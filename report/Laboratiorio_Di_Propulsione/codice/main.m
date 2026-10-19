%% =======================================================================
%  NOME DELLO SCRIPT: main.m
%  AUTORI: Luca Borghi, Martino Maria Colciago, Giovanni De Stefano, Adriano Pattacini
%  DATA: 16/07/2026
%  DESCRIZIONE: Script per il dimensionamento preliminare e l'ottimizzazione
%               di un motore a ciclo variabile (Turbogetto / Ramjet).
%% =======================================================================



%% -----------------------------------------------------------------------
%  1. OTTIMIZZAZIONE DEL TURBOGETTO
%  -----------------------------------------------------------------------

clear 
clc
close all

addpath("/FunzioniMotore")
motoreBase = structMotore();


% ── OTTIMIZZAZIONE ──────────────────────────────────────────────────────
tic

[parametri, rangeP] = structParametri();

nvars = length(parametri);
M     = max(400, 20*nvars);
lb    = rangeP(:,1)';
ub    = rangeP(:,2)';

fun     = @(x) runnerMotore(motoreBase, x);
nonlcon = @(x) myconTurbo(x, motoreBase);

% ── GA options ──────────────────────────────────────────────────────────
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

% ── Multi-start ─────────────────────────────────────────────────────────
n_runs = 150;
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
    if fi < best_f && all(condDisEq <= 0) && all(condEq <= 0)
       best_f = fi;
       best_x = xi;
    end
end

if isempty(best_x)
    error('Nessuna soluzione fattibile trovata')
end

x1 = best_x;
fprintf('Best fval across all runs: %.4f\n', best_f);

% ── Post-process ────────────────────────────────────────────────────────
[T, motore] = runnerMotore(motoreBase, best_x);
[z, u]  = myconTurbo(best_x, motoreBase);

% ── Diagramma T-s reale del ciclo turbogetto ────────────────────────────

gammaA = motore.fluidi.aria.gamma;
RA     = motore.fluidi.aria.R;
cpA    = motore.fluidi.aria.cp;

gammaG = motore.fluidi.gas.gamma;
RG     = motore.fluidi.gas.R;
cpG    = motore.fluidi.gas.cp;

N = 200;

% Stati statici reali
% 0 - freestream
T0 = motore.freestream.h12km.T0;
P0 = motore.freestream.h12km.P0;

% 2 - uscita presa / ingresso compressore
T2 = motore.presaAria.T02;
P2 = motore.presaAria.P02;

% 3 - uscita compressore
M3 = motore.compressore.mach3;
T3 = motore.compressore.T03;
P3 = motore.compressore.P03;

% 3.5 - uscita diffusore / ingresso camera
M35 = motore.diffusore.mach35;
T35 = motore.diffusore.T035;
P35 = motore.diffusore.P035;

% 4 - uscita camera / ingresso turbina
M4 = motore.turbina.mach4;
T4 = motore.camera.T04;
P4 = motore.camera.P04;

% 5 - uscita turbina
M5 = motore.turbina.mach5;
T5 = motore.turbina.T05;
P5 = motore.turbina.P05;

% 6 - uscita ugello
M6 = motore.ugello.mach6;
T6 = motore.ugello.T06/(1 + (gammaG-1)/2*M6^2);
P6 = motore.ugello.P06/(1 + (gammaG-1)/2*M6^2)^(gammaG/(gammaG-1));

% Funzioni

entropiaAria = @(T,P,Tref,Pref,sref) ...
    sref + (cpA*log(T./Tref) - RA*log(P./Pref))/1000;

entropiaGas = @(T,P,Tref,Pref,sref) ...
    sref + (cpG*log(T./Tref) - RG*log(P./Pref))/1000;

poly_curve = @(Ti,Pi,Tf,Pf,N) deal( ...
    linspace(Pi,Pf,N), ...
    Ti*(linspace(Pi,Pf,N)/Pi).^(log(Tf/Ti)/log(Pf/Pi)) ); % Non rappresenta la vera trasformazione termodinamica
