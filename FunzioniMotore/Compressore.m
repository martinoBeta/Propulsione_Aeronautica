function [motore] = Compressore(motore)

%% --------------------------------------------------------------------
%  LIMITI / VINCOLI DI PROGETTO COMPRESSORE

% Vincoli aerodinamici:
%   machRel    < 1
%   deHaller    > 0.72
%   CpStadio   < 0.5
%   DRotore    < 0.6
%   DStatore   < 0.6


% Vincoli geometrici indicativi larghi da imporre nell'ottimizzazione:
%   A2 / Ain_c      < 2.0 m^2      area ingresso compressore max
%   Aout_c          < 1.5 m^2      area uscita compressore max
%   r_m_in          < 1.2 m        raggio medio ingresso max
%   r_m_out         < 1.2 m        raggio medio uscita max
%   hIn            < 0.60 m       altezza pala ingresso max
%   hOut           < 0.45 m       altezza pala uscita max
%   hIn, hOut     > 0.02 m       altezza pala minima
%   NStadi         < 20           numero stadi massimo
%   N_R             < 180          numero pale rotoriche massimo
%
% Questi limiti non sono vincoli stringenti: servono solo
% a scartare configurazioni geometricamente non plausibili.
%% ------------------------------------------------------------------------




    % Inizializzazione
    T0I = motore.presaAria.T02;
    P0I = motore.presaAria.P02;
    piC = motore.compressore.piC;
    mDot = motore.portate.mDot;
    etaP = motore.compressore.etaP;
    Utip = motore.compressore.Utip; 
    machIn = motore.presaAria.M2;
    hubTip = motore.compressore.hubTip;

    gamma = motore.fluidi.aria.gamma;
    cp = motore.fluidi.aria.cp;
    Rgas = motore.fluidi.aria.R;

    etaC = (piC^((gamma-1)/gamma) - 1) / ...
            (piC^((gamma-1)/(gamma*etaP)) - 1);

    P0U = piC * P0I;

    T02s = T0I * piC^((gamma - 1)/gamma);
    T0U  = T0I + (T02s - T0I)/etaC;

    lComp = cp * (T0U - T0I);
    LComp = mDot * lComp;

    % Ingresso compressore
    T1 = T0I / (1 + (gamma - 1)/2 * machIn^2);
    P1 = P0I / (1 + (gamma - 1)/2 * machIn^2)^(gamma/(gamma - 1));
    rho1 = P1 / (Rgas * T1);

    a1 = sqrt(gamma * Rgas * T1);
    Va = machIn * a1;

    % Geometria ingresso
    Ain = mDot / (rho1 * Va);
    r_TIn = sqrt(Ain/(pi*(1 - hubTip^2)));
    
    r_hIn = hubTip * r_TIn;
    r_m_in = (r_TIn + r_hIn)/2;
    hIn = r_TIn - r_hIn;

    % Fisso Utip e ricavo U alla sezione media
    omega = Utip / r_TIn;
    U = omega * r_m_in;

    % Uscita compressore
    TOut = T0U - Va^2/(2*cp);
    a_out = sqrt(gamma * Rgas * TOut);
    machOut = Va / a_out;

    P_out = P0U / (1 + (gamma - 1)/2 * machOut^2)^(gamma/(gamma - 1));
    rhoOut = P_out / (Rgas * TOut);

    % Geometria uscita
    Aout = mDot / (rhoOut * Va);

    r_TOut = sqrt(Aout/(pi*(1 - hubTip^2)));
    r_hOut = hubTip * r_TOut;
    r_m_out = (r_TOut + r_hOut)/2;
    hOut  = r_TOut - r_hOut;

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

    NStadi = ceil(LComp / l_stadio_teorico);

    % Ricalcolo triangolo con numero di stadi intero
    l_stadio = LComp / NStadi;

    Vt2 = Vt1 + l_stadio / U;

    V1 = sqrt(Va^2 + Vt1^2);
    V2 = sqrt(Va^2 + Vt2^2);

    Wt1 = Vt1 - U;
    Wt2 = Vt2 - U;

    W1 = sqrt(Va^2 + Wt1^2);
    W2 = sqrt(Va^2 + Wt2^2);

    CpStadio = 1 - (W2/W1)^2;
    deHaller  = W2/W1;

    beta1 = atan(Wt1/Va) * 180/pi;
    beta2 = atan(Wt2/Va) * 180/pi;

    Mach_abs = max([V1/a1, V2/a1]);
    machRel = max([W1/a1, W2/a1]);

    % Sezione media
    sigma_r = 1.0;
    sigma_s = 1.25;

    DRotore = 1 - W2/W1 + abs(Vt2 - Vt1)/(2*sigma_r*W1);
    DStatore = 1 - Va/V2 + abs(Vt2 - Vt1)/(2*sigma_s*V2);

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
    motore.compressore.L_c = LComp;
    motore.compressore.etaC = etaC;
    motore.compressore.machRel = machRel;
    motore.compressore.Mach_abs = Mach_abs;
    motore.compressore.CpStadio = CpStadio;
    motore.compressore.deHaller = deHaller;
    motore.compressore.Va = Va;
    motore.compressore.beta1 = beta1;
    motore.compressore.beta2 = beta2;

    %motore.compressore.Ain_c = Ain;

    motore.compressore.r_m_in = r_m_in;
    motore.compressore.hIn = hIn;
    motore.compressore.Aout_c = Aout;
    motore.compressore.r_m_out = r_m_out;
    motore.compressore.hOut = hOut;
    motore.compressore.DRotore = DRotore;
    motore.compressore.DStatore = DStatore;
    motore.compressore.R_m = R_m;
    motore.compressore.c_m = c_m;
    motore.compressore.N_R = N_R;
    motore.compressore.NStadi = NStadi;
    motore.compressore.U_m = U;
    motore.compressore.mach3 = machOut;




end