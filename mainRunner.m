%% 
clear 
close all
addpath("FunzioniMotore")
motoreBase = structMotore();


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

%% ── Post-process ──────────────────────────────────────────────────────────
[T, motore] = runnerMotore(motoreBase, best_x);

%% Diagramma T-s reale del ciclo turbogetto

gammaA = motore.fluidi.aria.gamma;
RA     = motore.fluidi.aria.R;
cpA    = motore.fluidi.aria.cp;

gammaG = motore.fluidi.gas.gamma;
RG     = motore.fluidi.gas.R;
cpG    = motore.fluidi.gas.cp;

N = 200;

%% Stati statici reali

% 0 - freestream
T0 = motore.freestream.h12km.T0;
P0 = motore.freestream.h12km.P0;

% 2 - uscita presa / ingresso compressore
T2 = motore.presaAria.T2;
P2 = motore.presaAria.P2;

% 3 - uscita compressore
M3 = motore.compressore.mach3;
T3 = motore.compressore.T03/(1 + (gammaA-1)/2*M3^2);
P3 = motore.compressore.P03/(1 + (gammaA-1)/2*M3^2)^(gammaA/(gammaA-1));

% 3.5 - uscita diffusore / ingresso camera
M35 = motore.diffusore.mach35;
T35 = motore.diffusore.T035/(1 + (gammaA-1)/2*M35^2);
P35 = motore.diffusore.P035/(1 + (gammaA-1)/2*M35^2)^(gammaA/(gammaA-1));

% 4 - uscita camera / ingresso turbina
M4 = motore.turbina.mach4;
T4 = motore.camera.T04/(1 + (gammaG-1)/2*M4^2);
P4 = motore.camera.P04/(1 + (gammaG-1)/2*M4^2)^(gammaG/(gammaG-1));

% 5 - uscita turbina
M5 = motore.turbina.mach5;
T5 = motore.turbina.T05/(1 + (gammaG-1)/2*M5^2);
P5 = motore.turbina.P05/(1 + (gammaG-1)/2*M5^2)^(gammaG/(gammaG-1));

% 6 - uscita ugello
M6 = motore.ugello.mach6;
T6 = motore.ugello.T06/(1 + (gammaG-1)/2*M6^2);
P6 = motore.ugello.P06/(1 + (gammaG-1)/2*M6^2)^(gammaG/(gammaG-1));

%% Funzioni

entropiaAria = @(T,P,Tref,Pref,sref) ...
    sref + (cpA*log(T./Tref) - RA*log(P./Pref))/1000;

entropiaGas = @(T,P,Tref,Pref,sref) ...
    sref + (cpG*log(T./Tref) - RG*log(P./Pref))/1000;

poly_curve = @(Ti,Pi,Tf,Pf,N) deal( ...
    linspace(Pi,Pf,N), ...
    Ti*(linspace(Pi,Pf,N)/Pi).^(log(Tf/Ti)/log(Pf/Pi)) ); % Non rappresenta la vera trasformazione termodinamica
%                                                           ma una sua approssimazione usando una legge esponenziale

%% Entropie calcolate nei punti reali

s0 = 0;
s2  = entropiaAria(T2, P2, T0, P0, s0);
s3  = entropiaAria(T3, P3, T2, P2, s2);
s35 = entropiaAria(T35, P35, T3, P3, s3);

s4  = entropiaGas(T4, P4, T35, P35, s35);
s5  = entropiaGas(T5, P5, T4, P4, s4);
s6  = entropiaGas(T6, P6, T5, P5, s5);

%% Curve reali

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

%% Plot

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
labels = {'0','2','3','3.5','4','5','6'};

plot(s_points,T_points,'ko','MarkerFaceColor','w','LineWidth',1.2)

text(s0  -0.008 , T0  -30 , '0'  ,'FontSize',10)
text(s2  -0.008, T2  +30 , '2'  ,'FontSize',10)

text(s3  -0.008 , T3  +30 , '3'  ,'FontSize',10)
text(s35 +0.005 , T35 +30 , '3.5','FontSize',10)

text(s4  +0.006 , T4  +8  , '4'  ,'FontSize',10)
text(s5  +0.006 , T5  +8  , '5'  ,'FontSize',10)
text(s6  +0.006 , T6  +8  , '6'  ,'FontSize',10)

