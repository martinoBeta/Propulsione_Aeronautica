clc
clear 
close all

addpath("FunzioniMotore")
motore = structMotore();

%impostazione per latex
%% 
set(groot, ...
    'defaultTextInterpreter', 'latex', ...
    'defaultAxesTickLabelInterpreter', 'latex', ...
    'defaultLegendInterpreter', 'latex', ...
    'defaultColorbarTickLabelInterpreter', 'latex', ...
    'defaultAxesFontSize', 14, ...
    'defaultTextFontSize', 14, ...
    'defaultLegendFontSize', 14, ...
    'defaultAxesFontName', 'Latin Modern Roman');


% %%
% % calcolo portata necessaria per mach 0.85 e 25Kn di spinta
% rho_12000 = 0.31;
% mach = 0.85;
% R = 8314/29;
% gamma = 1.3;
% T_12000   = -56.5+273.15;
% v_exitstimata = 900;
% v_volo = mach * sqrt(R*gamma*T_12000);
% % Spinta = mdot(ve-v_volo)
% spinta = 25000;
% mdot = spinta/(v_exitstimata-v_volo);
% motore.portate.mDotAir = mdot;

%% ------------------------------------------------------------------------
%                               PRESA D'ARIA
%--------------------------------------------------------------------------
motore.presaAria.regime = "subsonico";


%% ANALISI 1: vario M2
M2_range = 0.25:0.01:0.55;
n = length(M2_range);

A2_vec = zeros(1,n);
CPR_vec = zeros(1,n);
P2_vec = zeros(1,n);
V2_vec = zeros(1,n);

for i = 1:n

    motore.presaAria.M2 = M2_range(i);

    motore = PresaDaria(motore);

    A2_vec(i) = motore.presaAria.A2;
    CPR_vec(i) = motore.presaAria.CPR;
    P2_vec(i) = motore.presaAria.P2;
    V2_vec(i) = motore.presaAria.V2;

end

figure

subplot(2,1,1)
plot(M2_range, A2_vec, 'LineWidth',1.5)
grid on
xlabel('M_2')
ylabel('A_2 [m^2]')
title('Area uscita presa / ingresso compressore')

subplot(2,1,2)
plot(M2_range, CPR_vec, 'LineWidth',1.5)
hold on
yline(0.6,'--r','Limite CPR = 0.6')
grid on
xlabel('M_2')
ylabel('CPR')
title('Pressure recovery statico')

%% ANALISI 2: vario M0
M0_range = 0.83:0.005:0.87;
n = length(M0_range);

A_cattura_vec = zeros(1,n);
A2_vec = zeros(1,n);
CPR_vec = zeros(1,n);
A_ingresso_vec = zeros(1,n);

for i = 1:n

    M0 = M0_range(i);

    motore.freestream.h12km.M0 = M0;
    motore.freestream.h12km.V0 = M0 * motore.freestream.h12km.a0;

    T0 = motore.freestream.h12km.T0;
    P0 = motore.freestream.h12km.P0;
    gamma = motore.fluidi.aria.gamma;

    motore.freestream.h12km.T00 = T0 * (1 + (gamma - 1)/2 * M0^2);
    motore.freestream.h12km.P00 = P0 * (1 + (gamma - 1)/2 * M0^2)^(gamma/(gamma - 1));

    motore = PresaDaria(motore);

    A_ingresso_vec(i) = motore.presaAria.A0;
    A2_vec(i) = motore.presaAria.A2;
    CPR_vec(i) = motore.presaAria.CPR;

end

figure

subplot(3,1,1)
plot(M0_range, A_ingresso_vec, 'LineWidth',1.5)
grid on
xlabel('M_0')
ylabel('A_{ingresso} [m^2]')
title('Area ingresso presa')

subplot(3,1,2)
plot(M0_range, A2_vec, 'LineWidth',1.5)
grid on
xlabel('M_0')
ylabel('A_2 [m^2]')
title('Area uscita presa')

subplot(3,1,3)
plot(M0_range, CPR_vec, 'LineWidth',1.5)
hold on
yline(0.6,'--r','Limite CPR = 0.6')
grid on
xlabel('M_0')
ylabel('CPR')
title('CPR al variare di M_0')



%% ANALISI PRESA 3: VARIO mDotAir


mDotAir_range = 25:1:50;
n = length(mDotAir_range);

A_ingresso_vec = zeros(1,n);
A2_vec = zeros(1,n);

for i = 1:n

    motore.portate.mDotAir = mDotAir_range(i);

    motore = PresaDaria(motore);

   
    A_ingresso_vec(i) = motore.presaAria.A0;
    A2_vec(i) = motore.presaAria.A2;

end

figure


plot(mDotAir_range, A_ingresso_vec,  'LineWidth',1.5)
hold on;
plot(mDotAir_range, A2_vec, 'LineWidth',1.5)
grid on
xlabel('\dot{m}_{air} [kg/s]')
ylabel('Area [m^2]')
legend('A_{ingresso}','A_2')
title('Aree presa al variare della portata aria')


%% ------------------------------------------------------------------------
%                                COMPRESSORE
%--------------------------------------------------------------------------
motore.compressore.piC = 12;
motore.portate.mDot = 0.35;
motore.presaAria.M2 = 0.35;


%% ANALISI 1: vario il rapporto di compressione
piC_range = 8:0.05:11;
n = length(piC_range);

% Inizializzazione vettori
T03_vec = zeros(1,n);
P03_vec = zeros(1,n);
etaC_vec = zeros(1,n);
L_vec = zeros(1,n);

machRel_vec = zeros(1,n);
Mach_abs_vec = zeros(1,n);
Cp_vec = zeros(1,n);
deHaller_vec = zeros(1,n);

Aout_vec = zeros(1,n);
NStadi_vec = zeros(1,n);

