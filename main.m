clc
clear 
close all

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

%% ------------------------------------------------------------------------
%                               PRESA D'ARIA
%--------------------------------------------------------------------------

%IMPORTANTE
%il range di machIn è solo preliminare/fittizio.
% I valori reali di M1 ( raccolti nel vettore machIn_range) dovranno arrivare dal modello della presa dinamica
% variando la geometria della presa.


%% ------------------------------------------------------------------------
%                               COMPRESSORE
%--------------------------------------------------------------------------
propFluidi = structFluidi();
propMotore = structMotore(structTurbina());


machIn_range = 0.40:0.05:0.60;

propFluidi = structFluidi();
propMotore = structMotore(structTurbina());

mDot = propMotore.mdot;

T0I = propFluidi.T00;
P0I = propFluidi.P00;

eta_p  = 0.9;
hubTip = 0.5;

%% ANALISI 1: VARIO pi_c

machIn = 0.35;
Utip = 350;

pi_c_range = 8:0.05:11;
n = length(pi_c_range);

T0U_vec = zeros(1,n);
eta_c_vec = zeros(1,n);
L_vec = zeros(1,n);
Mach_rel_vec = zeros(1,n);
Mach_abs_vec = zeros(1,n);
Cp_vec = zeros(1,n);
deHaller_vec = zeros(1,n);
Ain_vec = zeros(1,n);
Aout_vec = zeros(1,n);
N_stadi_vec = zeros(1,n);

for i = 1:n

    pi_c = pi_c_range(i);

    [T0U, P0U, L_comp, eta_c, Mach_rel, Mach_abs, Cp_stadio, ...
     deHaller, Va, beta1, beta2, Ain, r_m_in, h_in, ...
     Aout, r_m_out, h_out, D_rotore, D_statore, R_m, ...
     c_m, N_R, N_stadi] = ...
        compressore(T0I, P0I, mDot, pi_c, eta_p, Utip, ...
                    machIn, hubTip, propFluidi);

    T0U_vec(i) = T0U;
    eta_c_vec(i) = eta_c;
    L_vec(i) = L_comp;
    Mach_rel_vec(i) = Mach_rel;
    Mach_abs_vec(i) = Mach_abs;
    Cp_vec(i) = Cp_stadio;
    deHaller_vec(i) = deHaller;
    Ain_vec(i) = Ain;
    Aout_vec(i) = Aout;
    N_stadi_vec(i) = N_stadi;

end

figure
subplot(2,2,1)
plot(pi_c_range, T0U_vec, 'LineWidth',1.5)
grid on
xlabel('\pi_c')
ylabel('T_{0U} [K]')
title('Temperatura uscita compressore')

subplot(2,2,2)
plot(pi_c_range, L_vec/1e6, 'LineWidth',1.5)
grid on
xlabel('\pi_c')
ylabel('L_{comp} [MW]')
title('Potenza compressore')

subplot(2,2,3)
plot(pi_c_range, eta_c_vec, 'LineWidth',1.5)
grid on
xlabel('\pi_c')
ylabel('\eta_c')
title('Rendimento compressore')

subplot(2,2,4)
plot(pi_c_range, N_stadi_vec, 'LineWidth',1.5)
grid on
xlabel('\pi_c')
ylabel('N_{stadi}')
title('Numero di stadi calcolato')

figure
subplot(3,1,1)
plot(pi_c_range, Mach_rel_vec, 'LineWidth',1.5)
hold on
plot(pi_c_range, Mach_abs_vec, 'LineWidth',1.5)
grid on
xlabel('\pi_c')
ylabel('Mach relativo')
title('Mach nello stadio')

subplot(3,1,2)
plot(pi_c_range, Cp_vec, 'LineWidth',1.5)
hold on
yline(0.5,'--r','Limite Cp_R = 0.5')
grid on
xlabel('\pi_c')
ylabel('Cp_R')
title('Coefficiente di pressione rotore')

subplot(3,1,3)
plot(pi_c_range, deHaller_vec, 'LineWidth',1.5)
hold on
yline(0.72,'--r','Limite De Haller')
grid on
xlabel('\pi_c')
ylabel('W_2/W_1')
title('Criterio di De Haller')

figure
plot(pi_c_range, Aout_vec, 'LineWidth',1.5)
grid on
xlabel('\pi_c')
ylabel('Area [m^2]')

title('Sezione uscita compressore')