plot([s6 s0],[T6 T0], ...
    '--', ...
    'Color',[0.5 0.5 0.5], ...
    'LineWidth',1);

xlabel('$s-s_0$ [kJ/(kg K)]','Interpreter','latex')
ylabel('$T$ [K]','Interpreter','latex')
title('Diagramma $T-s$ reale del ciclo turbogetto','Interpreter','latex')

set(gca,'FontSize',11)
hold off

%%

[z, u]       = mycon(best_x, motoreBase);

turb = motore.turbina
cam = motore.camera
port = motore.portate
comp = motore.compressore
ug = motore.ugello
per = motore.performance

%% ANDAMENTO TSFC MINIMO PER OGNI RUN
figure
plot(1:n_runs, fHistory, 'o-')
xlabel('Run')
ylabel('TSFC minimo')
grid on

%% MIGLIOR VALORE PROGRESSIVO ( TSFC minore)
% Il grafico mostra il minimo cumulativo della funzione obiettivo
% ottenuto attraverso diverse run indipendenti del GA. Ogni run parte
% da un seed casuale differente, mentre il grafico tiene traccia della
% migliore soluzione trovata fino a quel momento.
figure
plot(1:n_runs, cummin(fHistory), 'o-')
xlabel('Run')
ylabel('Minor TSFC finora')
grid on


%% PLOT GRAFICI MOTORE

%% Pressioni totali lungo il motore

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


%% Temperature totali lungo il motore

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


%% Aree principali lungo il motore

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

%% VINCOLI
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


%% STAMPA RISULTATI A VIDEO
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

function X = lhs_sample(n, d)
    X = zeros(n, d);
    for j = 1:d
        X(:,j) = (randperm(n)' - rand(n,1)) / n;
    end
end
toc

function [ineq, eq] = mycon(x, motoreBase)
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
        motore.camera.LC - 1.8
        motore.performance.TSFC - 0.14

        
    ];
    eq = [ motore.performance.F - 25000 ];
end

save('turbogetto.mat', 'motore');

