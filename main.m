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

%% ------------------------------------------------------------------------
%                               COMPRESSORE
%--------------------------------------------------------------------------
propFluidi = structFluidi();
propMotore = structMotore(structTurbina());


% Caso base 

machIn = 0.35;
pi_c   = 12;
eta_p  = 0.9;
U     = 320;
N_stadi = 8;
mDot   = propMotore.mdot;

T0I = propFluidi.T00;
P0I = propFluidi.P00;
hubTip = 0.5;

%mDot_range = mDot_base * (0.8:0.05:1.2);


%% Analisis 1: vario pi_c

% Analisi 1: vario pi_c

%pi_c_range = 6:1:20; più grossolano
pi_c_range = 8:0.1:11;

n = length(pi_c_range);

T0U_vec = zeros(1,n);
eta_c_vec = zeros(1,n);
L_vec   = zeros(1,n);
Mach_rel_vec = zeros(1,n);
Mach_abs_vec = zeros(1,n);

Cp_vec = zeros(1,n);
deHaller_vec = zeros(1,n);

Ain_vec = zeros(1,n);
Aout_vec = zeros(1,n);

rm_in_vec = zeros(1,n);
h_in_vec  = zeros(1,n);

rm_out_vec = zeros(1,n);
h_out_vec  = zeros(1,n);

for i = 1:n

    pi_c = pi_c_range(i);

    [T0U, P0U, L_comp, eta_c, Mach_rel, Mach_abs, Cp_stadio, ...
     deHaller, Va, beta1, beta2, Ain, r_m_in, h_in, Aout, r_m_out, h_out] = ...
        compressore(T0I, P0I, mDot, pi_c, eta_p, U, N_stadi, machIn, hubTip, propFluidi);
    
    T0U_vec(i) = T0U;
    eta_c_vec(i) = eta_c;
    L_vec(i) = L_comp;

    Mach_rel_vec(i) = Mach_rel;
    Mach_abs_vec(i) = Mach_abs;

    Cp_vec(i) = Cp_stadio;
    deHaller_vec(i) = deHaller;

    Ain_vec(i) = Ain;
    Aout_vec(i) = Aout;

    rm_in_vec(i) = r_m_in;
    h_in_vec(i)  = h_in;

    rm_out_vec(i) = r_m_out;
    h_out_vec(i)  = h_out;

end

% Grafici

figure
plot(pi_c_range, T0U_vec, 'o-', 'LineWidth',1.5)
grid on
xlabel('\pi_c')
ylabel('T_{0U} [K]')
title('Temperatura uscita compressore')

figure
plot(pi_c_range, L_vec/1e6, 'o-', 'LineWidth',1.5)
grid on
xlabel('\pi_c')
ylabel('L_{comp} [MW]')
title('Potenza compressore')

figure
plot(pi_c_range, eta_c_vec, 'o-', 'LineWidth',1.5)
grid on
xlabel('\pi_c')
ylabel('\eta_c')
title('Rendimento globale compressore')

figure
plot(pi_c_range, Mach_rel_vec, 'o-', 'LineWidth',1.5)
hold on
plot(pi_c_range, Mach_abs_vec, 'o-', 'LineWidth',1.5)
grid on
xlabel('\pi_c')
ylabel('Mach')
legend('Mach relativo','Mach assoluto')
title('Mach nello stadio')

figure
plot(pi_c_range, Cp_vec, 'o-', 'LineWidth',1.5)
hold on
yline(0.5,'--r','Limite Cp_R = 0.5')
grid on
xlabel('\pi_c')
ylabel('Cp_R')
title('Coefficiente di pressione rotore')

figure
plot(pi_c_range, deHaller_vec, 'o-', 'LineWidth',1.5)
hold on
yline(0.72,'--r','Limite De Haller')
grid on
xlabel('\pi_c')
ylabel('W_2 / W_1')
title('Criterio di De Haller')

figure
plot(pi_c_range, Ain_vec, 'o-', 'LineWidth',1.5)
hold on
plot(pi_c_range, Aout_vec, 'o-', 'LineWidth',1.5)
grid on
xlabel('\pi_c')
ylabel('Area [m^2]')
legend('A_{in}','A_{out}')
title('Sezioni compressore')

%% Analisi 2: vario N_stadi

U = 290;
machIn = 0.30;

pi_c_base = 8.9;

N_range = 5:1:20;

n = length(N_range);

Cp_vec = zeros(1,n);
deHaller_vec = zeros(1,n);
Mach_rel_vec = zeros(1,n);

beta1_vec = zeros(1,n);
beta2_vec = zeros(1,n);

