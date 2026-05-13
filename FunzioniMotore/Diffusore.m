function [motore] = Diffusore(motore)
% DIFFUSORE
% Svolge il calcolo del rallentamento del flusso tra compressore e camera.
% Calcola il recupero di pressione e le dimensioni geometriche del condotto.
    % 
    propDiffusore = motore.diffusore;

    propDiffusore.mach3 = motore.compressore.mach3;
    propDiffusore.T03 = motore.compressore.T03;
    propDiffusore.P03 = motore.compressore.P03;
    rMedio = motore.compressore.r_m_out;
    propDiffusore.rMedio = rMedio;
    %calcolo velcoità
    

    % 1. INIZIALIZZAZIONE VARIABILI DA STRUCT
    m_a     = motore.portate.mDotAir;      % Portata aria totale 
    R       = motore.fluidi.aria.R;         % Costante del gas 
    gamma   = motore.fluidi.aria.gamma;     % Rapporto calori specifici
    cp      = motore.fluidi.aria.cp;      % Calore specifico aria 

    pi_d    = propDiffusore.pi_d;   % Rendimento pneumatico diffusore 
    theta   = propDiffusore.theta;  % Angolo di apertura del diffusore
    mach3 =  propDiffusore.mach3;
    v35 = propDiffusore.vTargetCamera;
    T03 = propDiffusore.T03;
    P03 = propDiffusore.P03;
    % 2. CONDIZIONI TERMODINAMICHE D'USCITA
    % La temperatura totale rimane costante (scambio adiabatico, no lavoro)
    T035 = T03; 
    % La pressione totale diminuisce
    P035 = P03 * pi_d; 
    
    % 3. CALCOLO GEOMETRICO 
    % Sezione di ingresso (Area 1 - uscita compressore)
    T3 = T03 / (1 + (gamma-1)/2 * mach3^2); % Temperatura statica ingresso
    P3 = P03 / (1 + (gamma-1)/2 * mach3^2)^(gamma/(gamma-1)); % Pressione statica ingresso
    rho1 = P3 / (R * T3);
    v3 = mach3 * sqrt(gamma * R * T3);
    A3 = m_a / (rho1 * v3); 
    
    % Sezione di uscita 
    T35 = T035 - (v35^2 / (2 * cp)); % Temperatura statica uscita
    a2 = sqrt(gamma*R*T35);
    mach35 = v35/a2;
    P35 = P035 / (1 + (gamma-1)/2 * mach35^2)^(gamma/(gamma-1)); % Pressione statica uscita
    rho2 = P35 / (R * T35);
    A35 = m_a / (rho2 * v35); % Area uscita 
    
    % 4. LUNGHEZZA DEL DIFFUSORE
    % Calcolata in base all'angolo di apertura theta per evitare distacchi
    % Assumendo un diffusore anulare: Ain = 2*pi*rm*hin e Aout = 2*pi*rm*hout
    h3 = A3 / (2 * pi * rMedio);
    h35 = A35 / (2 * pi * rMedio);
    
    % Lunghezza assiale necessaria per l'espansione
    LD = (h35 - h3) / (2 * tand(theta));
    
    % Aggiornamento cose
    propDiffusore.T035 = T035;
    propDiffusore.P035 = P035;
    propDiffusore.mach35 = mach35;
    


    % 5. AGGIORNAMENTO DELLA STRUCT DI OUTPUT
    propDiffusore.A3  = A3;
    propDiffusore.A35 = A35;
    propDiffusore.h3  = h3;
    propDiffusore.h35 = h35;
    propDiffusore.LD   = LD;
    propDiffusore.v3 = v3;
    propDiffusore.v35 = v35;

    motore.diffusore = propDiffusore;
end