toc
% Optimization finished: average change in the fitness value less than options.FunctionTolerance and constraint violation is less than options.ConstraintTolerance.
% Switch2g to the hybrid optimization algorithm (FMINCON).
% FMINCON terminated.
%   fval = 0.1304
% Best fval across all runs: 0.1155
% 
% turb = 
% 
%   struct with fields:
% 
%               etaM: 0.9200
%               etaP: 0.9000
%     coolingStatore: [function_handle]
%      coolingRotore: [function_handle]
%           lTurbina: 2.6619e+07
%               etaN: 0.9218
%           etaNRaff: 0.9218
%              mach4: 0.3616
%                P04: 9.4001e+05
%                T04: 1.2756e+03
%               rho4: 2.4069
%                P05: 1.1446e+05
%                T05: 797.0996
%               rho5: 0.4508
%              mach5: 0.4605
%             T05Iso: 756.5234
%                 rp: 0.1218
%              TRaff: 763.5082
%                 A4: 0.0800
%                 A5: 0.4273
%                 h5: 0.0957
%                rt5: 0.7583
%                rh5: 0.6626
%                  U: 270.0026
%                  R: 0.2797
%            lStadio: 1.0436e+07
%             nStadi: 3
%            statore: [1×1 struct]
%             rotore: [1×1 struct]
% 
% 
% cam = 
% 
%   struct with fields:
% 
%               rMedio: 0.7104
%      perditaDinamica: 20
%     perditaPressione: 0.0600
%                    I: 80.0255
%                 etaB: 0.9800
%                 ARef: 0.2858
%                 hRef: 0.0640
%               ALiner: 0.1008
%                    V: 0.4332
%                   LC: 1.5160
%                 URef: 36.3427
%                 qRef: 3.0070e+03
%                 MRef: 0.0673
%                 tRes: 0.0127
%                    f: 0.0170
%                  T04: 1.2756e+03
%         mDotAirCalda: 16.6877
%        mDotAirFredda: 30.6035
%                  P04: 9.4001e+05
%                 QDot: 3.4672e+07
%                TComb: 2.3990e+03
%                  phi: 0.7301
% 
% 
% port = 
% 
%   struct with fields:
% 
%         mDot: 47.2911
%      mDotAir: 47.2911
%     mDotRaff: 0
%      mDotGas: 48.0934
%     mDotComb: 0.8022
% 
% 
% comp = 
% 
%   struct with fields:
% 
%          piC: 34.5608
%         etaP: 0.9000
%         Utip: 360.0035
%          U_m: 270.0026
%       hubTip: 0.5000
%          T03: 763.5082
%          P03: 1.0526e+06
%          L_c: 2.4490e+07
%         etaC: 0.8425
%      machRel: 0.9139
%     Mach_abs: 0.4016
%     CpStadio: 0.4659
%     deHaller: 0.7308
%           Va: 93.9793
%        beta1: -70.8086
%        beta2: -63.2701
%       rM2: 0.5418
%          h2: 0.3612
%       A3: 0.1063
%      rM3: 0.7104
%         hOut: 0.0238
%      DRotore: 0.4150
%     DStatore: 0.5175
%          RStadio: 0.8456
%          c_m: 0.0490
%          N_R: 70
%       NStadi: 23
%        mach3: 0.1702
% 
% 
% ug = 
% 
%   struct with fields:
% 
%      etaN: 0.9000
%       P06: 9.0469e+04
%       T06: 797.0996
%     mach6: 1.6833
%        Ue: 766.4462
%     AStar: 0.3049
%        AE: 0.4092
%        DE: 0.7218
% 
% 
% per = 
% 
%   struct with fields:
% 
%             F: 2.5000e+04
%     etaGlobal: 0.1772
%          TSFC: 0.1155
%       etaProp: 0.4961
%         etaTh: 0.3572
%           ISP: 528.6404
% 
% 
%           RISULTATI OTTIMIZZAZIONE            
% 
% --- PERFORMANCE ---
% Spinta            = 24999.999 N
% TSFC              = 0.115523547 kg/(N*h)
% eta globale       = 0.177
% 
% --- PRESA D'ARIA ---
% T02                  = 247.956 K
% P02                  = 30457.801 Pa
% Portata totale aria  = 47.291 kg/s
% A ingresso           = 0.6082 m^2
% A2                   = 1.2294 m^2
% CPR                  = 0.957
% 
% --- COMPRESSORE ---
% T03                        = 763.508 K
% P03                        = 1052645.364 Pa
% Rapporto compressione π_c  = 34.561
% L_c                        = 24.490 MW
% etaC                       = 0.842
% Utip compressore           = 360.003 m/s
% Mach ingresso compressore  = 0.300
% Mach relativo              = 0.914
% Mach assoluto              = 0.402
% Cp stadio                  = 0.466
% De Haller                  = 0.731
% D rotore                   = 0.415
% D statore                  = 0.517
% N stadi                    = 23
% N pale rotore              = 70
% rM2                     = 0.5418 m
% rM3                    = 0.7104 m
% h2                        = 0.3612 m
% hOut                       = 0.0238 m
% 
% --- DIFFUSORE ---
% T035      = 763.508 K
% P035      = 1000013.096 Pa
% Mach35    = 0.068
% A3        = 0.1063 m^2
% A35       = 0.2758 m^2
% LD        = 0.3263 m
% 
% --- CAMERA DI COMBUSTIONE ---
% T04               = 1275.630 K
% P04               = 940012.310 Pa
% f                 = 0.01696
% phi               = 0.730
% tRes              = 0.01266 s
% ARef              = 0.2858 m^2
% V camera          = 0.4332 m^3
% LC                = 1.5160 m
% 
% --- TURBINA ---
% T05               = 797.100 K
% P05               = 114458.495 Pa
% etaN              = 0.922
% n stadi           = 3
% A4                = 0.0800 m^2
% A5                = 0.4273 m^2
% 
% --- UGELLO ---
% Ue                = 766.446 m/s
% Mach uscita       = 1.683
% A*                = 0.30488 m^2
% Ae                = 0.40918 m^2
% De                = 0.7218 m
% 
% --- PORTATE ---
% mDot totale       = 47.2911 kg/s
% mDot aria camera  = 47.2911 kg/s
% mDot raffredd.    = 0.0000 kg/s
% mDot combustibile = 0.8022 kg/s
% mDot gas          = 48.0934 kg/s
% 
% --- CONTROLLO VINCOLI ---
% Max c             = -3.806646e-03
% Norm ceq          = 5.489963e-04
% Elapsed time is 2630.715187 seconds.
% Elapsed time is 2630.715257 seconds.
% Elapsed time is 2630.715275 seconds.