%% ANALISI 2: VARIO U


machIn = 0.35;
pi_c = 9;

Utip_range = 390 : 1 : 410;
n = length(Utip_range);

Mach_rel_vec = zeros(1,n);
Mach_abs_vec = zeros(1,n);
beta1_vec = zeros(1,n);
beta2_vec = zeros(1,n);
Cp_vec = zeros(1,n);
deHaller_vec = zeros(1,n);
N_stadi_vec = zeros(1,n);

for i = 1:n

    Utip = Utip_range(i);

    [T0U, P0U, L_comp, eta_c, Mach_rel, Mach_abs, Cp_stadio, ...
     deHaller, Va, beta1, beta2, Ain, r_m_in, h_in, ...
     Aout, r_m_out, h_out, D_rotore, D_statore, R_m, ...
     c_m, N_R, N_stadi] = ...
        compressore(T0I, P0I, mDot, pi_c, eta_p, Utip, ...
                    machIn, hubTip, propFluidi);

    Mach_rel_vec(i) = Mach_rel;
    Mach_abs_vec(i) = Mach_abs;
    beta1_vec(i) = beta1;
    beta2_vec(i) = beta2;
    Cp_vec(i) = Cp_stadio;
    deHaller_vec(i) = deHaller;
    N_stadi_vec(i) = N_stadi;

end

figure
subplot(2,2,1)
plot(Utip_range, Mach_rel_vec, 'LineWidth',1.5)
hold on
yline(1,'--r','Limite Mach = 1')
grid on
xlabel('U [m/s]')
ylabel('Mach relativo')
title('Mach relativo al variare di U')

subplot(2,2,2)
plot(Utip_range, Cp_vec, 'LineWidth',1.5)
hold on
yline(0.5,'--r','Limite Cp_R = 0.5')
grid on
xlabel('U [m/s]')
ylabel('Cp_R')
title('Cp rotore al variare di U')

subplot(2,2,3)
plot(Utip_range, deHaller_vec, 'LineWidth',1.5)
hold on
yline(0.72,'--r','Limite De Haller')
grid on
xlabel('U [m/s]')
ylabel('W_2/W_1')
title('De Haller al variare di U')

subplot(2,2,4)
plot(Utip_range, N_stadi_vec, 'LineWidth',1.5)
grid on
xlabel('U [m/s]')
ylabel('N_{stadi}')
title('Numero di stadi al variare di U')

%% ANALISI 3: VARIO MACH INGRESSO COMPRESSORE

pi_c = 9;
Utip = 350;

machIn_range = 0.2:0.01:0.6;
n = length(machIn_range);

Ain_vec = zeros(1,n);
Mach_rel_vec = zeros(1,n);
Cp_vec = zeros(1,n);
deHaller_vec = zeros(1,n);
N_stadi_vec = zeros(1,n);

for i = 1:n

    machIn = machIn_range(i);

    [T0U, P0U, L_comp, eta_c, Mach_rel, Mach_abs, Cp_stadio, ...
     deHaller, Va, beta1, beta2, Ain, r_m_in, h_in, ...
     Aout, r_m_out, h_out, D_rotore, D_statore, R_m, ...
     c_m, N_R, N_stadi] = ...
        compressore(T0I, P0I, mDot, pi_c, eta_p, Utip, ...
                    machIn, hubTip, propFluidi);

    Ain_vec(i) = Ain;
    Mach_rel_vec(i) = Mach_rel;
    Cp_vec(i) = Cp_stadio;
    deHaller_vec(i) = deHaller;
    N_stadi_vec(i) = N_stadi;

end

figure
subplot(2,2,1)
plot(machIn_range, Ain_vec, 'LineWidth',1.5)
grid on
xlabel('M_1 ingresso compressore')
ylabel('A_{in} [m^2]')
title('Area ingresso al variare di M_1')

subplot(2,2,2)
plot(machIn_range, Mach_rel_vec, 'LineWidth',1.5)
hold on
yline(1,'--r','Limite Mach relativo = 1')
grid on
xlabel('M_1 ingresso compressore')
ylabel('Mach relativo')
title('Mach relativo al variare di M_1')

subplot(2,2,3)
plot(machIn_range, Cp_vec, 'LineWidth',1.5)
hold on
yline(0.5,'--r','Limite Cp_R = 0.5')
grid on
xlabel('M_1 ingresso compressore')
ylabel('Cp_R')
title('Cp rotore al variare di M_1')