for i = 1:n

    motore.compressore.piC = piC_range(i);

    motore = Compressore(motore);

    T03_vec(i) = motore.compressore.T03;
    P03_vec(i) = motore.compressore.P03;
    etaC_vec(i) = motore.compressore.etaC;
    L_vec(i) = motore.compressore.LC;

    machRel_vec(i) = motore.compressore.machRel;
    Mach_abs_vec(i) = motore.compressore.MachAbs;
    Cp_vec(i) = motore.compressore.CpStadio;
    deHaller_vec(i) = motore.compressore.deHaller;

    Aout_vec(i) = motore.compressore.A3;
    NStadi_vec(i) = motore.compressore.NStadi;

end

figure
subplot(2,2,1)
plot(piC_range, T03_vec, 'LineWidth',1.5)
grid on
xlabel('\piC')
ylabel('T_{03} [K]')
title('Temperatura uscita compressore')

subplot(2,2,2)
plot(piC_range, L_vec/1e6, 'LineWidth',1.5)
grid on
xlabel('\piC')
ylabel('L_c [MW]')
title('Potenza compressore')

subplot(2,2,3)
plot(piC_range, etaC_vec, 'LineWidth',1.5)
grid on
xlabel('\piC')
ylabel('\etaC')
title('Rendimento compressore')

subplot(2,2,4)
plot(piC_range, NStadi_vec, 'LineWidth',1.5)
grid on
xlabel('\piC')
ylabel('N_{stadi}')
title('Numero di stadi calcolato')

figure
subplot(3,1,1)
plot(piC_range, machRel_vec, 'LineWidth',1.5)
hold on
plot(piC_range, Mach_abs_vec, 'LineWidth',1.5)
yline(1,'--r','Limite Mach relativo = 1')
grid on
xlabel('\piC')
ylabel('Mach')
legend('Mach relativo','Mach assoluto','Limite')
title('Mach nello stadio')

subplot(3,1,2)
plot(piC_range, Cp_vec, 'LineWidth',1.5)
hold on
yline(0.5,'--r','Limite Cp_R = 0.5')
grid on
xlabel('\piC')
ylabel('Cp_R')
title('Coefficiente di pressione rotore')

subplot(3,1,3)
plot(piC_range, deHaller_vec, 'LineWidth',1.5)
hold on
yline(0.72,'--r','Limite De Haller')
grid on
xlabel('\piC')
ylabel('W_2/W_1')
title('Criterio di De Haller')

figure
plot(piC_range, Aout_vec, 'LineWidth',1.5)
grid on
xlabel('\piC')
ylabel('A_{out,c} [m^2]')
title('Sezione uscita compressore')

%% ANALISI 2: VARIO U

motore.presaAria.M2 = 0.35;
motore.compressore.piC = 9;

Utip_range = 390:1:410;
n = length(Utip_range);

machRel_vec = zeros(1,n);
Mach_abs_vec = zeros(1,n);

beta1_vec = zeros(1,n);
beta2_vec = zeros(1,n);

Cp_vec = zeros(1,n);
deHaller_vec = zeros(1,n);

NStadi_vec = zeros(1,n);

RStadio_vec = zeros(1,n);

DRotore_vec = zeros(1,n);
DStatore_vec = zeros(1,n);

for i = 1:n

    motore.compressore.Utip = Utip_range(i);

    motore = Compressore(motore);

    machRel_vec(i) = motore.compressore.machRel;
    Mach_abs_vec(i) = motore.compressore.MachAbs;

    beta1_vec(i) = motore.compressore.beta1;
    beta2_vec(i) = motore.compressore.beta2;

    Cp_vec(i) = motore.compressore.CpStadio;
    deHaller_vec(i) = motore.compressore.deHaller;

    NStadi_vec(i) = motore.compressore.NStadi;

    RStadio_vec(i) = motore.compressore.RStadio;

    DRotore_vec(i) = motore.compressore.DRotore;
    DStatore_vec(i) = motore.compressore.DStatore;

end

figure

subplot(2,2,1)
plot(Utip_range, machRel_vec, 'LineWidth',1.5)
hold on
yline(1,'--r','Limite Mach = 1')
grid on
xlabel('U_{tip} [m/s]')
ylabel('Mach relativo')
title('Mach relativo al variare di U_{tip}')

subplot(2,2,2)
plot(Utip_range, Cp_vec, 'LineWidth',1.5)
hold on
yline(0.5,'--r','Limite Cp_R = 0.5')
grid on
xlabel('U_{tip} [m/s]')
ylabel('Cp_R')
title('Cp rotore al variare di U_{tip}')

subplot(2,2,3)
plot(Utip_range, deHaller_vec, 'LineWidth',1.5)
hold on
yline(0.72,'--r','Limite De Haller')
grid on
xlabel('U_{tip} [m/s]')
ylabel('W_2/W_1')
title('De Haller al variare di U_{tip}')

subplot(2,2,4)
plot(Utip_range, NStadi_vec, 'LineWidth',1.5)
grid on
xlabel('U_{tip} [m/s]')
ylabel('N_{stadi}')
title('Numero di stadi al variare di U_{tip}')

figure

subplot(3,1,1)
plot(Utip_range, RStadio_vec, 'LineWidth',1.5)
grid on
xlabel('U_{tip} [m/s]')
ylabel('RStadio')
title('Grado di reazione')

subplot(3,1,2)
plot(Utip_range, DRotore_vec, 'LineWidth',1.5)
hold on
yline(0.6,'--r','Limite D_{rotore}')
grid on
xlabel('U_{tip} [m/s]')
ylabel('D_{rotore}')
title('Diffusion factor rotore')

subplot(3,1,3)
plot(Utip_range, DStatore_vec, 'LineWidth',1.5)
hold on
yline(0.6,'--r','Limite D_{statore}')
grid on
xlabel('U_{tip} [m/s]')
ylabel('D_{statore}')
title('Diffusion factor statore')

%% ANALISI 3: VARIO MACH INGRESSO COMPRESSORE

