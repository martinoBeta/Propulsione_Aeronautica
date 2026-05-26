function motore = PresaDaria(motore)

    regime = motore.presaAria.regime;

    if regime == "subsonico"


        %% presaAria SUBSONICA

        R = motore.fluidi.aria.R;
        gamma = motore.fluidi.aria.gamma;

        P0   = motore.freestream.h12km.P0;
        rho0 = motore.freestream.h12km.rho0;
        V0   = motore.freestream.h12km.V0;
        T00  = motore.freestream.h12km.T00;
        P00  = motore.freestream.h12km.P00;

        M2   = motore.presaAria.M2;
        pi_d = motore.presaAria.pi_d;
        A_ingresso = motore.presaAria.A_ingresso;

       

        T02 = T00;
        P02 = pi_d * P00;

        T2 = T02 / (1 + (gamma - 1)/2 * M2^2);

        P2 = P02 / (1 + (gamma - 1)/2 * M2^2)^ ...
             (gamma/(gamma - 1));

        rho2 = P2 / (R * T2);

        a2 = sqrt(gamma * R * T2);
        V2 = M2 * a2;

        mDotAir = A_ingresso * (rho0 * V0);

        A2 = mDotAir / (rho2 * V2);

        q0 = 0.5 * rho0 * V0^2;

        CPR = (P2 - P0) / q0;

        % OUTPUT
        motore.portate.mDot = mDotAir;
        motore.presaAria.T02 = T02;
        motore.presaAria.P02 = P02;

        motore.presaAria.T2 = T2;
        motore.presaAria.P2 = P2;

        motore.presaAria.rho2 = rho2;
        motore.presaAria.V2 = V2;

        motore.presaAria.A_ingresso = A_ingresso;
        motore.presaAria.A2 = A2;

        motore.presaAria.CPR = CPR;

    elseif regime == "supersonico"

        %% presaAria SUPERSONICA
        R = motore.fluidi.aria.R;
        gamma = motore.fluidi.aria.gamma;

        P0   = motore.freestream.h25km.P0;
        rho0 = motore.freestream.h25km.rho0;
        V0   = motore.freestream.h25km.V0;
        T00  = motore.freestream.h25km.T00;
        P00  = motore.freestream.h25km.P00;

        M2   = motore.presaAria.M2;
        pi_d = motore.presaAria.pi_d;

        mDotAir = motore.portate.mDot;
        machOut = 0.7;

        motore.presaAria.machOut = machOut;
        % Calculate output parameters for supersonic regime
        T02 = T00; 
        P02 = pi_d * P00;

        % T2 = T02 / (1 + (gamma - 1)/2 * M2^2);
        % P2 = P02 / (1 + (gamma - 1)/2 * M2^2)^(gamma/(gamma - 1));
        % rho2 = P2 / (R * T2);
        % 
        % a2 = sqrt(gamma * R * T2);
        % V2 = M2 * a2;
        % 
        % A2 = mDotAir / (rho2 * V2);
        % q0 = 0.5 * rho0 * V0^2;
        % CPR = (P2 - P0) / q0;

        % OUTPUT
        motore.presaAria.T02 = T02;
        motore.presaAria.P02 = P02;
        % motore.presaAria.T2 = T2;
        % motore.presaAria.P2 = P2;
        % motore.presaAria.rho2 = rho2;
        % motore.presaAria.V2 = V2;
        % motore.presaAria.A2 = A2;
        % motore.presaAria.CPR = CPR;
        
    else

        error('Regime presaAria non valido')

    end

end