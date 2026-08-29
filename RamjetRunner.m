% clc
% clear 
% close all
addpath("FunzioniMotore")

ramjetBase = structRamjet();
%load('turbogetto.mat')

% DA COMPLETARE!! % 

%% OTTIMIZZAZIONE
tic

% [parametri, rangeP] = structParametri();
rangeP = [5 400;2100 2100; 4 10];
parametri = [5; 1600; 2];

nvars = length(parametri);
M     = max(400, 20*nvars);
lb    = rangeP(:,1)';
ub    = rangeP(:,2)';

fun     = @(x) runnerRamjet(ramjetBase, x, motore);
nonlcon = @(x) mycon(x, ramjetBase, motore);

% ── GA options ────────────────────────────────────────────────────────────
hybrid_opts = optimoptions('fmincon', ...
    'Display',           'none', ...
    'Algorithm',         'sqp', ...
    'StepTolerance',     1e-6, ...
    'FunctionTolerance', 1e-6);

options_ga = optimoptions('ga', ...
    'PopulationSize',      M, ...
    'UseParallel',         false, ...
    'MaxGenerations',      120, ...
    'FunctionTolerance',   1e-4, ...
    'MaxStallGenerations', 15, ...
    'Display',             'iter', ...
    'MaxTime',             60, ...
    'EliteCount',          ceil(0.10*M), ...
    'CrossoverFraction',   0.8, ...
    'HybridFcn',           {@fmincon, hybrid_opts});

% ── Multi-start ───────────────────────────────────────────────────────────
n_runs = 2;
best_f = inf;
best_x = [];
fHistory = zeros(n_runs,1);
xHistory = zeros(n_runs,nvars);

for i = 1:n_runs
    fprintf('Run %d/%d ...\n', i, n_runs);

    init_pop = lb + lhs_sample(M, nvars) .* (ub - lb);
    options_ga = optimoptions(options_ga, 'InitialPopulationMatrix', init_pop);

    [xi, fi] = ga(fun, nvars, [], [], [], [], lb, ub, nonlcon, options_ga);
    fHistory(i) = fi;
    xHistory(i,:) = xi;
    [condDisEq, condEq] = nonlcon(xi);
    fprintf('  fval = %.4f\n', fi);
    if fi < best_f && all(condDisEq <= 0)
        best_f = fi;
        best_x = xi;
    end
end
if isempty(best_x)
    error('Nessuna soluzione fattibile trovata')
end

x1 = best_x;
fprintf('Best fval across all runs: %.4f\n', best_f);

%% ── Post-process ──────────────────────────────────────────────────────────
[T, ramjet] = runnerRamjet(ramjetBase, x1, motore);
[z, u]       = mycon(x1, ramjetBase, motore);


cam  = ramjet.camera
port = ramjet.portate
an   = ramjet.anulus
ug   = ramjet.ugello
per  = ramjet.performance

%% ANDAMENTO TSFC MINIMO PER OGNI RUN
figure
plot(1:n_runs, fHistory, 'o-')
xlabel('Run')
ylabel('Objective function')
grid on

%% MIGLIOR VALORE PROGRESSIVO ( TSFC minore)
% Il grafico mostra il minimo cumulativo della funzione obiettivo
% ottenuto attraverso diverse run indipendenti del GA. Ogni run parte
% da un seed casuale differente, mentre il grafico tiene traccia della
% migliore soluzione trovata fino a quel momento.
figure
plot(1:n_runs, cummin(fHistory), 'o-')
xlabel('Run')
ylabel('Best objective so far')
grid on


%% PLOT GRAFICI ramjet

%% Pressioni totali lungo il ramjet

Ptot = [
    ramjet.freestream.h25km.P00
    ramjet.presaAria.P02
    ramjet.anulus.P03
    ramjet.camera.P04
    ramjet.ugello.P05
];

stazioni = {'0','2','3','4','5'};