%                                                           ma una sua approssimazione usando una legge esponenziale

% Entropie calcolate nei punti reali

s0 = 0;
s2  = entropiaAria(T2, P2, T0, P0, s0);
s3  = entropiaAria(T3, P3, T2, P2, s2);
s35 = entropiaAria(T35, P35, T3, P3, s3);

s4  = entropiaGas(T4, P4, T35, P35, s35);
s5  = entropiaGas(T5, P5, T4, P4, s4);
s6  = entropiaGas(T6, P6, T5, P5, s5);

% Curve reali

% 0 -> 2 presa reale
[P02_curve,T02_curve] = poly_curve(T0,P0,T2,P2,N);
s02_curve = entropiaAria(T02_curve,P02_curve,T0,P0,s0);

% 2 -> 3 compressione reale
[P23_curve,T23_curve] = poly_curve(T2,P2,T3,P3,N);
s23_curve = entropiaAria(T23_curve,P23_curve,T2,P2,s2);

% 3 -> 3.5 diffusore reale
[P335_curve,T335_curve] = poly_curve(T3,P3,T35,P35,N);
s335_curve = entropiaAria(T335_curve,P335_curve,T3,P3,s3);

% 3.5 -> 4 combustione reale con perdita di pressione
T354_curve = linspace(T35,T4,N);
P354_curve = linspace(P35,P4,N);
s354_curve = entropiaGas(T354_curve,P354_curve,T35,P35,s35);

% 4 -> 5 espansione turbina reale
[P45_curve,T45_curve] = poly_curve(T4,P4,T5,P5,N);
s45_curve = entropiaGas(T45_curve,P45_curve,T4,P4,s4);

% 5 -> 6 espansione ugello reale
[P56_curve,T56_curve] = poly_curve(T5,P5,T6,P6,N);
s56_curve = entropiaGas(T56_curve,P56_curve,T5,P5,s5);

% ── Plot ────────────────────────────────────────────────────────────────


% Cilco Termodinamico Reale T-s
figure
hold on
grid on
box on

plot(s02_curve,T02_curve,'LineWidth',1.6)
plot(s23_curve,T23_curve,'LineWidth',1.8)
plot(s335_curve,T335_curve,'LineWidth',1.6)
plot(s354_curve,T354_curve,'LineWidth',1.8)
plot(s45_curve,T45_curve,'LineWidth',1.8)
plot(s56_curve,T56_curve,'LineWidth',1.6)

s_points = [s0 s2 s3 s35 s4 s5 s6];
T_points = [T0 T2 T3 T35 T4 T5 T6];
labels = {'0','02','03','03.5','04','05','6'};

plot(s_points, T_points, 'ko', 'MarkerFaceColor', 'w', 'LineWidth', 0.1, 'MarkerSize', 3)

text(s0  -0.008 , T0  -30 , 'T_{0}'  ,'FontSize',8)
text(s2  -0.008, T2  +30 , 'T_{02}'  ,'FontSize',8)

text(s3  -0.008 , T3  +30 , 'T_{03}'  ,'FontSize',8)
text(s35 +0.005 , T35 +30 , 'T_{03.5}','FontSize',8)

text(s4  +0.006 , T4  +8  , 'T_{04}'  ,'FontSize',8)
text(s5  +0.006 , T5  +8  , 'T_{05}'  ,'FontSize',8)
text(s6  +0.006 , T6  +8  , 'T_{6}'  ,'FontSize',8)

plot([s6 s0],[T6 T0], ...
    '--', ...
    'Color',[0.5 0.5 0.5], ...
    'LineWidth',1);

xlabel('$s-s_0$ [kJ/(kg K)]','Interpreter','latex')
ylabel('$T$ [K]','Interpreter','latex')
title('Diagramma $T-s$ reale del ciclo turbogetto','Interpreter','latex')

set(gca,'FontSize',11)
hold off
xlim([-0.05 1.5])
ylim([-20 1650])


