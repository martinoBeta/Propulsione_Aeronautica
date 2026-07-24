clc
clear 
close all
addpath("FunzioniMotore")

ramjetBase = structRamjet();
load('turbogetto.mat')

% DA COMPLETARE!! % 

%% OTTIMIZZAZIONE
tic

% [parametri, rangeP] = structParametri();
rangeP = [5 400; 1300 2100; 4 10];
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
n_runs = 5;
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
    ramjet.anulus.rIn
    ramjet.anulus.rOut
    motore.turbina.rt5
    ramjet.ugello.AStar
    ramjet.ugello.AE];

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
