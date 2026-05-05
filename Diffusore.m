function [P03_primo, T03_primo, propDiffusore] = Diffusore(P03, T03, propDiffusore, propFluidi, propMotore)
% DIFFUSORE
% Svolge il calcolo del rallentamento del flusso tra compressore e camera.
% Calcola il recupero di pressione e le dimensioni geometriche del condotto.

    % 1. INIZIALIZZAZIONE VARIABILI DA STRUCT
    m_a     = propMotore.mAir;      % Portata aria totale 
    R       = propFluidi.R;         % Costante del gas 
    gamma   = propFluidi.gamma;     % Rapporto calori specifici
    cp      = propFluidi.cpOx;      % Calore specifico aria 
    
    M_in    = propDiffusore.M_in;    % Mach ingresso 
    v2  = propDiffusore.v_target_camera;   % Mach uscita 
    pi_d    = propDiffusore.pi_d;   % Rendimento pneumatico diffusore 
    theta   = propDiffusore.theta;  % Angolo di apertura del diffusore
    
    % 2. CONDIZIONI TERMODINAMICHE D'USCITA
    % La temperatura totale rimane costante (scambio adiabatico, no lavoro)
    T03_primo = T03; 
    % La pressione totale diminuisce
    P03_primo = P03 * pi_d; 
    
    % 3. CALCOLO GEOMETRICO 
    % Sezione di ingresso (Area 1 - uscita compressore)
    T3 = T03 / (1 + (gamma-1)/2 * M_in^2); % Temperatura statica ingresso
    P3 = P03 / (1 + (gamma-1)/2 * M_in^2)^(gamma/(gamma-1)); % Pressione statica ingresso
    rho1 = P3 / (R * T3);
    v1 = M_in * sqrt(gamma * R * T3);
    A_in = m_a / (rho1 * v1); 
    
    % Sezione di uscita 
    T3_primo = T03_primo - (v2^2 / (2 * cp)); % Temperatura statica uscita
    a2 = sqrt(gamma*R*T3_primo);
    M_out = v2/a2;
    P3_primo = P03_primo / (1 + (gamma-1)/2 * M_out^2)^(gamma/(gamma-1)); % Pressione statica uscita
    rho2 = P3_primo / (R * T3_primo);
    v2 = M_out * sqrt(gamma * R * T3_primo);
    A_out = m_a / (rho2 * v2); % Area uscita 
    
    % 4. LUNGHEZZA DEL DIFFUSORE
    % Calcolata in base all'angolo di apertura theta per evitare distacchi
    % Assumendo un diffusore anulare: Ain = 2*pi*rm*hin e Aout = 2*pi*rm*hout
    rm = propDiffusore.rm; 
    h_in = A_in / (2 * pi * rm);
    h_out = A_out / (2 * pi * rm);
    
    % Lunghezza assiale necessaria per l'espansione
    LD = (h_out - h_in) / (2 * tand(theta));
    
    % 5. AGGIORNAMENTO DELLA STRUCT DI OUTPUT
    propDiffusore.Ain  = A_in;
    propDiffusore.Aout = A_out;
    propDiffusore.hin  = h_in;
    propDiffusore.hout = h_out;
    propDiffusore.LD   = LD;
    propDiffusore.v_in = v1;
    propDiffusore.v_out = v2;
end