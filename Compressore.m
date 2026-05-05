clear
clc


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


function [T0U, P0U, L_comp, eta_c, Mach_rel, Mach_abs, Cp_stadio, ...
          deHaller, Va, beta1, beta2, Ain, r_m_in, h_in, Aout, r_m_out, h_out] = ...
          compressore(T0I, P0I, mDot, pi_c, eta_p, U, N_stadi, machIn, hubTip, propFluidi)

    gamma = propFluidi.gamma;
    Rgas  = propFluidi.R;
    cp    = propFluidi.cp;

    eta_c = (pi_c^((gamma-1)/gamma) - 1) / ...
            (pi_c^((gamma-1)/(gamma*eta_p)) - 1);

    P0U = pi_c * P0I;

    T02s = T0I * pi_c^((gamma - 1)/gamma);
    T0U  = T0I + (T02s - T0I)/eta_c;

    l_comp = cp * (T0U - T0I);
    L_comp = mDot * l_comp;

    % Ingresso compressore
    T1 = T0I / (1 + (gamma - 1)/2 * machIn^2);
    P1 = P0I / (1 + (gamma - 1)/2 * machIn^2)^(gamma/(gamma - 1));
    rho1 = P1 / (Rgas * T1);

    a1 = sqrt(gamma * Rgas * T1);
    Va = machIn * a1;

    

    % Uscita compressore, assumendo Va costante
    T_out = T0U - Va^2/(2*cp);
    a_out = sqrt(gamma * Rgas * T_out);
    mach_out = Va / a_out;

    P_out = P0U / (1 + (gamma - 1)/2 * mach_out^2)^(gamma/(gamma - 1));
    rho_out = P_out / (Rgas * T_out);


    % Primo stadio
    l_stadio = l_comp / N_stadi;

    delta_Vt = l_stadio / U;

    Vt1 = 0;
    Vt2 = delta_Vt;

    V1 = sqrt(Va^2 + Vt1^2);
    V2 = sqrt(Va^2 + Vt2^2);

    Wt1 = Vt1 - U;
    Wt2 = Vt2 - U;

    W1 = sqrt(Va^2 + Wt1^2);
    W2 = sqrt(Va^2 + Wt2^2);

    Cp_stadio = 1 - (W2/W1)^2;
    deHaller  = W2/W1;

    beta1 = atan(Wt1/Va) * 180/pi;
    beta2 = atan(Wt2/Va) * 180/pi;

    Mach_abs = max([V1/a1, V2/a1]);
    Mach_rel = max([W1/a1, W2/a1]);

    % Geometria ingresso

    Ain = mDot / (rho1 * Va);
    r_t_in = sqrt(Ain/(pi*(1 - hubTip^2)));
    r_h_in = hubTip * r_t_in;
    r_m_in = (r_t_in + r_h_in)/2;
    h_in  = r_t_in - r_h_in;

    % Geometria uscita

    Aout = mDot / (rho_out * Va);
    r_t_out = sqrt(Aout/(pi*(1 - hubTip^2)));
    r_h_out = hubTip * r_t_out;
    r_m_out = (r_t_out + r_h_out)/2;
    h_out  = r_t_out - r_h_out;


end