motore.compressore.piC = 9;
motore.compressore.Utip = 350;

mach2_range = 0.20:0.01:0.60;
n = length(mach2_range);

A2_vec = zeros(1,n);

machRel_vec = zeros(1,n);
Mach_abs_vec = zeros(1,n);

Cp_vec = zeros(1,n);
deHaller_vec = zeros(1,n);

NStadi_vec = zeros(1,n);

RStadio_vec = zeros(1,n);

DRotore_vec = zeros(1,n);
DStatore_vec = zeros(1,n);

for i = 1:n

    motore.presaAria.M2 = mach2_range(i);

    motore = Compressore(motore);

    % Area ingresso compressore = uscita presa
    A2_vec(i) = motore.presaAria.A2;

    machRel_vec(i) = motore.compressore.machRel;
    Mach_abs_vec(i) = motore.compressore.MachAbs;

    Cp_vec(i) = motore.compressore.CpStadio;

    deHaller_vec(i) = motore.compressore.deHaller;

    NStadi_vec(i) = motore.compressore.NStadi;

    RStadio_vec(i) = motore.compressore.RStadio;

    DRotore_vec(i) = motore.compressore.DRotore;
    DStatore_vec(i) = motore.compressore.DStatore;

end

figure

subplot(2,2,1)
plot(mach2_range, A2_vec, 'LineWidth',1.5)
grid on
xlabel('M_2 ingresso compressore')
ylabel('A_2 [m^2]')
title('Area ingresso compressore')

subplot(2,2,2)
plot(mach2_range, machRel_vec, 'LineWidth',1.5)
hold on
yline(1,'--r','Limite Mach relativo = 1')
grid on
xlabel('M_2 ingresso compressore')
ylabel('Mach relativo')
title('Mach relativo al variare di M_2')

subplot(2,2,3)
plot(mach2_range, Cp_vec, 'LineWidth',1.5)
hold on
yline(0.5,'--r','Limite Cp_R = 0.5')
grid on
xlabel('M_2 ingresso compressore')
ylabel('Cp_R')
title('Cp rotore al variare di M_2')

subplot(2,2,4)
plot(mach2_range, NStadi_vec, 'LineWidth',1.5)
grid on
xlabel('M_2 ingresso compressore')
ylabel('N_{stadi}')
title('Numero di stadi al variare di M_2')

figure

subplot(3,1,1)
plot(mach2_range, deHaller_vec, 'LineWidth',1.5)
hold on
yline(0.72,'--r','Limite De Haller')
grid on
xlabel('M_2 ingresso compressore')
ylabel('W_2/W_1')
title('Criterio di De Haller')

subplot(3,1,2)
plot(mach2_range, DRotore_vec, 'LineWidth',1.5)
hold on
yline(0.6,'--r','Limite D_{rotore}')
grid on
xlabel('M_2 ingresso compressore')
ylabel('D_{rotore}')
title('Diffusion factor rotore')

subplot(3,1,3)
plot(mach2_range, DStatore_vec, 'LineWidth',1.5)
hold on
yline(0.6,'--r','Limite D_{statore}')
grid on
xlabel('M_2 ingresso compressore')
ylabel('D_{statore}')
title('Diffusion factor statore')
% 
% %% Ricerca configurazione ammissibile più compatta
% % questa ottimizzazione non va bene se vogliamo minimizzare il TSFC
% 
% FS = 0.99; % fattore di sicurezza
% 
% % Utip = 400;   troppo alto
% Utip_range = 340:5:400;
% 
% mach2_range = 0.20:0.01:0.45;
% piC_range   = 7:0.1:11;
% 
% best_NStadi = 100000;
% best_Ain     = 100000;
% 
% for Utip = Utip_range
% for mach2s = mach2_range
%     for piC = piC_range
% 
%         [T0U, P0U, lComp, etaC, machRel, Mach_abs, CpStadio, ...
%          deHaller, Va, beta1, beta2, Ain, rM2, h2, ...
%          Aout, rM3, hOut, DRotore, DStatore, RStadio, ...
%          c_m, N_R, NStadi] = ...
%             compressore(T0I, P0I, mDot, piC, etaP, Utip, ...
%                         mach2s, hubTip, propFluidi);
% 
%         if machRel < FS*1.0 && ...
%            CpStadio < FS*0.5 && ...
%            deHaller > 0.72/FS && ...
%            DRotore < FS*0.6 && ...
%            DStatore < FS*0.6
% 
%             nuovaSoluzione = false;
% 
%             if NStadi < best_NStadi
%                 nuovaSoluzione = true;
% 
%             elseif NStadi == best_NStadi && Ain < best_Ain
%                 nuovaSoluzione = true;
%             end
% 
%             if nuovaSoluzione
% 
%                 best_NStadi = NStadi;
%                 best_Ain = Ain;
% 
%                 best_mach2 = mach2s;
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
%                 best_DStatore = DStatore;
%                 best_RStadio = RStadio;
% 
%                 best_Va = Va;
%                 best_beta1 = beta1;
%                 best_beta2 = beta2;
% 
%                 best_Aout = Aout;
% 
%                 best_rM2 = rM2;
%                 best_h2 = h2;
% 
%                 best_rM3 = rM3;
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
% fprintf('\n=========== CONFIGURAZIONE COMPRESSORE COMPATTO ===========\n')
% fprintf('mach2    = %.2f\n', best_mach2)
% fprintf('Utip      = %.1f m/s\n', best_Utip)
% fprintf('NStadi   = %d\n', best_NStadi)
% fprintf('piC      = %.2f\n', best_piC)
% 
% fprintf('\n--- Vincoli ---\n')
% fprintf('Mach relativo = %.3f\n', best_machRel)
% fprintf('Cp stadio     = %.3f\n', best_Cp)
% fprintf('De Haller     = %.3f\n', best_deHaller)
% fprintf('D rotore      = %.3f\n', best_DRotore)
% fprintf('D statore     = %.3f\n', best_DStatore)
% fprintf('RStadio           = %.3f\n', best_RStadio)
% 
% fprintf('\n--- Prestazioni ---\n')
% fprintf('T0U      = %.2f K\n', best_T0U)
% fprintf('P0U      = %.2f Pa\n', best_P0U)
% fprintf('lComp   = %.2f MW\n', best_lComp/1e6)
% fprintf('etaC    = %.4f\n', best_etaC)
% 
% fprintf('\n--- Geometria ---\n')
% fprintf('Ain      = %.4f m^2\n', best_Ain)
% fprintf('Aout     = %.4f m^2\n', best_Aout)
% fprintf('h2     = %.4f m\n', best_h2)
% fprintf('hOut    = %.4f m\n', best_hOut)
% 
% fprintf('\n--- Primo stadio ---\n')
% fprintf('Corda c_m        = %.4f m\n', best_c_m)
% fprintf('Numero pale N_R  = %d\n', best_N_R)
% fprintf('-------------------------------------------------\n')

