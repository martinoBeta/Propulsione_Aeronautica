function [motore] = PresaDaria(motore)

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
        
        mDotAir = motore.portate.mDot;
       

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
        motore.presaAria.A_ingresso = A_ingresso;
        
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
        ramjet = motore;
        % Costanti 
        R = ramjet.fluidi.aria.R;
        gamma = ramjet.fluidi.aria.gamma;

        % Parametri aria ingresso  
        T00 = ramjet.freestream.h25km.T00;  
        P00 = ramjet.freestream.h25km.P00;  
        rho0 = ramjet.freestream.h25km.rho0; 
        M0 = ramjet.freestream.h25km.M0;   
        V0 = ramjet.freestream.h25km.V0;   
        mDot = ramjet.portate.mDot;
        
        %Parametri scelti
        delta1 = ramjet.presaAria.delta1;
        delta2 = ramjet.presaAria.delta2;
        theta1 = ramjet.presaAria.theta1;
        theta2 = ramjet.presaAria.theta2;

        % Calcolo valori dopo la prima onda d'urto obliqua:
        M0t = M0*cos(theta1);
        M0n = M0*sin(theta1);

        % utilizzo la relazione v0t = v1t, la velocità tangente prima e
        % dopo l'urto rimane costante:
        M1t = M0t*sqrt( ( (gamma+1)^2/(2*(gamma-1))*M0n^2 )/( (1+(gamma-1)/2*M0n^2)*(2*gamma/(gamma-1)*M0n^2-1) ) );
        M1n = sqrt( (M0n^2+2/(gamma-1))/(2*gamma/(gamma-1)*M0n^2-1) );
    
        M1 = sqrt( M1t^2 + M1n^2 );

        % Calcolo valori dopo la seconda onda d'urto obliqua:
        M1t_2 = M1*cos(theta2);
        M1n_2 = M1*sin(theta2);

        % utilizzo la relazione v0t = v1t, la velocità tangente prima e
        % dopo l'urto rimane costante:
        M2t = M1t_2*sqrt( ( (gamma+1)^2/(2*(gamma-1))*M1n_2^2 )/( (1+(gamma-1)/2*M1n_2^2)*(2*gamma/(gamma-1)*M1n_2^2-1) ) );
        M2n = sqrt( (M1n_2^2+2/(gamma-1))/(2*gamma/(gamma-1)*M1n_2^2-1) );
    
        M2 = sqrt( M2t^2 + M2n^2 );

        % Calcolo Mach dopo onda normale

        M3 = sqrt( (M2^2+2/(gamma-1))/(2*gamma/(gamma-1)*M2^2-1) );
        
        % Calcolo delle pressioni totali dopo ogni urto:
        % Funzione per il rapporto di pressione totale
        pr_total = @(Mn, g) ( ((g+1)/2 * Mn^2) / (1 + (g-1)/2 * Mn^2) )^(g/(g-1)) * ...
                            ( 1 / (2*g/(g+1) * Mn^2 - (g-1)/(g+1)) )^(1/(g-1));
        
        % Recupero dopo la prima onda
        pi_1 = pr_total(M0n, gamma); % rapporto di pressione
        P01 = P00 * pi_1; % pressione totale
        
        % Recupero dopo la seconda onda
        pi_2 = pr_total(M1n_2, gamma);
        P02 = P01 * pi_2;
        
        % Recupero dopo onda normale
        pi_3 = pr_total(M2, gamma);
        P03 = P02 * pi_3;

        % Recupero totale delle sole onde oblique
        piTot = P03/P00; 

        % Calcolo della temperatura e della densità: 
        % La temperatura totale rimane costante:
        T03 = T00;
        T3 = T03 / (1 + (gamma - 1) / 2 * M3^2);
        P3 = P03 / (1 + (gamma - 1) / 2 * M3^2)^(gamma/(gamma-1)); 
        rho3 = P3 / (R * T3);
        a3 = sqrt(rho3*R*T3);
        V3 = M3*a3;

        % Calcolo l'efficienza termodinamica, per una seconda
        % interpretazione dell'efficienza della presa oltre al recupero di
        % pressione:
        eta_d = ((piTot^((gamma-1)/gamma)) * (1 + (gamma-1)/2 * M0^2) - 1) / ((gamma-1)/2 * M0^2);

        % Dimensionamento della presa dinamica supersonica:
        ACatt = mDot/(rho0*V0);

        % Imponogo che la larghezza sia il doppio dell'altezza della mia
        % area di cattura che ha forma rettangolare, quindi W = 2H, 
        % A = W*H = 2*H^2;

        hCatt = sqrt( ACatt/2 ); % altezza area cattura
        wCatt = 2*hCatt; % larghezza area cattura
        LSuper = hCatt/tan(theta1); % lunghezza tratto supersonico
        LOnda1 = LSuper/cos(theta1); % lunghezza prima onda d'urto obliqua fino a Shock-Point
        LRampa12 = LOnda1*sin(theta2+delta1-theta1)/sin(pi-theta2); % lunghezza primo tratto di rampa tra 1^ e 2^ onda obliqua
        LOnda2 = LOnda1*sin(theta1-delta1)/sin(pi-theta2); % lunghezza seconda onda d'urto obliqua fino a Shock-Point
        LRampa23 = LOnda2*cos(theta2-delta2); % lunghezza rampa tra 2^ onda obliqua e onda normale 
        
        % Impongo i parametri di offset labbro e angolo di carenatura:
        deltaS = 0.1*LSuper;
        delta3 = deg2rad(4);

        % Ricavo i dati per la progettazione della gola:
        hGola = hCatt - LRampa12*sin(delta1) - LRampa23*sin(delta2);
        AGola = hGola * wCatt;

        ramjet.presaAria.T2         = T3;
        ramjet.presaAria.P2         = P3;
        ramjet.presaAria.T02        = T03;
        ramjet.presaAria.P02        = P03;
        ramjet.presaAria.M2         = M3;
        ramjet.presaAria.eta_d      = eta_d;
        ramjet.presaAria.rho2       = rho3;
        ramjet.presaAria.V2         = V3;
        ramjet.presaAria.CPR        = piTot;
        ramjet.presaAria.LSuper     = LSuper;
        ramjet.presaAria.LRampa12   = LRampa12;
        ramjet.presaAria.LRampa23   = LRampa23;
        ramjet.presaAria.hCatt      = hCatt;
        ramjet.presaAria.hGola      = hGola;
        ramjet.presaAria.ACatt      = ACatt;
        ramjet.presaAria.A2         = AGola;
        ramjet.presaAria.piTot      = piTot;
        ramjet.presaAria.eta_d      = eta_d;
        ramjet.presaAria.deltaS     = deltaS;
        ramjet.presaAria.delta3     = delta3;

        motore = ramjet;
    else

        error('Regime presaAria non valido')

    end

end