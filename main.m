clc
clear 
close all

addpath("FunzioniMotore")
motore = structMotore();

%impostazione per latex
set(groot, ...
    'defaultTextInterpreter', 'latex', ...
    'defaultAxesTickLabelInterpreter', 'latex', ...
    'defaultLegendInterpreter', 'latex', ...
    'defaultColorbarTickLabelInterpreter', 'latex', ...
    'defaultAxesFontSize', 14, ...
    'defaultTextFontSize', 14, ...
    'defaultLegendFontSize', 14);


%%
% calcolo portata necessaria per mach 0.85 e 25Kn di spinta
rho_12000 = 0.31;
mach = 0.85;
R = 8314/29;
gamma = 1.3;
T_12000   = -56.5+273.15;
v_exitstimata = 900;
v_volo = mach * sqrt(R*gamma*T_12000);
% Spinta = mdot(ve-v_volo)
spinta = 25000;
mdot = spinta/(v_exitstimata-v_volo);
motore.portate.mDotAir = mdot;

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

    A_ingresso_vec(i) = motore.presaAria.A_ingresso;
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

   
    A_ingresso_vec(i) = motore.presaAria.A_ingresso;
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

    motore = compressore(motore);

    T03_vec(i) = motore.compressore.T03;
    P03_vec(i) = motore.compressore.P03;
    etaC_vec(i) = motore.compressore.etaC;
    L_vec(i) = motore.compressore.L_c;

    machRel_vec(i) = motore.compressore.machRel;
    Mach_abs_vec(i) = motore.compressore.Mach_abs;
    Cp_vec(i) = motore.compressore.CpStadio;
    deHaller_vec(i) = motore.compressore.deHaller;

    Aout_vec(i) = motore.compressore.Aout_c;
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

R_m_vec = zeros(1,n);

DRotore_vec = zeros(1,n);
DStatore_vec = zeros(1,n);

for i = 1:n

    motore.compressore.Utip = Utip_range(i);

    motore = compressore(motore);

    machRel_vec(i) = motore.compressore.machRel;
    Mach_abs_vec(i) = motore.compressore.Mach_abs;

    beta1_vec(i) = motore.compressore.beta1;
    beta2_vec(i) = motore.compressore.beta2;

    Cp_vec(i) = motore.compressore.CpStadio;
    deHaller_vec(i) = motore.compressore.deHaller;

    NStadi_vec(i) = motore.compressore.NStadi;

    R_m_vec(i) = motore.compressore.R_m;

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
plot(Utip_range, R_m_vec, 'LineWidth',1.5)
grid on
xlabel('U_{tip} [m/s]')
ylabel('R_m')
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

machIn_range = 0.20:0.01:0.60;
n = length(machIn_range);

A2_vec = zeros(1,n);

machRel_vec = zeros(1,n);
Mach_abs_vec = zeros(1,n);

Cp_vec = zeros(1,n);
deHaller_vec = zeros(1,n);

NStadi_vec = zeros(1,n);

R_m_vec = zeros(1,n);

DRotore_vec = zeros(1,n);
DStatore_vec = zeros(1,n);

for i = 1:n

    motore.presaAria.M2 = machIn_range(i);

    motore = compressore(motore);

    % Area ingresso compressore = uscita presa
    A2_vec(i) = motore.presaAria.A2;

    machRel_vec(i) = motore.compressore.machRel;
    Mach_abs_vec(i) = motore.compressore.Mach_abs;

    Cp_vec(i) = motore.compressore.CpStadio;

    deHaller_vec(i) = motore.compressore.deHaller;

    NStadi_vec(i) = motore.compressore.NStadi;

    R_m_vec(i) = motore.compressore.R_m;

    DRotore_vec(i) = motore.compressore.DRotore;
    DStatore_vec(i) = motore.compressore.DStatore;

end

figure

subplot(2,2,1)
plot(machIn_range, A2_vec, 'LineWidth',1.5)
grid on
xlabel('M_2 ingresso compressore')
ylabel('A_2 [m^2]')
title('Area ingresso compressore')

subplot(2,2,2)
plot(machIn_range, machRel_vec, 'LineWidth',1.5)
hold on
yline(1,'--r','Limite Mach relativo = 1')
grid on
xlabel('M_2 ingresso compressore')
ylabel('Mach relativo')
title('Mach relativo al variare di M_2')

subplot(2,2,3)
plot(machIn_range, Cp_vec, 'LineWidth',1.5)
hold on
yline(0.5,'--r','Limite Cp_R = 0.5')
grid on
xlabel('M_2 ingresso compressore')
ylabel('Cp_R')
title('Cp rotore al variare di M_2')

subplot(2,2,4)
plot(machIn_range, NStadi_vec, 'LineWidth',1.5)
grid on
xlabel('M_2 ingresso compressore')
ylabel('N_{stadi}')
title('Numero di stadi al variare di M_2')

figure

subplot(3,1,1)
plot(machIn_range, deHaller_vec, 'LineWidth',1.5)
hold on
yline(0.72,'--r','Limite De Haller')
grid on
xlabel('M_2 ingresso compressore')
ylabel('W_2/W_1')
title('Criterio di De Haller')

subplot(3,1,2)
plot(machIn_range, DRotore_vec, 'LineWidth',1.5)
hold on
yline(0.6,'--r','Limite D_{rotore}')
grid on
xlabel('M_2 ingresso compressore')
ylabel('D_{rotore}')
title('Diffusion factor rotore')