%% ------------------------------------------------------------------------
%                          CAMERA DI COMBUSTIONE
% -------------------------------------------------------------------------
% Parametri da PDF Politecnico di Milano e specifiche JP-7
propCombust.LHV = 44.1e6;       % JP-7 LHV [J/kg]
propCamera.I = 8;               % Intensità [MW/(m^3*bar)] (Slide 8) 
propCamera.RStadio = best_RStadio;      % Raggio medio dal compressore [cite: 138, 142]
propCamera.DP_su_qref = 20;     % Valore tipico camera Anulare (Slide 6) [cite: 114]
propCamera.DP_su_P3_target = 0.06; % Perdita 6% (Slide 6) [cite: 106, 114]

% Sweep sulla pressione d'ingresso (P03)
P03_vec = linspace(1e5, 10e5, 20); 
Lc_vec = zeros(size(P03_vec));
tres_vec = zeros(size(P03_vec));

for j = 1:length(P03_vec)
    % Nota: T03 deve essere best_T0U calcolato dal compressore
    % [P04_res, T04_res, Q_dot_res, cam_out, propCombust] = ...
    [P04, T04, Q_dot, propCamera, propCombust] = Camera_combustione( ...
    Motore, modo)
    Lc_vec(j) = cam_out.Lc;
    tres_vec(j) = cam_out.t_res;
end

% Visualizzazione Risultati
figure('Name', 'Analisi Camera di Combustione JP-7');
subplot(2,1,1);
plot(P03_vec/1e5, Lc_vec, 'LineWidth', 2);
ylabel('Lunghezza L_c [m]'); grid on; % [cite: 134, 139]
title('Dimensionamento Longitudinale');

subplot(2,1,2);
plot(P03_vec/1e5, tres_vec*1000, 'r', 'LineWidth', 2);
hold on; 
yline(8, '--k', 'Target JP-7 (8ms)'); % Limite stabilità JP-7
ylabel('Tempo residenza \tau_{res} [ms]'); 
xlabel('P_{03} [bar]'); grid on;


%% ------------------------------------------------------------------------
%                                 TURBINA
%--------------------------------------------------------------------------
addpath("FunzioniMotore")
% -----
% variazione della temperatura in ingresso
T0I = 1100:1:1800;

motoreBase = structMotore();

% in caso solo di errore dei codici precendenti
if (~exist('best_lComp', 'var'))
    motoreBase.compressore.L_c = 7000000;
    motoreBase.camera.P04 = 213000;
    motoreBase.compressore.T03 = 410;
    motoreBase.compressore.U_m = 400;

    motoreBase.turbina.mach4 = 0.3;
    motoreBase.turbina.rotore.wmachOut = 0.8;
    best_mach2 = 0.3;
    motoreBase.portate.mDot = 35;
    motoreBase.compressore.U_m = 350;
    motoreBase.compressore.rM3 = 0.4;
    motoreBase.compressore.T04 = 420;
    motoreBase.portate.mDotComb = 0.9;


else 
    motoreBase.compressore.L_c = best_lComp;
    motoreBase.turbina.mach4 = best_mach2;
    motoreBase.turbina.P04 = best_P0U;
    motoreBase.turbina.TRaff = best_T0U;
end


N = length(T0I);

% preallocazioni
etan = zeros(1,N);
coolPecentualeA = zeros(1,N);
P0Is = zeros(1,N);
P0Us = zeros(1,N);
T0Us_in = zeros(1,N);
T0Us = zeros(1,N);
spinta = zeros(1,N);
A4s = zeros(1,N);
A5s = zeros(1,N);
machOut = zeros(1,N);
sot = zeros(1,N);

for i = 1:N
    motore = motoreBase;
    motore.camera.T04 = T0I(i);
    motore = StimaSpillaggio(motore);
    motore = Turbina(motore);

    % Slavataggio 
    T = motore.turbina;
    port = motore.portate;

    etan(i) = T.etaN;
    coolPecentualeA(i) = port.mDotRaff/port.mDot;

    P0Us(i) = T.P05;
    P0Is(i) = T.P04;
    T0Us(i) = T.T05;
    T0Us_in(i) = T.T05Iso;

    A4s(i) = T.A4;
    A5s(i) = T.A5;
    machOut(i) = T.mach5;
    sot(i) = 2/(1.33+1)*T.T04;

    % [~, ~, ~, ~, ~, Ue, ~] = ugello(P0Us(i), T0Us(i), machOut(i), motore.mdot);
    % 
    % spinta(i) = motore.mdot * (Ue - v_volo);
