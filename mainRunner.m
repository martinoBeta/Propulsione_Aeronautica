clc
clear 
close all
addpath("FunzioniMotore")
motoreBase = structMotore();
[parametri,rangeP] = structParametri();
[TSFC,motore] = runnerMotore(motoreBase,parametri);


%% OTTIMIZZAZIONE
tic
[parametri,rangeP] = structParametri();
fun = @(x) runnerMotore(motoreBase,x);
nonlcon = @(x) mycon(x,motoreBase);

% x = fmincon(fun,parametri,[],[],[],[],rangeP(:,1),rangeP(:,2),nonlcon);



M = 1000;         % Best M candidates from grid-search as seeds

init_pop = zeros(M, length(parametri));
hybrid_opts = optimoptions('fmincon', ...   % Solution refinement with fmincon
    'Display',           'none', ...
    'Algorithm',         'sqp', ...
    'StepTolerance',     1e-12, ...
    'FunctionTolerance', 1e-12);

options_ga = optimoptions('ga', ...
    'PopulationSize',          M, ...
    'MaxGenerations',          ceil(M/200), ...   
    'FunctionTolerance',       1e-8, ...
    'MaxStallGenerations',     ceil(M/100), ...
    'Display',                 'none', ...
    'InitialPopulationMatrix', init_pop, ...
    'InitialPopulationRange',  rangeP', ...
    'maxTime',                 100,...
    'HybridFcn',               {@fmincon, hybrid_opts});

x1 = ga(fun, length(parametri), [], [], [], [], rangeP(:,1), rangeP(:,2), nonlcon, options_ga);
% Aggiungere constrains!

function [ineqnonlin,eqnonlin] = mycon(x,motoreBase)
    [~,motore] = runnerMotore(motoreBase,x);

    ineqnonlin = [ ...                      % f <= 0
        motore.compressore.machRel-1;
        0.72 - motore.compressore.deHaller;
        motore.compressore.CpStadio - 0.5;
        motore.compressore.DRotore - 0.6;
        motore.compressore.DStatore - 0.6;
        % motore.compressore.NStadi - 20;
        0.008 - motore.camera.tRes;
        motore.camera.phi - 1.1;
        0.7 -  motore.camera.phi;      
        ];                            % Compute nonlinear inequalities at x.

    eqnonlin = [ ...
        motore.performance.F - 25000;
    ];    % Co
% %% mpute nonlinear equalities at x.
end
[T,motore1] = runnerMotore(motoreBase,x1);
[z,u] = mycon(x1,motoreBase);
toc

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