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
n_runs = 5;
best_f = inf;
best_x = [];

for i = 1:n_runs
    fprintf('Run %d/%d ...\n', i, n_runs);

    init_pop = lb + lhs_sample(M, nvars) .* (ub - lb);
    options_ga = optimoptions(options_ga, 'InitialPopulationMatrix', init_pop);

    [xi, fi] = ga(fun, nvars, [], [], [], [], lb, ub, nonlcon, options_ga);

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

%% 
% %% 
% FS = 1; % fattore di sicurezza
% 
% 
% best_NStadi = 100000;
% best_Ain     = 100000;
% 
% for Utip = Utip_range
% for machIns = machIn_range
%     for piC = piC_range
% 
%         motore = runnerMotore(motoreBase,propFluidi);
%         if motore.compressore.machRel  < FS*1.0  && ...  % Vincoli aerodinamici compressore
%            motore.compressore.CpStadio < FS*0.5  && ...
%            motore.compressore.deHaller  > 0.72/FS && ...
%            motore.compressore.DRotore  < FS*0.6  && ...
%            motore.compressore.DStatore < FS*0.6  && ...
%            motore.compressore.NStadi   < 20     && ...  % Vincoli geometrici compressore
%            motore.compressore.N_R       < 180    && ...
%            motore.compressore.r_m_in   < 1.2     && ...
%            motore.compressore.r_m_out   < 1.2 
% 
% 
%             nuovaSoluzione = false;
% 
%             if NStadi < best_NStadi
%                 nuovaSoluzione = true;
% 
% %% 
% FS = 
%             elseif NStadi == best_NStadi && Ain < best_Ain
%                 nuovaSoluzione = true;
%             end
% 
%             if nuovaSoluzione
% 
%                 best_NStadi = NStadi;
%       
% %% 
% FS =           best_Ain = Ain;
% 
%                 best_machIn = machIns;
%                 best_Utip = Utip;
%                 best_piC = piC;
% 
%                 best_T0U = T0U;
%                 best_P0U = P0U;
%                 best_lComp = lComp;
%                 best_etaC = etaC;
% 
%                 best_machRel = machRel;
%                 best_Mach_abs = Mach_abs;
% 
%                 best_Cp = CpStadio;
%                 best_deHaller = deHaller;
% 
%                 best_DRotore = DRotore;
% 
%                 best_DStatore = DStatore;
%                 best_R_m = R_m;
% 
%                 best_Va = Va;
%                 best_beta1 = beta1;
%                 best_beta2 = beta2;
% 
%                 best_Aout = Aout;
% 
%                 best_r_m_in = r_m_in;
%                 best_hIn = hIn;
% 
%                 best_r_m_out = r_m_out;
%                 best_hOut = hOut;
% 
%                 best_c_m = c_m;
%                 best_N_R = N_R;
% 
%             end
%         end
%     end
% end
% end
% 
% if best_NStadi == 100000
%     error('Nessuna configurazione valida trovata')
% end

% 