end
%%
%Rendimento isoentropico
figure("name","rendimentoIsoentropicoTurbina");
nexttile();
title("rendimento isoentropico")
plot(T0I,etan);
title("Rendimento isoentropico")
xlabel("Temperatura gas in uscita camera di combustione $T_{04}$ [K]")
ylabel('$\eta_t$')
hold on
grid on
%%
figure('name','coolPercentagevsT04');
plot(T0I, coolPecentualeA * 100, T0I, T.coolingStatore(sot)*100,T0I, T.coolingRotore(sot)*100  );
hold on
grid on
ylabel("Aria spillata [%]")
xlabel("Temperatura gas in uscita camera di combustione $T_{04}$ [K]")
legend("Totale","Statore","Rotore");
%%
% Forza light mode solo per questa figura

%Rendimento al variare della percentuale di aria utilizzata per rafreddamento turbina
figure()
title("rendimento vs rafreddamento")
plot(coolPecentualeA*100,etos,"-");
title("Rendimento isoentropico vs aria spillata per rafreddamento")
xlabel("Temperatura gas in uscita camera di combustione $T_{04}$ [K]")
ylabel("$\eta_{\text{turbina}$")
grid on


% Pressioni Totali e Temperature totali
figure()
title("Pressione e Temperature totali")

yyaxis left
p1 = plot(T0I, P0Is, 'b-'); hold on
p2 = plot(T0I, P0Us, 'r-');
ylabel("pressure [Pa]")
ylim([min([P0Is,P0Us]) - 5000, max([P0Is,P0Us]) + 5000])

yyaxis right
t1 = plot(T0I, T0Us_in, 'g-'); hold on
t2 = plot(T0I, T0Us, 'k-');
ylabel("Temperature")
ylim([min([T0Us_in, T0Us]) - 50; max([T0Us_in, T0Us]) + 50])

grid on
xlabel("T04 (camera di combustione) [K]")

legend([p1 p2 t1 t2], ...
    "P0I","P0U","T0U iso","T0U");

%Area entrata e uscità
figure("Name","In e Out motore")
nexttile();
title("in e out aree")
plot(T0I,A4s)
hold on
plot(T0I,A5s)
grid on
xlabel("T04 (camera di combustione) [K]")
ylabel("area [m^2]")
legend("In","Out")

%mach
nexttile();
title("in e out mach")
plot(T0I,best_mach2*ones(size(T0I)))
hold on
plot(T0I,machOut)
grid on
xlabel("T04 (camera di combustione) [K]")
ylabel("mach]")
legend("In","Out")

%Spinta generata al variare della temperatura in camera. 
figure("name","spinta")
plot(T0I,spinta)
grid on
xlabel("T04 (camera di combustione) [K]")
ylabel("Spinta [N]")
yline(25000,'--r','Spinta minima = 25000N')

%% -----
% variazione mahc in ingresso
mach2s = 0.3:0.02:0.4;

motoreBase.turbina.T0I = 1400;

N = length(mach2s);
etan = zeros(1,N);
coolPecentualeA = zeros(1,N);
Sota = zeros(1,N);
etos = zeros(1,N);
P0Is = zeros(1,N);
P0Us = zeros(1,N);
T0Us_in = zeros(1,N);
T0Us = zeros(1,N);
spinta = zeros(1,N);
A4s = zeros(1,N);
A5s = zeros(1,N);
machOut = zeros(1,N);

for i = 1:N
    motore = motoreBase;
    motore.turbina.mach2 = mach2s(i);

    motore = turbina(propFluidi, motore);

    % Slavataggio 
    T = motore.turbina;

    etan(i) = T.eta_n;
    coolPecentualeA(i) = T.coolPecentuale;
    Sota(i) = T.SOT;
    etos(i) = T.eta_NC;

    P0Us(i) = T.P0U;
    P0Is(i) = T.P0I;
    T0Us(i) = T.T0U;
    T0Us_in(i) = T.T0U_iso;

    A4s(i) = T.AIn;
    A5s(i) = T.AOut;
    machOut(i) = T.machOut;

    [~, ~, ~, ~, ~, Ue, ~] = ugello(P0Us(i), T0Us(i), machOut(i), motore.mdot);

    spinta(i) = motore.mdot * (Ue - v_volo);
end




%Spinta generata al variare della temperatura in camera. 
figure("name","spinta")
plot(mach2s,spinta)
xlabel("mach2")
ylabel("Spinta [N]")
yline(25000,'--r','Spinta minima = 25000N')


figure("name","Turbina");
nexttile();
title("rendimento isoentropico")
plot(mach2s,etan);
title("Rendimento isoentropico")
xlabel("mach2")
ylabel("\eta_n")
hold on
plot(mach2s,etos);
legend("Isoentropico Raff","Isoentropico Non Raff")


%Area entrata e uscità
figure("Name","In e Out motore")
nexttile();
title("in e out aree")
plot(mach2s,A4s)
hold on
plot(mach2s,A5s)
xlabel("mach2")
ylabel("area [m^2]")
legend("In","Out")

%mach
nexttile();
title("in e out mach")
plot(mach2s,mach2s)
hold on
plot(mach2s,machOut)
xlabel("mach2")
ylabel("mach]")
legend("In","Out")

%% ------------------------------------------------------------------------
%                                 UGELLO
%--------------------------------------------------------------------------


clear
clc

%% Impostazioni Grafiche Avanzate (LaTeX & Font)
set(groot, ...
    'defaultTextInterpreter', 'latex', ...
    'defaultAxesTickLabelInterpreter', 'latex', ...
    'defaultLegendInterpreter', 'latex', ...
    'defaultColorbarTickLabelInterpreter', 'latex', ...
    'defaultAxesFontSize', 12, ...
    'defaultTextFontSize', 12, ...
    'defaultLegendFontSize', 10, ...
    'defaultAxesFontName', 'Latin Modern Roman');

% Caricamento strutture dati
parametri = structParametri();
motoreBase = structMotore();

% =========================================================================
% 1. STUDIO DELLA VARIAZIONE DI T04 (Temperatura Uscita Camera)
% =========================================================================
T0I = 1100:10:1800;
N_T = length(T0I);