% ANDAMENTO TSFC MINIMO PER OGNI RUN
figure
plot(1:n_runs, fHistory, 'o-')
xlabel('Run')
ylabel('Minimo della funzione obiettivo')
grid on

% MIGLIOR VALORE PROGRESSIVO ( TSFC minore)
% Il grafico mostra il minimo cumulativo della funzione obiettivo
% ottenuto attraverso diverse run indipendenti del GA. Ogni run parte
% da un seed casuale differente, mentre il grafico tiene traccia della
% migliore soluzione trovata fino a quel momento.
figure
plot(1:n_runs, cummin(fHistory), 'o-')
xlabel('Run')
ylabel('Minimo cumulativo della funzione obiettivo')
grid on


% ── PLOT GRAFICI MOTORE ──────────────────────────────────────────────────

% Pressioni totali lungo il motore

Ptot = [
    motore.freestream.h12km.P00
    motore.presaAria.P02
    motore.compressore.P03
    motore.diffusore.P035
    motore.camera.P04
    motore.turbina.P05
    motore.ugello.P06
];

stazioni = {'0','2','3','3.5','4','5','6'};

figure
plot(1:length(Ptot), Ptot/1000, '-o', 'LineWidth',1.5)
grid on
xticks(1:length(Ptot))
xticklabels(stazioni)
xlabel('Stazione motore')
ylabel('P_0 [kPa]')
title('Pressione totale lungo il motore')


% Temperature totali lungo il motore

Ttot = [
    motore.freestream.h12km.T00
    motore.presaAria.T02
    motore.compressore.T03
    motore.diffusore.T035
    motore.camera.T04
    motore.turbina.T05
    motore.ugello.T06
];

figure
plot(1:length(Ttot), Ttot, '-o', 'LineWidth',1.5)
grid on
xticks(1:length(Ttot))
xticklabels(stazioni)
xlabel('Stazione motore')
ylabel('T_0 [K]')
title('Temperatura totale lungo il motore')


% Aree principali lungo il motore

Aree = [
    motore.presaAria.A0
    motore.presaAria.A2
    motore.compressore.A3
    motore.diffusore.A35
    motore.turbina.A4
    motore.turbina.A5
    motore.ugello.AStar
    motore.ugello.AE
];

nomiAree = {
    'A ingresso presa'
    'A_2 ingresso comp.'
    'A uscita comp.'
    'A uscita diffusore'
    'A_4 turbina'
    'A_5 turbina'
    'A^* ugello'
    'A_e ugello'};

figure
bar(Aree)
grid on
set(gca,'XTickLabel',nomiAree)
xtickangle(35)
ylabel('Area [m^2]')
title('Aree principali del motore')

% ── VINCOLI ─────────────────────────────────────────────────────────────
valoriVincoli = [

    % Compressore
    motore.compressore.machRel
    motore.compressore.CpStadio
    motore.compressore.deHaller
    motore.compressore.DRotore
    motore.compressore.DStatore

    % Camera
    motore.camera.tRes
    motore.camera.phi

    
];

limitiVincoli = [

    % Compressore
    1.0
    0.5
    0.72
    0.6
    0.6

    % Camera
    0.008
    1.1

];

nomiVincoli = {

    'Mach rel'
    'Cp stadio'
    'De Haller'
    'D rotore'
    'D statore'

    'tRes'
    '\phi'};

figure
bar([valoriVincoli, limitiVincoli])
grid on
box on
set(gca,'XTickLabel',nomiVincoli)
ylabel('Valore')
title('Confronto risultati ottimizzati vs vincoli')
legend('Valore ottenuto','Limite')
xtickangle(35)


% ── STAMPA RISULTATI A VIDEO ────────────────────────────────────────────
fprintf('\n          RISULTATI OTTIMIZZAZIONE            \n')