for i = 1:n

    N_stadi = N_range(i);

    [T0U, P0U, L_comp, eta_c, Mach_rel, Mach_abs, Cp_stadio, ...
     deHaller, Va, beta1, beta2, Ain, r_m_in, h_in, Aout, r_m_out, h_out] = ...
        compressore(T0I, P0I, mDot, pi_c_base, eta_p, U, N_stadi, machIn, hubTip, propFluidi);

    Cp_vec(i) = Cp_stadio;
    deHaller_vec(i) = deHaller;
    Mach_rel_vec(i) = Mach_rel;

    beta1_vec(i) = beta1;
    beta2_vec(i) = beta2;

end

% Grafici

figure
plot(N_range, Cp_vec, 'o-', 'LineWidth',1.5)
hold on
yline(0.5,'--r','Limite Cp_R = 0.5')
grid on
xlabel('N_{stadi}')
ylabel('Cp_R')
title('Carico aerodinamico rotore')

figure
plot(N_range, deHaller_vec, 'o-', 'LineWidth',1.5)
hold on
yline(0.72,'--r','Limite De Haller')
grid on
xlabel('N_{stadi}')
ylabel('W_2 / W_1')
title('Criterio di De Haller')

figure
plot(N_range, Mach_rel_vec, 'o-', 'LineWidth',1.5)
hold on
yline(1,'--r','Limite Mach = 1')
grid on
xlabel('N_{stadi}')
ylabel('Mach relativo')
title('Mach relativo nel rotore')

figure
plot(N_range, beta1_vec, 'o-', N_range, beta2_vec, 'o-', 'LineWidth',1.5)
grid on
xlabel('N_{stadi}')
ylabel('\beta [deg]')
legend('\beta_1','\beta_2')
title('Angoli relativi')



%% Analisi 3: vario U

U_range = 300:25:400;
n = length(U_range);

Mach_rel_vec = zeros(1,n);
Mach_abs_vec = zeros(1,n);
l_stadio_vec = zeros(1,n);
beta1_vec = zeros(1,n);
beta2_vec = zeros(1,n);
Cp_vec = zeros(1,n);
deHaller_vec = zeros(1,n);



for i = 1:n

    U = U_range(i);

    [T0U, P0U, L_comp, eta_c, Mach_rel, Mach_abs, Cp_stadio, ...
          deHaller, Va, beta1, beta2, Ain, r_m_in, h_in, Aout, r_m_out, h_out] = ...
        compressore(T0I, P0I, mDot, pi_c, eta_p, U, N_stadi, machIn, hubTip, propFluidi);

    Mach_rel_vec(i) = Mach_rel;
    Mach_abs_vec(i) = Mach_abs;

    % lavoro per stadio (ricavato fuori funzione)
    l_comp = propFluidi.cp * (T0U - T0I);
    l_stadio_vec(i) = l_comp / N_stadi;

    
    beta1_vec(i)  = beta1;
    beta2_vec(i)  = beta2;
    Cp_vec(i)     = Cp_stadio;
    deHaller_vec(i) = deHaller;

end


% Grafici

figure
plot(U_range, beta1_vec, 'o-', U_range, beta2_vec, 'o-', 'LineWidth',1.5)
grid on
xlabel('U [m/s]')
ylabel('\beta [deg]')
legend('\beta_1','\beta_2')
title('Angoli relativi al variare di U')

figure
plot(U_range, Cp_vec, 'o-', 'LineWidth',1.5)
hold on
yline(0.5,'--','Limite Cp rotore = 0.5')
grid on
xlabel('U [m/s]')
ylabel('Cp')
title('Coefficiente Cp al variare di U')

figure
plot(U_range, deHaller_vec, 'o-', 'LineWidth',1.5)
hold on
yline(0.72,'--r','Limite De Haller = 0.72')
grid on
xlabel('U [m/s]')
ylabel('W_2 / W_1')
title('Criterio di De Haller al variare di U')
legend('W_2/W_1','Limite')


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

for i = T0I
    [P0U, T0U, T05_iso, mach, L_turbina, eta_n,coolPecentuale,SOT,eto] = turbina(P0I,i, mach, L_compressore,propFluidi,propMotore,TCool);
    etan = [etan, eta_n];
    coolPecentualeA = [coolPecentualeA,coolPecentuale];
    Sota = [Sota, SOT];
    etos = [etos, eto];
    P0Us = [P0Us,P0U];
    P0Is = [P0Is,P0I];
    T0Us = [T0Us,T0U];
    T0Is = [T0Is,T05_iso];
    [P0U, T0U, mach1, Q, L, Ue, eta_n] = ugello(P0U,T0U, mach, propMotore.mdot);
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

%Spinta generata al variare della temperatura in camera. 
figure("name","spinta")
plot(T0I,spinta)
xlabel("T04 (camera di combustione) [K]")
ylabel("Spinta [N]")
yline(25000,'--r','Spinta minima = 25000N')




%% ------------------------------------------------------------------------
%                                 UGELLO
%--------------------------------------------------------------------------

