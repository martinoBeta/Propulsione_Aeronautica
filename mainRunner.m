clc
clear 
close all
addpath("FunzioniMotore")
motoreBase = structMotore();
[parametri,rangeP] = structParametri();
[TSFC,motore] = runnerMotore(motoreBase,parametri);


%% OTTIMIZZAZIONE
tic

[parametri, rangeP] = structParametri();

nvars = length(parametri);
M     = max(400, 20*nvars);
lb    = rangeP(:,1)';
ub    = rangeP(:,2)';

fun     = @(x) runnerMotore(motoreBase, x);
nonlcon = @(x) mycon(x, motoreBase);

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
n_runs = 20;
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
    fprintf('  fval = %.4f\n', fi);
    if fi < best_f
        best_f = fi;
        best_x = xi;
    end
end

x1 = best_x;
fprintf('Best fval across all runs: %.4f\n', best_f);

% ── Post-process ──────────────────────────────────────────────────────────
[T, motore1] = runnerMotore(motoreBase, x1);
[z, u]       = mycon(x1, motoreBase);

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

%% PLOT GRAFICI MOTORE

%% Pressioni totali lungo il motore

Ptot = [
    motore1.freestream.h12km.P00
    motore1.presaAria.P02
    motore1.compressore.P03
    motore1.diffusore.P035
    motore1.camera.P04
    motore1.turbina.P05
    motore1.ugello.P06
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


%% Temperature totali lungo il motore

Ttot = [
    motore1.freestream.h12km.T00
    motore1.presaAria.T02
    motore1.compressore.T03
    motore1.diffusore.T035
    motore1.camera.T04
    motore1.turbina.T05
    motore1.ugello.T06
];

figure
plot(1:length(Ttot), Ttot, '-o', 'LineWidth',1.5)
grid on
xticks(1:length(Ttot))
xticklabels(stazioni)
xlabel('Stazione motore')
ylabel('T_0 [K]')
title('Temperatura totale lungo il motore')


%% Aree principali lungo il motore

Aree = [
    motore1.presaAria.A_ingresso
    motore1.presaAria.A2
    motore1.compressore.Aout_c
    motore1.diffusore.A35
    motore1.turbina.A4
    motore1.turbina.A5
    motore1.ugello.AStar
    motore1.ugello.AE
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

%% VINCOLI
valoriVincoli = [

    % Compressore
    motore1.compressore.machRel
    motore1.compressore.CpStadio
    motore1.compressore.deHaller
    motore1.compressore.DRotore
    motore1.compressore.DStatore

    % Camera
    motore1.camera.tRes
    motore1.camera.phi

    
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


%% STAMPA RISULTATI A VIDEO
fprintf('\n          RISULTATI OTTIMIZZAZIONE            \n')

fprintf('\n--- PERFORMANCE ---\n')
fprintf('Spinta            = %.3f N\n', motore1.performance.F)
fprintf('TSFC              = %.9f kg/(N*s)\n', motore1.performance.TSFC)
fprintf('eta globale       = %.3f\n', motore1.performance.etaGlobal)

fprintf('\n--- PRESA D''ARIA ---\n')
fprintf('T02                  = %.3f K\n', motore1.presaAria.T02)
fprintf('P02                  = %.3f Pa\n', motore1.presaAria.P02)
fprintf('Portata totale aria  = %.3f kg/s\n', motore1.portate.mDot)
fprintf('A ingresso           = %.4f m^2\n', motore1.presaAria.A_ingresso)
fprintf('A2                   = %.4f m^2\n', motore1.presaAria.A2)
fprintf('CPR                  = %.3f\n', motore1.presaAria.CPR)

fprintf('\n--- COMPRESSORE ---\n')
fprintf('T03                        = %.3f K\n', motore1.compressore.T03)
fprintf('P03                        = %.3f Pa\n', motore1.compressore.P03)
fprintf('Rapporto compressione π_c  = %.3f\n', motore1.compressore.piC)
fprintf('L_c                        = %.3f MW\n', motore1.compressore.L_c/1e6)
fprintf('etaC                       = %.3f\n', motore1.compressore.etaC)
fprintf('Utip compressore           = %.3f m/s\n', motore1.compressore.Utip)
fprintf('Mach ingresso compressore  = %.3f\n', motore1.presaAria.M2)
fprintf('Mach relativo              = %.3f\n', motore1.compressore.machRel)
fprintf('Mach assoluto              = %.3f\n', motore1.compressore.Mach_abs)
fprintf('Cp stadio                  = %.3f\n', motore1.compressore.CpStadio)
fprintf('De Haller                  = %.3f\n', motore1.compressore.deHaller)
fprintf('D rotore                   = %.3f\n', motore1.compressore.DRotore)
fprintf('D statore                  = %.3f\n', motore1.compressore.DStatore)
fprintf('N stadi                    = %d\n', motore1.compressore.NStadi)
fprintf('N pale rotore              = %d\n', motore1.compressore.N_R)
fprintf('r_m_in                     = %.4f m\n', motore1.compressore.r_m_in)
fprintf('r_m_out                    = %.4f m\n', motore1.compressore.r_m_out)
fprintf('hIn                        = %.4f m\n', motore1.compressore.hIn)
fprintf('hOut                       = %.4f m\n', motore1.compressore.hOut)

fprintf('\n--- DIFFUSORE ---\n')
fprintf('T035      = %.3f K\n', motore1.diffusore.T035)
fprintf('P035      = %.3f Pa\n', motore1.diffusore.P035)
fprintf('Mach35    = %.3f\n', motore1.diffusore.mach35)
fprintf('A3        = %.4f m^2\n', motore1.diffusore.A3)
fprintf('A35       = %.4f m^2\n', motore1.diffusore.A35)
fprintf('LD        = %.4f m\n', motore1.diffusore.LD)

fprintf('\n--- CAMERA DI COMBUSTIONE ---\n')
fprintf('T04               = %.3f K\n', motore1.camera.T04)
fprintf('P04               = %.3f Pa\n', motore1.camera.P04)
fprintf('f                 = %.5f\n', motore1.camera.f)
fprintf('phi               = %.3f\n', motore1.camera.phi)
fprintf('tRes              = %.5f s\n', motore1.camera.tRes)
fprintf('ARef              = %.4f m^2\n', motore1.camera.ARef)
fprintf('V camera          = %.4f m^3\n', motore1.camera.V)
fprintf('LC                = %.4f m\n', motore1.camera.LC)

fprintf('\n--- TURBINA ---\n')
fprintf('T05               = %.3f K\n', motore1.turbina.T05)
fprintf('P05               = %.3f Pa\n', motore1.turbina.P05)
fprintf('etaN              = %.3f\n', motore1.turbina.etaN)
fprintf('n stadi           = %d\n', motore1.turbina.nStadi)
fprintf('A4                = %.4f m^2\n', motore1.turbina.A4)
fprintf('A5                = %.4f m^2\n', motore1.turbina.A5)

fprintf('\n--- UGELLO ---\n')
fprintf('Ue                = %.3f m/s\n', motore1.ugello.Ue)
fprintf('Mach uscita       = %.3f\n', motore1.ugello.mach6)
fprintf('A*                = %.5f m^2\n', motore1.ugello.AStar)
fprintf('Ae                = %.5f m^2\n', motore1.ugello.AE)
fprintf('De                = %.4f m\n', motore1.ugello.DE)

fprintf('\n--- PORTATE ---\n')
fprintf('mDot totale       = %.4f kg/s\n', motore1.portate.mDot)
fprintf('mDot aria camera  = %.4f kg/s\n', motore1.portate.mDotAir)
fprintf('mDot raffredd.    = %.4f kg/s\n', motore1.portate.mDotRaff)
fprintf('mDot combustibile = %.4f kg/s\n', motore1.portate.mDotComb)
fprintf('mDot gas          = %.4f kg/s\n', motore1.portate.mDotGas)



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

function [ineq, eq] = mycon(x, motoreBase)
    [~, motore] = runnerMotore(motoreBase, x);
    ineq = [
        motore.compressore.machRel   - 1;
        0.72 - motore.compressore.deHaller;
        motore.compressore.CpStadio  - 0.5;
        motore.compressore.DRotore   - 0.6;
        motore.compressore.DStatore  - 0.6;
        0.008 - motore.camera.tRes;
        motore.camera.phi            - 1.1;
        0.7   - motore.camera.phi;
    ];
    eq = [ motore.performance.F - 25000 ];
end




%----------------------------------------------------------------------
%----------------------------------------------------------------------

% %% OTTIMIZZAZIONE
% tic
% 
% 
% [parametri,rangeP] = structParametri();
% 
% fun = @(x) runnerMotore(motoreBase,x);
% 
% nonlcon = @(x) mycon(x,motoreBase);
% 
% % x = fmincon(fun,parametri,[],[],[],[], ...
% %             rangeP(:,1),rangeP(:,2),nonlcon);
% 
% 
% fun     = @(x) runnerMotore(motoreBase, x);
% nonlcon = @(x) mycon(x, motoreBase);
% 
% 
% bestTSFC = inf; % Salva il TSFC minore
% 
% nSeed = 40;     % numero di ottimizzazioni indipendenti
% 
% M = 1000;       % Best M candidates from grid-search as seeds
% 
% 
% hybrid_opts = optimoptions('fmincon', ...   % Solution refinement with fmincon
%     'Display',           'none', ...
%     'Algorithm',         'sqp', ...
%     'StepTolerance',     1e-12, ...
%     'FunctionTolerance', 1e-12);
% 
% 
% 
% for seed = 1:nSeed
% 
%     rng(seed);    % cambia il seed ad ogni iterazione
% 
%     init_pop = zeros(M, length(parametri));
% 
%     options_ga = optimoptions('ga', ...
%         'PopulationSize',          M, ...
%         'MaxGenerations',          ceil(M/200), ...
%         'FunctionTolerance',       1e-8, ...
%         'MaxStallGenerations',     ceil(M/100), ...
%         'Display',                 'none', ...
%         'InitialPopulationMatrix', init_pop, ...
%         'InitialPopulationRange',  rangeP', ...
%         'maxTime',                 100,...
%         'HybridFcn',               {@fmincon, hybrid_opts});
% 
%     xTmp = ga(fun, length(parametri), [], [], [], [], ...
%               rangeP(:,1), rangeP(:,2), nonlcon, options_ga);
% 
%     [TSFC_tmp, motoreTmp] = runnerMotore(motoreBase,xTmp);
% 
%     fprintf('Seed %2d --> TSFC = %.8f\n', seed, TSFC_tmp)
% 
%     if TSFC_tmp < bestTSFC
% 
%         bestTSFC = TSFC_tmp;
% 
%         x1 = xTmp;
% 
%         motore1 = motoreTmp;
% 
%     end
% 
% end
% 
% [z,u] = mycon(x1,motoreBase);
% 
% fprintf('\n')
% fprintf('MIGLIOR TSFC TROVATO = %.8f\n', bestTSFC)
% fprintf('\n')
% fprintf('\n')
%----------------------------------------------------------------------
%----------------------------------------------------------------------



%---------------------------------------------------------------------

toc

% function [ineqnonlin,eqnonlin] = mycon(x,motoreBase)
% 
%     [~,motore] = runnerMotore(motoreBase,x);
% 
%     ineqnonlin = [ ...                      % f <= 0
%         motore.compressore.machRel-1;
%         0.72 - motore.compressore.deHaller;
%         motore.compressore.CpStadio - 0.5;
%         motore.compressore.DRotore - 0.6;
%         motore.compressore.DStatore - 0.6;
%         motore.compressore.NStadi - 20;
%         0.008 - motore.camera.tRes;
%         motore.camera.phi - 1.1;
%         0.7 -  motore.camera.phi;      
%         ];                            % Compute nonlinear inequalities at x.
% 
%     eqnonlin = [ ...
%         motore.performance.F - 25000;
%     ];    % Compute nonlinear equalities at x.
% 
% end