% Allocazione vettori
rendG_T    = zeros(1, N_T);
rendP_T    = zeros(1, N_T);
rendTh_T   = zeros(1, N_T);
rendSt_T   = zeros(1, N_T);
spinta_T   = zeros(1, N_T);
tsfc_T     = zeros(1, N_T);
mfuel_T    = zeros(1, N_T);
rpTurb_T   = zeros(1, N_T);
ue_T       = zeros(1, N_T);

parametri(2) = 30; % Rapporto di compressione fisso (beta = 30)

for i = 1:N_T
    parametri(3) = T0I(i);
    [~, motore]  = runnerMotore(motoreBase, parametri);
    
    rendG_T(i)   = motore.performance.etaGlobal;
    rendP_T(i)   = motore.performance.etaProp;
    rendTh_T(i)  = motore.performance.etaTh;
    rendSt_T(i)  = motore.turbina.etaN;
    spinta_T(i)  = motore.performance.F;
    tsfc_T(i)    = motore.performance.TSFC;
    mfuel_T(i)   = motore.portate.mDotComb;
    rpTurb_T(i)  = motore.turbina.rp;
    ue_T(i)      = motore.ugello.Ue;
end

% GRAFICI: Effetto di T04
figure('Name', 'Analisi_Prestazioni_vs_T04');
tiledlayout(3, 3, 'TileSpacing', 'Compact', 'Padding', 'Compact');

% 1. Rendimenti Energetici (Doppio Asse)
nexttile;
yyaxis left
plot(T0I, rendG_T, 'k-', 'LineWidth', 1.8, 'DisplayName', '$\eta_g$ (Globale)'); hold on;
ylabel('$\eta_g$ [-]');
yyaxis right
plot(T0I, rendP_T, 'b-.', 'LineWidth', 1.5, 'DisplayName', '$\eta_p$ (Propulsivo)');
plot(T0I, rendTh_T, 'r--', 'LineWidth', 1.5, 'DisplayName', '$\eta_{th}$ (Termico)');
ylabel('$\eta_p$, $\eta_{th}$ [-]');
grid on; xlabel('$T_{04}$ [K]');
title('Rendimenti di Propulsione');
legend('Location', 'best');

% 2. Rendimento Isoentropico Turbina
nexttile;
plot(T0I, rendSt_T, 'm', 'LineWidth', 1.5);
grid on; xlabel('$T_{04}$ [K]'); ylabel('$\eta_t$ [-]');
title('Rendimento Turbina');

% 3. Espansione in Turbina (Nuovo)
nexttile;
plot(T0I, rpTurb_T, '-', 'Color', [0.4660, 0.6740, 0.1880], 'LineWidth', 1.5);
grid on; xlabel('$T_{04}$ [K]'); ylabel('$r_{p,t}$ ($P_{04}/P_{05}$) [-]');
title('Rapporto di Espansione Turbina');

% 4. Spinta Motore
nexttile;
plot(T0I, spinta_T, 'g', 'LineWidth', 1.5);
grid on; xlabel('$T_{04}$ [K]'); ylabel('Spinta $F$ [N]');
title('Spinta erogata');

% 5. Velocità di Efflusso Ugello (Nuovo)
nexttile;
plot(T0I, ue_T, 'Color', [0.8500, 0.3250, 0.0980], 'LineWidth', 1.5);
grid on; xlabel('$T_{04}$ [K]'); ylabel('$U_e$ [m/s]');
title('Velocità di Efflusso Ugello');

% 6. Consumo Specifico (TSFC)
nexttile;
plot(T0I, tsfc_T, 'c', 'LineWidth', 1.5);
grid on; xlabel('$T_{04}$ [K]'); ylabel('TSFC [kg/(N$\cdot$h)]');
title('Consumo Specifico (TSFC)');

% 7. Portata Combustibile
nexttile;
plot(T0I, mfuel_T, 'k', 'LineWidth', 1.5);
grid on; xlabel('$T_{04}$ [K]'); ylabel('\dot{m}_f [kg/s]');
title('Portata Combustibile');


%% =========================================================================
%% 2. STUDIO DELLA VARIAZIONE DEL RAPPORTO DI COMPRESSIONE (rp)
%% =========================================================================
rp = 4:2:30;
N_rp = length(rp);

% Allocazione vettori
rendG_rp   = zeros(1, N_rp);
rendP_rp   = zeros(1, N_rp);
rendTh_rp  = zeros(1, N_rp);
rendSt_rp  = zeros(1, N_rp);
spinta_rp  = zeros(1, N_rp);
tsfc_rp    = zeros(1, N_rp);
mfuel_rp   = zeros(1, N_rp);
rpTurb_rp  = zeros(1, N_rp);
ue_rp      = zeros(1, N_rp);

parametri(3) = 1500; % Temperatura T04 fissa (1500 K)

for i = 1:N_rp
    parametri(2) = rp(i);
    [~, motore]  = runnerMotore(motoreBase, parametri);
    
    rendG_rp(i)  = motore.performance.etaGlobal;
    rendP_rp(i)  = motore.performance.etaProp;
    rendTh_rp(i) = motore.performance.etaTh;
    rendSt_rp(i) = motore.turbina.etaN;
    spinta_rp(i) = motore.performance.F;
    tsfc_rp(i)   = motore.performance.TSFC;
    mfuel_rp(i)  = motore.portate.mDotComb;
    rpTurb_rp(i) = motore.turbina.rp;
    ue_rp(i)     = motore.ugello.Ue;
end

% GRAFICI: Effetto di rp ($\beta$)
figure('Name', 'Analisi_Prestazioni_vs_rp');
tiledlayout(3, 3, 'TileSpacing', 'Compact', 'Padding', 'Compact');

