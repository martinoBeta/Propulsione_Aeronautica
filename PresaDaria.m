function motore = presa(motore)

   R = motore.fluidi.aria.R;
   gamma = motore.fluidi.aria.gamma;
   
    % Dati freestream
    P0   = motore.freestream.h12km.P0;
    rho0 = motore.freestream.h12km.rho0;
    V0   = motore.freestream.h12km.V0;
    T00  = motore.freestream.h12km.T00;
    P00  = motore.freestream.h12km.P00;

    % Dati presa
    M2    = motore.presa.M2;
    eta_d = motore.presa.eta_d;

    % Portata aria
    mDotAir = motore.portate.mDotAir;

    % Recupero pressione totale presa subsonica
    pi_d = motore.presa.pi_d;

    % Stazione 2: uscita presa / ingresso compressore
    T02 = T00;           % presa adiabatica
    P02 = pi_d * P00;   % perdita pressione totale

    % Condizioni statiche alla stazione 2
    T2 = T02 / (1 + (gamma - 1)/2 * M2^2);

    P2 = P02 / (1 + (gamma - 1)/2 * M2^2)^(gamma/(gamma - 1));

    rho2 = P2 / (R * T2);

    a2 = sqrt(gamma * R * T2);
    V2 = M2 * a2;

    % Area di cattura
    A_cattura = mDotAir / (rho0 * V0);

    % Area ingresso presa
    % Al punto di progetto subsonico: A_ingresso = A_cattura
    A_ingresso = A_cattura;

    % Area uscita presa = ingresso compressore
    A2 = mDotAir / (rho2 * V2);

    % Coefficiente di recupero pressione statica diffusore
    q0 = 0.5 * rho0 * V0^2;
    CPR = (P2 - P0) / q0;

    % Salvataggio nella struct
    motore.presa.pi_d = pi_d;

    motore.presa.T02 = T02;
    motore.presa.P02 = P02;

    motore.presa.T2 = T2;
    motore.presa.P2 = P2;
    motore.presa.rho2 = rho2;
    motore.presa.V2 = V2;

    motore.presa.A_cattura = A_cattura;
    motore.presa.A_ingresso = A_ingresso;
    motore.presa.A2 = A2;

    motore.presa.CPR = CPR;

end