figure
plot(1:length(Ptot), Ptot/1000, '-o', 'LineWidth',1.5)
grid on
xticks(1:length(Ptot))
xticklabels(stazioni)
xlabel('Stazione ramjet')
ylabel('P_0 [kPa]')
title('Pressione totale lungo il ramjet')


%% Temperature totali lungo il ramjet

Ttot = [
    ramjet.freestream.h25km.T00
    ramjet.presaAria.T02
    ramjet.anulus.T03
    ramjet.camera.T04
    ramjet.ugello.T05
];

figure
plot(1:length(Ttot), Ttot, '-o', 'LineWidth',1.5)
grid on
xticks(1:length(Ttot))
xticklabels(stazioni)
xlabel('Stazione ramjet')
ylabel('T_0 [K]')
title('Temperatura totale lungo il ramjet')


%% Aree principali lungo il ramjet

Aree = [
    ramjet.presaAria.ACatt
    ramjet.presaAria.A2
    ramjet.anulus.AIn
    ramjet.anulus.AOut
    ramjet.camera.A
    ramjet.ugello.AStar
    ramjet.ugello.AE
];

nomiAree = {
    'A ingresso presa'
    'A_2 ingresso anulus/fine presa.'
    'A_anulus area anulus ingresso'
    'A_a area anulus uscita'
    'A post Bruciatore'
    'A^* ugello'
    'A_e ugello'};

figure
bar(Aree)
grid on
set(gca,'XTickLabel',nomiAree)
xtickangle(35)
ylabel('Area [m^2]')
title('Aree principali del ramjet')

%% diametri/ altezze principali ramjet
RD = [
    ramjet.presaAria.hCatt
    ramjet.presaAria.hGola
    2*ramjet.anulus.rIn
    2*ramjet.anulus.rOut
    2*sqrt(ramjet.camera.A/pi)
    2*sqrt(ramjet.ugello.AStar/pi)
    2*sqrt(ramjet.ugello.AE/pi)
]

nomiRD = {
    'altezza di cattura' 
    'alezza gola presadaria'
    'anulus r2' 
    'anulus r3' 
    'post bruciatore' 
    'gola ' 
    'AE'};
figure
bar(RD)
grid on
set(gca,'XTickLabel',nomiRD)
% xtickangle(35)
ylabel('H/r [m]')
title('H/raggi principali del ramjet')
hold on
bar([0,0,0,sqrt(motore.turbina.A5/pi)*2], 'FaceColor', [1,0,0])

%% STAMPA RISULTATI A VIDEO
fprintf('\n          RISULTATI OTTIMIZZAZIONE            \n')

fprintf('\n--- PERFORMANCE ---\n')
fprintf('Spinta            = %.3f N\n', ramjet.performance.F)
fprintf('TSFC              = %.9f kg/(N*h)\n', ramjet.performance.TSFC)
fprintf('eta globale       = %.3f\n', ramjet.performance.etaGlobal)

fprintf('\n--- PRESA D''ARIA ---\n')
fprintf('T02                  = %.3f K\n', ramjet.presaAria.T02)
fprintf('P02                  = %.3f Pa\n', ramjet.presaAria.P02)
fprintf('Portata totale aria  = %.3f kg/s\n', ramjet.portate.mDot)
fprintf('A cattura           = %.4f m^2\n', ramjet.presaAria.ACatt)
fprintf('A2                   = %.4f m^2\n', ramjet.presaAria.A2)
fprintf('CPR                  = %.3f\n', ramjet.presaAria.CPR)

fprintf('\n--- ANULUS ---\n')
fprintf('T03                  = %.3f K\n', ramjet.anulus.T03)
fprintf('P03                  = %.3f Pa\n', ramjet.anulus.P03)
fprintf('A_a_in                  = %.4f m^2\n', ramjet.anulus.AIn)
fprintf('A_a_out                 = %.4f m^2\n', ramjet.anulus.AOut)