subplot(3,1,3)
plot(machIn_range, DStatore_vec, 'LineWidth',1.5)
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
% machIn_range = 0.20:0.01:0.45;
% piC_range   = 7:0.1:11;
% 
% best_NStadi = 100000;
% best_Ain     = 100000;
% 
% for Utip = Utip_range
% for machIns = machIn_range
%     for piC = piC_range
% 
%         [T0U, P0U, lComp, etaC, machRel, Mach_abs, CpStadio, ...
%          deHaller, Va, beta1, beta2, Ain, r_m_in, hIn, ...
%          Aout, r_m_out, hOut, DRotore, DStatore, R_m, ...
%          c_m, N_R, NStadi] = ...
%             compressore(T0I, P0I, mDot, piC, etaP, Utip, ...
%                         machIns, hubTip, propFluidi);
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
% fprintf('\n=========== CONFIGURAZIONE COMPRESSORE COMPATTO ===========\n')
% fprintf('machIn    = %.2f\n', best_machIn)
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
% fprintf('R_m           = %.3f\n', best_R_m)
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
% fprintf('hIn     = %.4f m\n', best_hIn)
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
propCamera.r_m = best_R_m;      % Raggio medio dal compressore [cite: 138, 142]
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
T0I = 1100:25:1800;

motoreBase = structMotore();

% in caso solo di errore dei codici precendenti
if (~exist('best_lComp', 'var'))
    motoreBase.compressore.L_c = 7000000;
    motoreBase.camera.P04 = 213000;
    motoreBase.compressore.T03 = 410;
    motoreBase.compressore.U_m = 400;

    motoreBase.turbina.mach4 = 0.3;
    motoreBase.turbina.rotore.wmachOut = 0.8;
    best_machIn = 0.3;
    motoreBase.portate.mDot = 35;
    motoreBase.compressore.U_m = 350;
    motoreBase.compressore.r_m_out = 0.4;
    motoreBase.compressore.T04 = 420;
    motoreBase.portate.mDotComb = 0.9;


else 
    motoreBase.compressore.L_c = best_lComp;
    motoreBase.turbina.mach4 = best_machIn;
    motoreBase.turbina.P04 = best_P0U;
    motoreBase.turbina.TRaff = best_T0U;
end


N = length(T0I);

% preallocazioni
etan = zeros(1,N);
coolPecentualeA = zeros(1,N);
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
    motore.camera.T04 = T0I(i);
    motore = StimaSpillaggio(motore);
    motore = Turbina(motore);

    % Slavataggio 
    T = motore.turbina;
    port = motore.portate;

    etan(i) = T.etaN;
    coolPecentualeA(i) = port.mDotRaff/port.mDot;
    etos(i) = T.etaNRaff;

    P0Us(i) = T.P05;
    P0Is(i) = T.P04;
    T0Us(i) = T.T05;
    T0Us_in(i) = T.T05Iso;

    A4s(i) = T.A4;
    A5s(i) = T.A5;
    machOut(i) = T.mach5;

    % [~, ~, ~, ~, ~, Ue, ~] = ugello(P0Us(i), T0Us(i), machOut(i), motore.mdot);
    % 
    % spinta(i) = motore.mdot * (Ue - v_volo);
end
%%
%Rendimento isoentropico
figure("name","Turbina");
nexttile();
title("rendimento isoentropico")
plot(T0I,etan);
title("Rendimento isoentropico")
xlabel("T04 (camera di combustione) [K]")
ylabel("$\eta_n$")
hold on
plot(T0I,etos);
grid on
legend("Isoentropico Raff","Isoentropico Non Raff")

figure('name','coolPercentagevsT04');
plot(T0I, coolPecentualeA * 100);
hold on
grid on
ylabel("Aria raffreddamento [%]")
xlabel("T0I [K]")
legend("Totale");

% Forza light mode solo per questa figura

%Rendimento al variare della percentuale di aria utilizzata per rafreddamento turbina
figure()
title("rendimento vs rafreddamento")
plot(coolPecentualeA*100,etos,"-");
title("Rendimento isoentropico vs aria spillata per rafreddamento")
xlabel("Aria spillata per rafreddamento [%]")
ylabel("$\eta_n$")
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
plot(T0I,best_machIn*ones(size(T0I)))
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
machIns = 0.3:0.02:0.4;

motoreBase.turbina.T0I = 1400;

N = length(machIns);
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
    motore.turbina.machIn = machIns(i);

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
plot(machIns,spinta)
xlabel("machIN")
ylabel("Spinta [N]")
yline(25000,'--r','Spinta minima = 25000N')


figure("name","Turbina");
nexttile();
title("rendimento isoentropico")
plot(machIns,etan);
title("Rendimento isoentropico")
xlabel("machIN")
ylabel("\eta_n")
hold on
plot(machIns,etos);
legend("Isoentropico Raff","Isoentropico Non Raff")


%Area entrata e uscità
figure("Name","In e Out motore")
nexttile();
title("in e out aree")
plot(machIns,A4s)
hold on
plot(machIns,A5s)
xlabel("machIN")
ylabel("area [m^2]")
legend("In","Out")

%mach
nexttile();
title("in e out mach")
plot(machIns,machIns)
hold on
plot(machIns,machOut)
xlabel("machIN")
ylabel("mach]")
legend("In","Out")

%% ------------------------------------------------------------------------
%                                 UGELLO
%--------------------------------------------------------------------------