% 1. Rendimenti Energetici (Doppio Asse)
nexttile;
yyaxis left
plot(rp, rendG_rp, 'k-', 'LineWidth', 1.8, 'DisplayName', '$\eta_g$ (Globale)'); hold on;
ylabel('$\eta_g$ [-]');
yyaxis right
plot(rp, rendP_rp, 'b-.', 'LineWidth', 1.5, 'DisplayName', '$\eta_p$ (Propulsivo)');
plot(rp, rendTh_rp, 'r--', 'LineWidth', 1.5, 'DisplayName', '$\eta_{th}$ (Termico)');
ylabel('$\eta_p$, $\eta_{th}$ [-]');
grid on; xlabel('Rapporto di compressione $\beta$');
title('Rendimenti di Propulsione');
legend('Location', 'best');

% 2. Rendimento Isoentropico Turbina
nexttile;
plot(rp, rendSt_rp, 'm', 'LineWidth', 1.5);
grid on; xlabel('Rapporto di compressione $\beta$'); ylabel('$\eta_t$ [-]');
title('Rendimento Turbina');

% 3. Espansione in Turbina (Nuovo)
nexttile;
plot(rp, rpTurb_rp, '-', 'Color', [0.4660, 0.6740, 0.1880], 'LineWidth', 1.5);
grid on; xlabel('Rapporto di compressione $\beta$'); ylabel('$r_{p,t}$ ($P_{04}/P_{05}$) [-]');
title('Rapporto di Espansione Turbina');

% 4. Spinta Motore
nexttile;
plot(rp, spinta_rp, 'g', 'LineWidth', 1.5);
grid on; xlabel('Rapporto di compressione $\beta$'); ylabel('Spinta $F$ [N]');
title('Spinta erogata');

% 5. Velocità di Efflusso Ugello (Nuovo)
nexttile;
plot(rp, ue_rp, 'Color', [0.8500, 0.3250, 0.0980], 'LineWidth', 1.5);
grid on; xlabel('Rapporto di compressione $\beta$'); ylabel('$U_e$ [m/s]');
title('Velocità di Efflusso Ugello');

% 6. Consumo Specifico (TSFC)
nexttile;
plot(rp, tsfc_rp, 'c', 'LineWidth', 1.5);
grid on; xlabel('Rapporto di compressione $\beta$'); ylabel('TSFC [kg/(N$\cdot$h)]');
title('Consumo Specifico (TSFC)');

% 7. Portata Combustibile
nexttile;
plot(rp, mfuel_rp, 'k', 'LineWidth', 1.5);
grid on; xlabel('Rapporto di compressione $\beta$'); ylabel('\dot{m}_f [kg/s]');
title('Portata Combustibile');

%%
% comp = 0.08m a stadio
% turb = 0.147m a stadio


%% Studio parametrici della Turbina: Effetto dei numeri di Mach

% --- CONFIGURAZIONE E INPUT ---
machRotoreAlto  = 0.80:0.01:0.9;
mach2gressoTurbina = 0.30:0.01:0.4;
motoreBase = structMotore();
numSimulazioni = length(machRotoreAlto); 

% Preallocazione vettori per i risultati
etaStadio_alto   = zeros(1, numSimulazioni);
lavoroStadio_alto = zeros(1, numSimulazioni);
etaStadio_basso   = zeros(1, numSimulazioni);
lavoroStadio_basso = zeros(1, numSimulazioni);
gradoReazione_alto = zeros(1, numSimulazioni);
gradoReazione_basso = zeros(1, numSimulazioni);

parametri = structParametri();

motore = motoreBase; % Inizializzazione dal modello di partenza
motore.turbina.mach4 = 0.3; % Fisso il mach4 a un valore costante

for i = 1:numSimulazioni
    % Aggiorna il Mach di uscita del rotore per il punto i-esimo
    motore.turbina.rotore.wmachOut = machRotoreAlto(i);
    
    % Esecuzione del solutore del motore
    [~, motore] = runnerMotore(motore, parametri);
    
    % Estrazione e salvataggio dei risultati dello stadio
    etaStadio_alto(i)   = motore.turbina.etaStadio;
    lavoroStadio_alto(i) = motore.turbina.lStadio;
    gradoReazione_alto(i) = motore.turbina.R;
end

% --- SIMULAZIONE 2: Variazione Mach Ingresso Turbina (mach4) ---
% Reset del motore allo stato base per garantire l'indipendenza delle simulazioni
motore = motoreBase; 
% NOTA: Qui motore.turbina.rotore.wmachOut utilizzerà il valore di default di motoreBase

for i = 1:numSimulazioni
    % Aggiorna il Mach di ingresso alla turbina per il punto i-esimo
    motore.turbina.mach4 = mach2gressoTurbina(i);
    
    % Esecuzione del solutore del motore
    [~, motore] = runnerMotore(motore, parametri);
    
    % Estrazione e salvataggio dei risultati dello stadio
    etaStadio_basso(i)   = motore.turbina.etaStadio;
    lavoroStadio_basso(i) = motore.turbina.lStadio;
    gradoReazione_basso(i) = motore.turbina.R;
    
end

% --- GENERAZIONE GRAFICI ---
figure("Name", "Analisi Parametrica Turbina: Effetto Mach");

% Creazione di un layout a griglia (1 riga, 2 colonne)
% --- Grafico 1: Effetto del Mach di Ingresso ---
tiledlayout(1, 2); 
nexttile();
yyaxis left
plot(mach2gressoTurbina, etaStadio_basso, '-', 'LineWidth', 1.5);
ylabel('$\eta_{stadio}$', 'Interpreter', 'latex')
grid on;
hold on;

yyaxis right 
plot(mach2gressoTurbina, lavoroStadio_basso / 1e6, '-', 'LineWidth', 1.5); % Lavoro convertito in MW
ylabel('Lavoro $[MW]$', 'Interpreter', 'latex')
xlabel("Mach Ingresso Turbina ($Mach_4$)", 'Interpreter', 'latex')

