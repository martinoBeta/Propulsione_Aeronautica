function [motore] = compressore(motore)

%% --------------------------------------------------------------------
%  LIMITI / VINCOLI DI PROGETTO COMPRESSORE

% Vincoli aerodinamici:
%   Mach_rel    < 1
%   deHaller    > 0.72
%   Cp_stadio   < 0.5
%   D_rotore    < 0.6
%   D_statore   < 0.6


% Vincoli geometrici indicativi larghi da imporre nell'ottimizzazione:
%   A2 / Ain_c      < 2.0 m^2      area ingresso compressore max
%   Aout_c          < 1.5 m^2      area uscita compressore max
%   r_m_in          < 1.2 m        raggio medio ingresso max
%   r_m_out         < 1.2 m        raggio medio uscita max
%   h_in            < 0.60 m       altezza pala ingresso max
%   h_out           < 0.45 m       altezza pala uscita max
%   h_in, h_out     > 0.02 m       altezza pala minima
%   N_stadi         < 20           numero stadi massimo
%   N_R             < 180          numero pale rotoriche massimo
%
% Questi limiti non sono vincoli stringenti: servono solo
% a scartare configurazioni geometricamente non plausibili.
%% ------------------------------------------------------------------------




    % Inizializzazione
    T0I = motore.presa.T02;
    P0I = motore.presa.P02;
    pi_c = motore.compressore.pi_c;
    mDot = motore.portate.mDotAir;
    eta_p = motore.compressore.eta_p;
    Utip = motore.compressore.Utip; 
    machIn = motore.presa.M2;
    hubTip = motore.compressore.hubTip;

    gamma = motore.fluidi.aria.gamma;
    cp = motore.fluidi.aria.cp;
    Rgas = motore.fluidi.aria.R;

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

    % Geometria ingresso
    Ain = mDot / (rho1 * Va);
    r_t_in = sqrt(Ain/(pi*(1 - hubTip^2)));
    
    r_h_in = hubTip * r_t_in;
    r_m_in = (r_t_in + r_h_in)/2;
    h_in = r_t_in - r_h_in;

    % Fisso Utip e ricavo U alla sezione media
    omega = Utip / r_t_in;
    U = omega * r_m_in;

    % Uscita compressore
    T_out = T0U - Va^2/(2*cp);
    a_out = sqrt(gamma * Rgas * T_out);
    mach_out = Va / a_out;

    P_out = P0U / (1 + (gamma - 1)/2 * mach_out^2)^(gamma/(gamma - 1));
    rho_out = P_out / (Rgas * T_out);

    % Geometria uscita
    Aout = mDot / (rho_out * Va);

    r_t_out = sqrt(Aout/(pi*(1 - hubTip^2)));
    r_h_out = hubTip * r_t_out;
    r_m_out = (r_t_out + r_h_out)/2;
    h_out  = r_t_out - r_h_out;

    % Primo stadio
    % Ipotesi: alpha1 = 0 --> Vt1 = 0
    Vt1 = 0;

    Wt1 = Vt1 - U;
    W1  = sqrt(Va^2 + Wt1^2); % velocità relativa all'ingresso dello stadio

    % Scelta progettuale: De Haller target
    deHaller_target = 0.72;

    W2_target = deHaller_target * W1;

    % Va = cost lungo lo stadio
    Wt2 = -sqrt(W2_target^2 - Va^2);
    Vt2 = Wt2 + U;

    l_stadio_teorico = U * (Vt2 - Vt1);

    N_stadi = ceil(l_comp / l_stadio_teorico);

    % Ricalcolo triangolo con numero di stadi intero
    l_stadio = l_comp / N_stadi;

    Vt2 = Vt1 + l_stadio / U;

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

    % Sezione media
    sigma_r = 1.0;
    sigma_s = 1.25;

    D_rotore = 1 - W2/W1 + abs(Vt2 - Vt1)/(2*sigma_r*W1);
    D_statore = 1 - Va/V2 + abs(Vt2 - Vt1)/(2*sigma_s*V2);

    R_m = 1 - (Vt1 + Vt2)/(2*U);

    % Numero di pale rotoriche
    Re_min = 300000;
    nu1 = 4.67e-5;

    c_m = Re_min * nu1 / W1;

    s_r = c_m / sigma_r;
    N_R = ceil(2*pi*r_m_in / s_r);

    % Salvataggio nella struct
    motore.compressore.T03 = T0U;
    motore.compressore.P03 = P0U;
    motore.compressore.L_c = L_comp;
    motore.compressore.eta_c = eta_c;
    motore.compressore.Mach_rel = Mach_rel;
    motore.compressore.Mach_abs = Mach_abs;
    motore.compressore.Cp_stadio = Cp_stadio;
    motore.compressore.deHaller = deHaller;
    motore.compressore.Va = Va;
    motore.compressore.beta1 = beta1;
    motore.compressore.beta2 = beta2;

    %motore.compressore.Ain_c = Ain;

    motore.compressore.r_m_in = r_m_in;
    motore.compressore.h_in = h_in;
    motore.compressore.Aout_c = Aout;
    motore.compressore.r_m_out = r_m_out;
    motore.compressore.h_out = h_out;
    motore.compressore.D_rotore = D_rotore;
    motore.compressore.D_statore = D_statore;
    motore.compressore.R_m = R_m;
    motore.compressore.c_m = c_m;
    motore.compressore.N_R = N_R;
    motore.compressore.N_stadi = N_stadi;
    motore.compressore.U_m = U;




end