subplot(2,2,4)
plot(machIn_range, N_stadi_vec, 'LineWidth',1.5)
grid on
xlabel('M_1 ingresso compressore')
ylabel('N_{stadi}')
title('Numero di stadi al variare di M_1')

%% Ricerca configurazione ammissibile più compatta
% voglio minimizzare le dimensioni del compressore

FS = 0.99; % fattore di sicurezza

% Utip = 400;   troppo alto
Utip_range = 340:5:400;

machIn_range = 0.20:0.01:0.45;
pi_c_range   = 7:0.1:11;

best_N_stadi = 100000;
best_Ain     = 100000;

for Utip = Utip_range
for machIn = machIn_range
    for pi_c = pi_c_range

        [T0U, P0U, L_comp, eta_c, Mach_rel, Mach_abs, Cp_stadio, ...
         deHaller, Va, beta1, beta2, Ain, r_m_in, h_in, ...
         Aout, r_m_out, h_out, D_rotore, D_statore, R_m, ...
         c_m, N_R, N_stadi] = ...
            compressore(T0I, P0I, mDot, pi_c, eta_p, Utip, ...
                        machIn, hubTip, propFluidi);

        if Mach_rel < FS*1.0 && ...
           Cp_stadio < FS*0.5 && ...
           deHaller > 0.72/FS && ...
           D_rotore < FS*0.6 && ...
           D_statore < FS*0.6

            nuovaSoluzione = false;

            if N_stadi < best_N_stadi
                nuovaSoluzione = true;

            elseif N_stadi == best_N_stadi && Ain < best_Ain
                nuovaSoluzione = true;
            end

            if nuovaSoluzione

                best_N_stadi = N_stadi;
                best_Ain = Ain;

                best_machIn = machIn;
                best_Utip = Utip;
                best_pi_c = pi_c;

                best_T0U = T0U;
                best_P0U = P0U;
                best_L_comp = L_comp;
                best_eta_c = eta_c;

                best_Mach_rel = Mach_rel;
                best_Mach_abs = Mach_abs;

                best_Cp = Cp_stadio;
                best_deHaller = deHaller;

                best_D_rotore = D_rotore;
                best_D_statore = D_statore;
                best_R_m = R_m;

                best_Va = Va;
                best_beta1 = beta1;
                best_beta2 = beta2;

                best_Aout = Aout;

                best_r_m_in = r_m_in;
                best_h_in = h_in;

                best_r_m_out = r_m_out;
                best_h_out = h_out;

                best_c_m = c_m;
                best_N_R = N_R;

            end
        end
    end
end
end

if best_N_stadi == 100000
    error('Nessuna configurazione valida trovata')
end

fprintf('\n=========== CONFIGURAZIONE OTTIMA COMPRESSORE ===========\n')
fprintf('machIn    = %.2f\n', best_machIn)
fprintf('Utip      = %.1f m/s\n', best_Utip)
fprintf('N_stadi   = %d\n', best_N_stadi)
fprintf('pi_c      = %.2f\n', best_pi_c)

fprintf('\n--- Vincoli ---\n')
fprintf('Mach relativo = %.3f\n', best_Mach_rel)
fprintf('Cp stadio     = %.3f\n', best_Cp)
fprintf('De Haller     = %.3f\n', best_deHaller)
fprintf('D rotore      = %.3f\n', best_D_rotore)
fprintf('D statore     = %.3f\n', best_D_statore)
fprintf('R_m           = %.3f\n', best_R_m)

fprintf('\n--- Prestazioni ---\n')
fprintf('T0U      = %.2f K\n', best_T0U)
fprintf('P0U      = %.2f Pa\n', best_P0U)
fprintf('L_comp   = %.2f MW\n', best_L_comp/1e6)
fprintf('eta_c    = %.4f\n', best_eta_c)

fprintf('\n--- Geometria ---\n')
fprintf('Ain      = %.4f m^2\n', best_Ain)
fprintf('Aout     = %.4f m^2\n', best_Aout)
fprintf('h_in     = %.4f m\n', best_h_in)
fprintf('h_out    = %.4f m\n', best_h_out)

fprintf('\n--- Primo stadio ---\n')
fprintf('Corda c_m        = %.4f m\n', best_c_m)
fprintf('Numero pale N_R  = %d\n', best_N_R)
fprintf('-------------------------------------------------\n')
%% ------------------------------------------------------------------------
%                          CAMERA DI COMBUSTIONE
% -------------------------------------------------------------------------