fprintf('\n--- CAMERA DI COMBUSTIONE ---\n')
fprintf('T04               = %.3f K\n', ramjet.camera.T04)
fprintf('P04               = %.3f Pa\n', ramjet.camera.P04)
fprintf('f                 = %.5f\n',   ramjet.camera.f)
fprintf('d                 = %.4f m\n', ramjet.camera.d)
fprintf('L                 = %.4f m\n', ramjet.camera.L)

fprintf('\n--- UGELLO ---\n')
fprintf('Ue                = %.3f m/s\n', ramjet.ugello.Ue)
fprintf('Mach uscita       = %.3f\n', ramjet.ugello.mach5)
fprintf('A*                = %.5f m^2\n', ramjet.ugello.AStar)
fprintf('Ae                = %.5f m^2\n', ramjet.ugello.AE)
fprintf('De                = %.4f m\n', ramjet.ugello.DE)

fprintf('\n--- PORTATE ---\n')
fprintf('mDot totale       = %.4f kg/s\n', ramjet.portate.mDot)
fprintf('mDot aria camera  = %.4f kg/s\n', ramjet.portate.mDotAir)
fprintf('mDot combustibile = %.4f kg/s\n', ramjet.portate.mDotComb)
fprintf('mDot gas          = %.4f kg/s\n', ramjet.portate.mDotGas)


fprintf('\n--- CONTROLLO VINCOLI ---\n')
fprintf('Max c             = %.6e\n', max(z))
fprintf('Norm ceq          = %.6e\n', norm(u))





