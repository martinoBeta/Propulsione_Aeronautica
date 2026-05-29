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

        mach2   = motore.presaAria.mach2;
        piD= motore.presaAria.piD;
        
        mDotAir = motore.portate.mDot;
       

        T02 = T00;
        P02 = piD * P00;

        T2 = T02 / (1 + (gamma - 1)/2 * mach2^2);

        P2 = P02 / (1 + (gamma - 1)/2 * mach2^2)^ ...
             (gamma/(gamma - 1));

        rho2 = P2 / (R * T2);

        a2 = sqrt(gamma * R * T2);
        V2 = mach2 * a2;

        A_ingresso = mDotAir / (rho0 * V0);

        A2 = mDotAir / (rho2 * V2);

        q0 = 0.5 * rho0 * V0^2;

        CPR = (P2 - P0) / q0;

        % OUTPUT
        motore.presaAria.A0 = A_ingresso;
        
        motore.presaAria.T02 = T02;
        motore.presaAria.P02 = P02;

        motore.presaAria.T2 = T2;
        motore.presaAria.P2 = P2;

        motore.presaAria.rho2 = rho2;
        motore.presaAria.V2 = V2;

        motore.presaAria.A0 = A_ingresso;
        motore.presaAria.A2 = A2;

        motore.presaAria.CPR = CPR;

    elseif regime == "supersonico"

        %% presaAria SUPERSONICA
        R = motore.fluidi.aria.R;
        gamma = motore.fluidi.aria.gamma;

        ramjet.freestream.h25km.T0   = T0;
        ramjet.freestream.h25km.P0   = P0;
        ramjet.freestream.h25km.T00  = T00;
        ramjet.freestream.h25km.P00  = P00;
        ramjet.freestream.h25km.rho0 = rho0;
        ramjet.freestream.h25km.M0   = M0;
        ramjet.freestream.h25km.V0   = V0;
        ramjet.freestream.h25km.a0   = a0;

        mach2   = motore.presaAria.mach2;
        piD = motore.presaAria.piD;

        mDotAir = ramjet.portate.mDot;

        
        
    else

        error('Regime presaAria non valido')

    end

end