%% ------------------------------------------------------------------------
%                                 TURBINA
%--------------------------------------------------------------------------

P0I = 50000;
T0I = 1100:25:1800;
mach = 0.3;

propFluidi = structFluidi();%
propMotore = structMotore(structTurbina());
L_compressore = 10.7e6;
mach = 0.3;
P0I = 213400;
T3 = 420;
TCool = T3;
    
etan = [];
coolPecentualeA = [];
Sota = [];
etos = [];
P0Is = [];
P0Us = [];
T0Is = [];
T0Us = [];
spinta = [];
A4s = zeros(size(T0I));
A5s = zeros(size(T0I));
machOut = zeros(size(T0I));


for i = 1:length(T0I)
    [P0U, T0U, T05_iso, machOut(i), L_turbina, eta_n,coolPecentuale,SOT,eto,A4,A5] = turbina(P0I,T0I(i), mach, L_compressore,propFluidi,propMotore,TCool);
    etan = [etan, eta_n];
    coolPecentualeA = [coolPecentualeA,coolPecentuale];
    Sota = [Sota, SOT];
    etos = [etos, eto];
    P0Us = [P0Us,P0U];
    P0Is = [P0Is,P0I];
    T0Us = [T0Us,T0U];
    T0Is = [T0Is,T05_iso];
    A4s(i) = A4;
    A5s(i) = A5;
    [P0U, T0U, mach1, Q, L, Ue, eta_n] = ugello(P0U,T0U, machOut(i), propMotore.mdot);
    spinta = [spinta,propMotore.mdot*(Ue-v_volo)];
end 

%Rendimento isoentropico
figure("name","rendimento isoentropico");
plot(T0I,etan);
title("Rendimento isoentropico")
xlabel("T04 (camera di combustione) [K]")
ylabel("\eta_n")
hold on
plot(T0I,etos);
legend("Isoentropico Raff","Isoentropico Non Raff")

%Percentuale d'aria utilizzata per rafreddamento turbina
figure("name","aria rafreddamento tubina");
plot(T0I,coolPecentualeA*100);
hold on
plot(T0I,propMotore.Turbina.CoolingRotore(Sota)*100)
hold on
plot(T0I,propMotore.Turbina.CoolingStatore(Sota)*100)
legend("Totale","Rotore","Statore");
title("percentuale di aria spillata da compressore per rafreddamento turbina")
xlabel("T04 (camera di combustione) [K]")
ylabel("Aria spillata per rafreddamento [%]")

%Rendimento al variare della percentuale di aria utilizzata per rafreddamento turbina
figure("name","rendimento vs rafreddamento")
plot(coolPecentualeA*100,etos,"-");
title("Rendimento isoentropico vs aria spillata per rafreddamento")
xlabel("Aria spillata per rafreddamento [%]")
ylabel("\eta_n")

% Pressioni Totali e Temperature totali
figure("name","Pressione e Temperature totali")
yyaxis left
plot(T0I,P0Is,'b-');
hold on
plot(T0I,P0Us,'w-');
ylim([min(P0Us)-5000,max(P0Is)+5000]);
ylabel("pressure [Pa]")
yyaxis right
ylabel("Temperature")
plot(T0I,T0Is,'y-');
hold on
plot(T0I,T0Us,'r-');
ylim([min(T0Us)-50,max(T0I)+50]);
xlabel("T04 (camera di combustione) [K]");
legend("P0I",'P0U','T0U_iso','T0U');

%Area entrata e uscità
figure("Name","in e out aree")
plot(T0I,A4s)
hold on
plot(T0I,A5s)
xlabel("T04 (camera di combustione) [K]")
ylabel("area [m^2]")
legend("In","Out")

%mach
figure("Name","in e out mach")
plot(T0I,mach*ones(size(T0I)))
hold on
plot(T0I,machOut)
xlabel("T04 (camera di combustione) [K]")
ylabel("mach]")
legend("In","Out")

%Spinta generata al variare della temperatura in camera. 
figure("name","spinta")
plot(T0I,spinta)
xlabel("T04 (camera di combustione) [K]")
ylabel("Spinta [N]")
yline(25000,'--r','Spinta minima = 25000N')





%% ------------------------------------------------------------------------
%                                 UGELLO
%--------------------------------------------------------------------------

