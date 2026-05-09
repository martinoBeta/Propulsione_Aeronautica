function [T0U, P0U, L_comp, eta_c, Mach_rel, Mach_abs, Cp_stadio, ...
          deHaller, Va, beta1, beta2, Ain, r_m_in, h_in, Aout, r_m_out, h_out,...
          D_rotore, D_statore, R_m, c_m, N_R, N_stadi] = compressore(T0I, P0I, mDot, pi_c,...
          eta_p, Utip, machIn, hubTip, propFluidi)

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

    % Geometria ingresso
    Ain = mDot / (rho1 * Va);

    r_t_in = sqrt(Ain/(pi*(1 - hubTip^2)));
    r_h_in = hubTip * r_t_in;
    r_m_in = (r_t_in + r_h_in)/2;
    h_in  = r_t_in - r_h_in;

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

end