% --- Grafico 2: Effetto del Mach del Rotore ---
nexttile();
yyaxis left
plot(machRotoreAlto, etaStadio_alto, '-', 'LineWidth', 1.5);
ylabel('$\eta_{stadio}$', 'Interpreter', 'latex')
grid on;
hold on;

yyaxis right 
plot(machRotoreAlto, lavoroStadio_alto / 1e6, '-', 'LineWidth', 1.5); % Lavoro convertito in MW
ylabel('Lavoro $[MW]$', 'Interpreter', 'latex')
xlabel("Mach Relativo Uscita Rotore ($w_{machOut}$)", 'Interpreter', 'latex')

% --- Grafico 3: Grado di reazione 
figure()
tiledlayout(1, 2); 
nexttile();
yyaxis left
plot(mach2gressoTurbina, gradoReazione_alto, '-', 'LineWidth', 1.5);
ylabel('$\eta_{stadio}$', 'Interpreter', 'latex')
grid on;
hold on;

% --- Grafico 2: Effetto del Mach del Rotore ---
nexttile();
yyaxis left
plot(machRotoreAlto, gradoReazione_basso, '-', 'LineWidth', 1.5);
ylabel('$\eta_{stadio}$', 'Interpreter', 'latex')
grid on;
hold on;

%% traingolozzi
figure('name', 'Statore/Rotore - vettori velocità')
nexttile
title('Statore')
quiver(0, 0, s.vz, s.vt, 0)        % v assoluta
hold on
quiver(0, 0, s.wz, s.wt, 0)        % w relativa
axis equal; grid on

quiver(0, 0, r.vz, r.vt, 0,'g')        % v assoluta
quiver(0, 0, r.wz, r.wt, 0)        % w relativa

quiver(r.wz, r.wt, 0, T.U, 0,'b')      % U tangenziale puro: punta w → punta v
quiver(s.wz, s.wt, 0, T.U, 0,'b')      % U tangenziale puro: punta w → punta v
legend("v2","w2","v3","w3","U")
xlabel("velocità assiale [m/s]")
ylabel("velocità radiale [m/s]")



% =========================================================================
% 1. RAMHET
% =========================================================================
clear
clc

%% Impostazioni Grafiche Avanzate (LaTeX & Font)
set(groot, ...
    'defaultTextInterpreter', 'latex', ...
    'defaultAxesTickLabelInterpreter', 'latex', ...
    'defaultLegendInterpreter', 'latex', ...
    'defaultColorbarTickLabelInterpreter', 'latex', ...
    'defaultAxesFontSize', 12, ...
    'defaultTextFontSize', 12, ...
    'defaultLegendFontSize', 10, ...
    'defaultAxesFontName', 'Latin Modern Roman');

% Caricamento strutture dati
parametri = [113, 1000];
motoreBase = structRamjet();

T0I = 1100:10:1800;
N_T = length(T0I);

% Allocazione vettori
rendG_T    = zeros(1, N_T);
rendP_T    = zeros(1, N_T);
rendTh_T   = zeros(1, N_T);
rendSt_T   = zeros(1, N_T);
spinta_T   = zeros(1, N_T);
tsfc_T     = zeros(1, N_T);
mfuel_T    = zeros(1, N_T);
rpTurb_T   = zeros(1, N_T);
ue_T       = zeros(1, N_T);


for i = 1:N_T
    parametri(2) = T0I(i);
    [~, motore]  = runnerRamjet(motoreBase, parametri);
    
    rendG_T(i)   = motore.performance.etaGlobal;
    rendP_T(i)   = motore.performance.etaProp;
    rendTh_T(i)  = motore.performance.etaTh;
    spinta_T(i)  = motore.performance.F;
    tsfc_T(i)    = motore.performance.TSFC;
    mfuel_T(i)   = motore.portate.mDotComb;
    ue_T(i)      = motore.ugello.Ue;
end

% GRAFICI: Effetto di T04
figure('Name', 'Analisi_Prestazioni_vs_T04');
tiledlayout(3, 3, 'TileSpacing', 'Compact', 'Padding', 'Compact');

% 1. Rendimenti Energetici (Doppio Asse)
nexttile;
yyaxis left
plot(T0I, rendG_T, 'k-', 'LineWidth', 1.8, 'DisplayName', '$\eta_g$ (Globale)'); hold on;
ylabel('$\eta_g$ [-]');
yyaxis right
plot(T0I, rendP_T, 'b-.', 'LineWidth', 1.5, 'DisplayName', '$\eta_p$ (Propulsivo)');
plot(T0I, rendTh_T, 'r--', 'LineWidth', 1.5, 'DisplayName', '$\eta_{th}$ (Termico)');
ylabel('$\eta_p$, $\eta_{th}$ [-]');
grid on; xlabel('$T_{04}$ [K]');
title('Rendimenti di Propulsione');
legend('Location', 'best');


% 4. Spinta Motore
nexttile;
plot(T0I, spinta_T, 'g', 'LineWidth', 1.5);
grid on; xlabel('$T_{04}$ [K]'); ylabel('Spinta $F$ [N]');
title('Spinta erogata');

% 5. Velocità di Efflusso Ugello (Nuovo)
nexttile;
plot(T0I, ue_T, 'Color', [0.8500, 0.3250, 0.0980], 'LineWidth', 1.5);
grid on; xlabel('$T_{04}$ [K]'); ylabel('$U_e$ [m/s]');
title('Velocità di Efflusso Ugello');

% 6. Consumo Specifico (TSFC)
nexttile;
plot(T0I, tsfc_T, 'c', 'LineWidth', 1.5);
grid on; xlabel('$T_{04}$ [K]'); ylabel('TSFC [kg/(N$\cdot$h)]');
title('Consumo Specifico (TSFC)');

% 7. Portata Combustibile
nexttile;
plot(T0I, mfuel_T, 'k', 'LineWidth', 1.5);
grid on; xlabel('$T_{04}$ [K]'); ylabel('\dot{m}_f [kg/s]');
title('Portata Combustibile');