fprintf('\n--- PERFORMANCE ---\n')
fprintf('Spinta            = %.3f N\n', motore.performance.F)
fprintf('TSFC              = %.9f kg/(N*h)\n', motore.performance.TSFC)
fprintf('eta globale       = %.3f\n', motore.performance.etaGlobal)

fprintf('\n--- PRESA D''ARIA ---\n')
fprintf('T02                  = %.3f K\n', motore.presaAria.T02)
fprintf('P02                  = %.3f Pa\n', motore.presaAria.P02)
fprintf('Portata totale aria  = %.3f kg/s\n', motore.portate.mDot)
fprintf('A ingresso           = %.4f m^2\n', motore.presaAria.A0)
fprintf('A2                   = %.4f m^2\n', motore.presaAria.A2)
fprintf('CPR                  = %.3f\n', motore.presaAria.CPR)

fprintf('\n--- COMPRESSORE ---\n')
fprintf('T03                        = %.3f K\n', motore.compressore.T03)
fprintf('P03                        = %.3f Pa\n', motore.compressore.P03)
fprintf('Rapporto compressione π_c  = %.3f\n', motore.compressore.piC)
fprintf('L_c                        = %.3f MW\n', motore.compressore.LC/1e6)
fprintf('etaC                       = %.3f\n', motore.compressore.etaC)
fprintf('Utip compressore           = %.3f m/s\n', motore.compressore.Utip)
fprintf('Mach ingresso compressore  = %.3f\n', motore.presaAria.mach2)
fprintf('Mach relativo              = %.3f\n', motore.compressore.machRel)
fprintf('Mach assoluto              = %.3f\n', motore.compressore.MachAbs)
fprintf('Cp stadio                  = %.3f\n', motore.compressore.CpStadio)
fprintf('De Haller                  = %.3f\n', motore.compressore.deHaller)
fprintf('D rotore                   = %.3f\n', motore.compressore.DRotore)
fprintf('D statore                  = %.3f\n', motore.compressore.DStatore)
fprintf('N stadi                    = %d\n', motore.compressore.NStadi)
fprintf('N pale rotore              = %d\n', motore.compressore.NPaleComp)
fprintf('rM2                     = %.4f m\n', motore.compressore.rM2)
fprintf('rM3                    = %.4f m\n', motore.compressore.rM3)
fprintf('h2                        = %.4f m\n', motore.compressore.h2)
fprintf('hOut                       = %.4f m\n', motore.compressore.h3)

fprintf('\n--- DIFFUSORE ---\n')
fprintf('T035      = %.3f K\n', motore.diffusore.T035)
fprintf('P035      = %.3f Pa\n', motore.diffusore.P035)
fprintf('v35       = %.3f m/2\n', motore.diffusore.vTargetCamera)
fprintf('Mach35    = %.3f\n', motore.diffusore.mach35)
fprintf('A3        = %.4f m^2\n', motore.diffusore.A3)
fprintf('A35       = %.4f m^2\n', motore.diffusore.A35)
fprintf('LD        = %.4f m\n', motore.diffusore.LD)

fprintf('\n--- CAMERA DI COMBUSTIONE ---\n')
fprintf('T04               = %.3f K\n', motore.camera.T04)
fprintf('P04               = %.3f Pa\n', motore.camera.P04)
fprintf('f                 = %.5f\n', motore.camera.f)
fprintf('phi               = %.3f\n', motore.camera.phi)
fprintf('tRes              = %.5f s\n', motore.camera.tRes)
fprintf('ARef              = %.4f m^2\n', motore.camera.ARef)
fprintf('V camera          = %.4f m^3\n', motore.camera.V)
fprintf('LC                = %.4f m\n', motore.camera.LC)

fprintf('\n--- TURBINA ---\n')
fprintf('T05               = %.3f K\n', motore.turbina.T05)
fprintf('P05               = %.3f Pa\n', motore.turbina.P05)
fprintf('etaN              = %.3f\n', motore.turbina.etaN)
fprintf('n stadi           = %d\n', motore.turbina.nStadi)
fprintf('A4                = %.4f m^2\n', motore.turbina.A4)
fprintf('A5                = %.4f m^2\n', motore.turbina.A5)

