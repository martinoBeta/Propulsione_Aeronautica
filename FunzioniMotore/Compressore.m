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
%   A3          < 1.5 m^2      area uscita compressore max
%   rM2          < 1.2 m        raggio medio ingresso max
%   rM3         < 1.2 m        raggio medio uscita max
%   h2            < 0.60 m       altezza pala ingresso max
%   h3           < 0.45 m       altezza pala uscita max
%   h2, h3     > 0.02 m       altezza pala minima
%   NStadi         < 20           numero stadi massimo
%   NPaleComp             < 180          numero pale rotoriche massimo
%
% Questi limiti non sono vincoli stringenti: servono solo
% a scartare configurazioni geometricamente non plausibili.
%% ------------------------------------------------------------------------




    % Inizializzazione
    T02 = motore.presaAria.T02;
    P02 = motore.presaAria.P02;
    piC = motore.compressore.piC;
    mDot = motore.portate.mDot;
    etaP = motore.compressore.etaP;
    Utip = motore.compressore.Utip; 
    mach2 = motore.presaAria.mach2;
    hubTip = motore.compressore.hubTip;

    gamma = motore.fluidi.aria.gamma;
    cp = motore.fluidi.aria.cp;
    Rgas = motore.fluidi.aria.R;

    etaC = (piC^((gamma-1)/gamma) - 1) / ...
            (piC^((gamma-1)/(gamma*etaP)) - 1);

    P03 = piC * P02;

    T03s = T02 * piC^((gamma - 1)/gamma);
    T03  = T02 + (T03s - T02)/etaC;

    lComp = cp * (T03 - T02);
    LComp = mDot * lComp;

    % Ingresso compressore
    T2 = T02 / (1 + (gamma - 1)/2 * mach2^2);
    P2 = P02 / (1 + (gamma - 1)/2 * mach2^2)^(gamma/(gamma - 1));
    rho2 = P2 / (Rgas * T2);

    a2 = sqrt(gamma * Rgas * T2);
    Va = mach2 * a2;

    % Geometria ingresso
    A2 = mDot / (rho2 * Va);
    rT2 = sqrt(A2/(pi*(1 - hubTip^2)));
    
    rH2 = hubTip * rT2;
    rM2 = (rT2 + rH2)/2;
    h2 = rT2 - rH2;

    % Fisso Utip e ricavo U alla sezione media
    omega = Utip / rT2;
    U = omega * rM2;

    % Uscita compressore
    T3 = T03 - Va^2/(2*cp);
    a3 = sqrt(gamma * Rgas * T3);
    mach3 = Va / a3;

    P3 = P03 / (1 + (gamma - 1)/2 * mach3^2)^(gamma/(gamma - 1));
    rho3 = P3 / (Rgas * T3);

    % Geometria uscita
    A3 = mDot / (rho3 * Va);

    % Rt costante
    rT3 = rT2;
    rH3 = sqrt(rT3^2 - A3/pi);
    h3  = rT3 - rH3;
    rM3 = (rT3 + rH3)/2;

    % Primo stadio
    % Ipotesi: alpha1 = 0 --> Vt1 = 0
    Vt1 = 0;

    Wt1 = Vt1 - U;
    W1  = sqrt(Va^2 + Wt1^2); % velocità relativa all'ingresso dello stadio

    % Scelta progettuale: De Haller target
    deHaller_target = 0.72;

    W2Target = deHaller_target * W1;

    % Va = cost lungo lo stadio
    Wt2 = -sqrt(W2Target^2 - Va^2);
    Vt2 = Wt2 + U;

    lStadioTeorico = U * (Vt2 - Vt1);

    NStadi = ceil(lComp / lStadioTeorico);

    % Ricalcolo triangolo con numero di stadi intero
    lStadio = lComp / NStadi;

    Vt2 = Vt1 + lStadio / U;

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

    machAbs = max([V1/a2, V2/a2]);
    machRel = max([W1/a2, W2/a2]);

    % Sezione media
    sigma_r = 1.0;
    sigma_s = 1.25;

    DRotore = 1 - W2/W1 + abs(Vt2 - Vt1)/(2*sigma_r*W1);
    DStatore = 1 - Va/V2 + abs(Vt2 - Vt1)/(2*sigma_s*V2);

    RStadio = 1 - (Vt1 + Vt2)/(2*U);

    % Numero di pale rotoriche
    ReMin = 300000;
    nu1 = 4.67e-5;

    c_m = ReMin * nu1 / W1;

    s_r = c_m / sigma_r;
    NPaleComp = ceil(2*pi*rM2 / s_r);

    % Salvataggio nella struct
    motore.compressore.T03 = T03;
    motore.compressore.P03 = P03;
    motore.compressore.LC = LComp;
    motore.compressore.etaC = etaC;
    motore.compressore.machRel = machRel;
    motore.compressore.MachAbs = machAbs;
    motore.compressore.CpStadio = CpStadio;
    motore.compressore.deHaller = deHaller;
    motore.compressore.Va = Va;
    motore.compressore.beta1 = beta1;
    motore.compressore.beta2 = beta2;

    %motore.compressore.Ain_c = Ain;

    motore.compressore.rM2 = rM2;
    motore.compressore.h2 = h2;
    motore.compressore.A3 = A3;
    motore.compressore.rM3 = rM3;
    motore.compressore.h3 = h3;
    motore.compressore.DRotore = DRotore;
    motore.compressore.DStatore = DStatore;
    motore.compressore.RStadio = RStadio;
    motore.compressore.c_m = c_m;
    motore.compressore.NPaleComp = NPaleComp;
    motore.compressore.NStadi = NStadi;
    motore.compressore.UM = U;
    motore.compressore.mach3 = mach3;




end