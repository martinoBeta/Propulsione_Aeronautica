function motore = PresaDaria(motore)

    regime = motore.presa.regime;

    if regime == "subsonico"


        %% PRESA SUBSONICA

        R = motore.fluidi.aria.R;
        gamma = motore.fluidi.aria.gamma;

        P0   = motore.freestream.h12km.P0;
        rho0 = motore.freestream.h12km.rho0;
        V0   = motore.freestream.h12km.V0;
        T00  = motore.freestream.h12km.T00;
        P00  = motore.freestream.h12km.P00;

        M2   = motore.presa.M2;
        pi_d = motore.presa.pi_d;

        mDotAir = motore.portate.mDotAir;

        T02 = T00;
        P02 = pi_d * P00;

        T2 = T02 / (1 + (gamma - 1)/2 * M2^2);

        P2 = P02 / (1 + (gamma - 1)/2 * M2^2)^ ...
             (gamma/(gamma - 1));

        rho2 = P2 / (R * T2);

        a2 = sqrt(gamma * R * T2);
        V2 = M2 * a2;

        A_ingresso = mDotAir / (rho0 * V0);

        A2 = mDotAir / (rho2 * V2);

        q0 = 0.5 * rho0 * V0^2;

        CPR = (P2 - P0) / q0;

        % OUTPUT
        motore.presa.T02 = T02;
        motore.presa.P02 = P02;

        motore.presa.T2 = T2;
        motore.presa.P2 = P2;

        motore.presa.rho2 = rho2;
        motore.presa.V2 = V2;

        motore.presa.A_ingresso = A_ingresso;
        motore.presa.A2 = A2;

        motore.presa.CPR = CPR;

    elseif regime == "supersonico"

        %% PRESA SUPERSONICA
    else

        error('Regime presa non valido')

    end

end