fprintf('\n--- UGELLO ---\n')
fprintf('Ue                = %.3f m/s\n', motore.ugello.Ue)
fprintf('Mach uscita       = %.3f\n', motore.ugello.mach6)
fprintf('A*                = %.5f m^2\n', motore.ugello.AStar)
fprintf('Ae                = %.5f m^2\n', motore.ugello.AE)
fprintf('De                = %.4f m\n', motore.ugello.DE)

fprintf('\n--- PORTATE ---\n')
fprintf('mDot totale       = %.4f kg/s\n', motore.portate.mDot)
fprintf('mDot aria camera  = %.4f kg/s\n', motore.portate.mDotAir)
fprintf('mDot raffredd.    = %.4f kg/s\n', motore.portate.mDotRaff)
fprintf('mDot combustibile = %.4f kg/s\n', motore.portate.mDotComb)
fprintf('mDot gas          = %.4f kg/s\n', motore.portate.mDotGas)



fprintf('\n--- CONTROLLO VINCOLI ---\n')
fprintf('Max c             = %.6e\n', max(z))
fprintf('Norm ceq          = %.6e\n', norm(u))



toc


save('turbogetto.mat', 'motore');


%% -----------------------------------------------------------------------
%  3. OTTIMIZZAZIONE DEL RAMJET
%  -----------------------------------------------------------------------
clear

ramjetBase = structRamjet();
load('turbogetto.mat')

% ── OTTIMIZZAZIONE ──────────────────────────────────────────────────────
tic

% [parametri, rangeP] = structParametri();
rangeP = [5 400;1500 2100; 4 10];
parametri = [5; 1600; 2];

nvars = length(parametri);
M     = max(400, 20*nvars);
lb    = rangeP(:,1)';
ub    = rangeP(:,2)';

fun     = @(x) runnerRamjet(ramjetBase, x, motore);
nonlcon = @(x) myconRamjet(x, ramjetBase, motore);

% ── GA options ──────────────────────────────────────────────────────────
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

% ── Multi-start ─────────────────────────────────────────────────────────
n_runs = 150;
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

% ── Post-process ────────────────────────────────────────────────────────
[T, ramjet] = runnerRamjet(ramjetBase, x1, motore);
[z, u]       = myconRamjet(x1, ramjetBase, motore);



% ANDAMENTO TSFC MINIMO PER OGNI RUN
figure
plot(1:n_runs, fHistory, 'o-')
xlabel('Run')
ylabel('Funzione obiettivo')
grid on

% MIGLIOR VALORE PROGRESSIVO ( TSFC minore)
% Il grafico mostra il minimo cumulativo della funzione obiettivo
% ottenuto attraverso diverse run indipendenti del GA. Ogni run parte
% da un seed casuale differente, mentre il grafico tiene traccia della
% migliore soluzione trovata fino a quel momento.
figure
plot(1:n_runs, cummin(fHistory), 'o-')
xlabel('Run')
ylabel('Minimo cumulativo della funzione obiettivo')
grid on


% ── PLOT GRAFICI ramjet ─────────────────────────────────────────────────

% Pressioni totali lungo il ramjet

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


% Temperature totali lungo il ramjet

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


% Aree principali lungo il ramjet

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

% diametri/ altezze principali ramjet
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

% ── STAMPA RISULTATI A VIDEO ────────────────────────────────────────────
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


save('ramjet.mat', 'ramjet');


% ── DIAGRAMMA T-s DEL RAMJET ────────────────────────────────────────────


% Proprietà
cp_a    = ramjet.fluidi.aria.cp;
R_a     = ramjet.fluidi.aria.R;
gamma_a = ramjet.fluidi.aria.gamma;

cp_g    = ramjet.fluidi.gas.cp;
R_g     = ramjet.fluidi.gas.R;
gamma_g = ramjet.fluidi.gas.gamma;

% STAZIONE 0