toc
function X = lhs_sample(n, d)
    X = zeros(n, d);
    for j = 1:d
        X(:,j) = (randperm(n)' - rand(n,1)) / n;
    end
end


function [ineq, eq] = mycon(x, motoreBase, motore)
    [~, motore] = runnerRamjet(motoreBase, x, motore); % <
    ineq = [ ... 
        motore.performance.TSFC - 0.278;
        motore.ugello.DE - 2.4;
    ];
    eq = [ motore.performance.F - 65000 ];
end

save('ramjet.mat', 'ramjet');
GraficoPresa


%% DIAGRAMMA T-s DEL RAMJET


% Proprietà
cp_a    = ramjet.fluidi.aria.cp;
R_a     = ramjet.fluidi.aria.R;
gamma_a = ramjet.fluidi.aria.gamma;

cp_g    = ramjet.fluidi.gas.cp;
R_g     = ramjet.fluidi.gas.R;
gamma_g = ramjet.fluidi.gas.gamma;

%% ------------------------------------------------------------
% STAZIONE 0
% ------------------------------------------------------------

M0  = ramjet.freestream.h25km.M0;
T00 = ramjet.freestream.h25km.T00;
P00 = ramjet.freestream.h25km.P00;

T0 = T00/(1 + (gamma_a-1)/2*M0^2);
P0 = P00/(1 + (gamma_a-1)/2*M0^2)^(gamma_a/(gamma_a-1));


%% ------------------------------------------------------------
% STAZIONE 2 - uscita presa
% ------------------------------------------------------------

M2  = ramjet.presaAria.M2;
T02 = ramjet.presaAria.T02;
P02 = ramjet.presaAria.P02;

T2 = T02/(1 + (gamma_a-1)/2*M2^2);
P2 = P02/(1 + (gamma_a-1)/2*M2^2)^(gamma_a/(gamma_a-1));


%% ------------------------------------------------------------
% STAZIONE 3 - uscita anulus
% ------------------------------------------------------------

M3  = ramjet.anulus.mach3;
T03 = ramjet.anulus.T03;
P03 = ramjet.anulus.P03;

T3 = T03/(1 + (gamma_a-1)/2*M3^2);
P3 = P03/(1 + (gamma_a-1)/2*M3^2)^(gamma_a/(gamma_a-1));


%% ------------------------------------------------------------
% STAZIONE 4 - uscita camera
% ------------------------------------------------------------

M4  = ramjet.camera.mach4;
T04 = ramjet.camera.T04;
P04 = ramjet.camera.P04;

T4 = T04/(1 + (gamma_g-1)/2*M4^2);
P4 = P04/(1 + (gamma_g-1)/2*M4^2)^(gamma_g/(gamma_g-1));


%% ------------------------------------------------------------
% STAZIONE 5 - uscita ugello
% ------------------------------------------------------------

M5 = ramjet.ugello.mach5;
T5 = ramjet.ugello.T05/(1 + (gamma_g-1)/2*M5^2);
P5 = ramjet.ugello.PE;



% ENTROPIA RELATIVA
s0 = 0;

s2 = s0 + cp_a*log(T2/T0) ...
        - R_a*log(P2/P0);

s3 = s2 + cp_a*log(T3/T2) ...
        - R_a*log(P3/P2);

s4 = s3 + cp_g*log(T4/T3) ...
        - R_g*log(P4/P3);

s5 = s4 + cp_g*log(T5/T4) ...
        - R_g*log(P5/P4);

% J/(kg K) -> kJ/(kg K)
s0 = s0/1000;
s2 = s2/1000;
s3 = s3/1000;
s4 = s4/1000;
s5 = s5/1000;


% COSTRUZIONE DELLE CURVE
N = 100;

% 0 -> 2
q = linspace(0,1,N);
s02 = s0 + (s2-s0).*q;
T02_curve = T0 + (T2-T0).*q;

% 2 -> 3
q = linspace(0,1,N);
s23 = s2 + (s3-s2).*q;
T23_curve = T2 + (T3-T2).*q;

% 3 -> 4 : combustione
q = linspace(0,1,N);
s34 = s3 + (s4-s3).*q;
T34_curve = T3 + (T4-T3).*q.^1.35;

% 4 -> 5 : espansione
q = linspace(0,1,N);
s45 = s4 + (s5-s4).*q;
T45_curve = T4 + (T5-T4).*q.^0.85;


%% ============================================================
% GRAFICO
% ============================================================

figure
hold on
box on
grid on

% 0 -> 2
plot(s02,T02_curve, ...
    'LineWidth',1.5)

% 2 -> 3
plot(s23,T23_curve, ...
    'LineWidth',1.5)

% 3 -> 4
plot(s34,T34_curve, ...
    'm','LineWidth',2)

% 4 -> 5
plot(s45,T45_curve, ...
    'LineWidth',2)



%% PUNTI

plot(s0,T0,'o','MarkerSize',4,'LineWidth',1)
plot(s2,T2,'o','MarkerSize',4,'LineWidth',1)
plot(s3,T3,'o','MarkerSize',4,'LineWidth',1)
plot(s4,T4,'o','MarkerSize',4,'LineWidth',1)
plot(s5,T5,'o','MarkerSize',4,'LineWidth',1)

% ============================================================
% ETICHETTE
% Posizionate manualmente per evitare sovrapposizioni

text(s0+0.015,T0-30, ...
    '$T_0$', ...
    'Interpreter','latex','FontSize',10)

text(s2+0.015,T2+35, ...
    '$T_2$', ...
    'Interpreter','latex','FontSize',10)

text(s3+0.020,T3+65, ...
    '$T_3$', ...
    'Interpreter','latex','FontSize',10)

text(s4+0.020,T4-20, ...
    '$T_4$', ...
    'Interpreter','latex','FontSize',10)

text(s5+0.020,T5, ...
    '$T_5$', ...
    'Interpreter','latex','FontSize',10)



% ASSI
xlabel('$s-s_0\;[\mathrm{kJ/(kg\,K)}]$', ...
    'Interpreter','latex')

ylabel('$T\;[\mathrm{K}]$', ...
    'Interpreter','latex')

set(gca, ...
    'FontSize',10, ...
    'TickLabelInterpreter','latex')

hold off