M0  = ramjet.freestream.h25km.M0;
T00 = ramjet.freestream.h25km.T00;
P00 = ramjet.freestream.h25km.P00;

T0 = T00/(1 + (gamma_a-1)/2*M0^2);
P0 = P00/(1 + (gamma_a-1)/2*M0^2)^(gamma_a/(gamma_a-1));


% STAZIONE 2 - uscita presa

M2  = ramjet.presaAria.M2;
T02 = ramjet.presaAria.T02;
P02 = ramjet.presaAria.P02;

T2 = T02/(1 + (gamma_a-1)/2*M2^2);
P2 = P02/(1 + (gamma_a-1)/2*M2^2)^(gamma_a/(gamma_a-1));


% STAZIONE 3 - uscita anulus

M3  = ramjet.anulus.mach3;
T03 = ramjet.anulus.T03;
P03 = ramjet.anulus.P03;

T3 = T03/(1 + (gamma_a-1)/2*M3^2);
P3 = P03/(1 + (gamma_a-1)/2*M3^2)^(gamma_a/(gamma_a-1));


% STAZIONE 4 - uscita camera

M4  = ramjet.camera.mach4;
T04 = ramjet.camera.T04;
P04 = ramjet.camera.P04;

T4 = T04/(1 + (gamma_g-1)/2*M4^2);
P4 = P04/(1 + (gamma_g-1)/2*M4^2)^(gamma_g/(gamma_g-1));


% STAZIONE 5 - uscita ugello

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

% Grafico

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



% PUNTI

plot(s0,T0,'o','MarkerSize',4,'LineWidth',1)
plot(s2,T2,'o','MarkerSize',4,'LineWidth',1)
plot(s3,T3,'o','MarkerSize',4,'LineWidth',1)
plot(s4,T4,'o','MarkerSize',4,'LineWidth',1)
plot(s5,T5,'o','MarkerSize',4,'LineWidth',1)

% ETICHETTE

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

%%
clear
load('turbogetto.mat');
load('ramjet.mat');


%% -----------------------------------------------------------------------
%  3. FUNZIONI AUSILIARIE
%  -----------------------------------------------------------------------

function X = lhs_sample(n, d)
    X = zeros(n, d);
    for j = 1:d
        X(:,j) = (randperm(n)' - rand(n,1)) / n;
    end
end

function [ineq, eq] = myconTurbo(x, motoreBase)
    % Funzione di vincolo non lineare per l'ottimizzazione del motore turbogetto.
    % Restituisce i vincoli di disuguaglianza (ineq) e uguaglianza (eq) basati sui parametri del motore e sulle condizioni di progetto.
    
    FS = 0.98;
    [~, motore] = runnerMotore(motoreBase, x); 
    ineq = [ ... 
        motore.compressore.machRel   - 1 * FS;
        0.72 - motore.compressore.deHaller;
        motore.compressore.CpStadio  - 0.5;
        motore.compressore.DRotore   - 0.6 * FS;
        motore.compressore.DStatore  - 0.6 * FS;
        0.008 - motore.camera.tRes;
        motore.camera.phi            - 1.1;
        0.7   - motore.camera.phi;
        (0.1 - motore.turbina.rh5) / 0.1; 
        - motore.compressore.h3 + 0.03;
        motore.presaAria.CPR - 0.78;
        motore.compressore.NStadi - 15;
        motore.diffusore.A35 - 0.8 
        motore.turbina.A5 - 0.8
        motore.camera.ARef - 0.8
        motore.turbina.nStadi - 5
        motore.performance.TSFC - 0.14

        
    ];
    eq = [ motore.performance.F - 25000 ];
end

function [ineq, eq] = myconRamjet(x, motoreBase, motore)
    [~, motore] = runnerRamjet(motoreBase, x, motore); % <
    ineq = [ ... 
        motore.performance.TSFC - 0.278;
        motore.ugello.DE - 1.6;
    ];
    eq = [ motore.performance.F - 65000 ];
end