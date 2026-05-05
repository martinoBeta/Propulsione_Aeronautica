function [P04, T04, Q_dot, propCamera, propCombust] = Camera_di_combustione...
(P03_primo, T03_primo, propCamera, propFluidi, propCombust)
    % CAMERA_DI_COMBUSTIONE
    % Funzione che svolge ciclo termodinamico reale della camera di combustione
    % restituendo valori del flusso in usciita e caratteristiche geometrica per
    % il dimensionamento della camera.
    %
    % INPUT:
    % P03_primo : pressione totale dal dump diffuser
    % T03_primo : temperatura totale dal dump diffuser
    % structCamera : struct contenente i dati geometrici conosciuti della
    %                camera di combustione
    % structFluidi : struct contenente dati del fluido
    % structCombust : struct contenente i dati del combustibile
    % OUTPUT
    % P04 : pressione totale in uscita dalla camera di combustione
    % T04 : temperatura totale in uscita dalla camera di combustione
    % Q_dot : Calore liberato 
    % structCamera : struct contenente i dati geometrici della camera di
    %                combustione con anche quelli calcolati
    % structCombust : struct contenente i dati del combustibile
    
    % BILANCIO ENERGETICO
    % Calcolo del rapporto combustibile-aria e di conseguenza la portata di
    % combustibile:
    
    % 1. INIZIALIZZAZIONE VARIABILI DA STRUCT
    % Estrazione per evitare di scrivere propStruct.nome ogni volta
    LHV   = propFluidi.LHV;       % Potere Calorifico Inferiore
    eta_b = propMotore.eta_b;     % Rendimento di combustione 
    m_a   = propMotore.mAir;      % Portata aria ingresso camera
    T04   = propMotore.Tmax;      % Temperatura target uscita 
    
    cp_a  = propFluidi.cpOx;      % Calore specifico aria ingresso 
    cp_g  = propFluidi.cp;        % Calore specifico gas uscita 
    R     = propFluidi.R;         % Costante del gas 
    gamma = propFluidi.gamma;     % Rapporto calori specifici 
    
    r_m             = propCamera.r_m;       % Raggio medio 
    DP_su_qref      = propCamera.Dp_su_qref;% Fattore perdita dinamica 
    I               = propCamera.I;         % Intensità di combustione 
    DP_su_P3_target = 0.06;                 % Perdita di pressione target 
    
    % 2. BILANCIO ENERGETICO
    % Calcolo del rapporto combustibile-aria (f)
    f = (cp_g * T04 - cp_a * T03_primo) / (LHV * eta_b - cp_g * T04);
    m_f = f * m_a; % Portata combustibile 
    
    % Calcolo il calore liberato durante la combustione
    Q_dot = m_f * LHV * eta_b; 
    
    % 3. DIMENSIONAMENTO TRASVERSALE
    % Calcolo dell'Area di Riferimento (A_ref)
    termine_flusso = (m_a * sqrt(T03_primo)) / P03_primo;
    A_ref = sqrt( (R/2) * (termine_flusso^2) * (DP_su_qref / DP_su_P3_target) );
    
    % Calcolo dell'Altezza del Condotto (h_ref)
    h_ref = A_ref / (2 * pi * r_m);
    
    % Grandezze di Verifica
    rho3  = P03_primo / (R * T03_primo);
    U_ref = m_a / (rho3 * A_ref); % Velocità di riferimento
    q_ref = 0.5 * rho3 * U_ref^2; % Pressione dinamica rif.
    M_ref = U_ref / sqrt(gamma * R * T03_primo); % Mach rif.
    
    % 4. DIMENSIONAMENTO VOLUMETRICO E LONGITUDINALE
    % Calcolo del volume della camera di tipo anulare
    V = Q_dot / (I * P03_primo);
    
    % Ricavo la lunghezza della camera
    Lc = V / A_ref;
    
    % 5. CONDIZIONI DI USCITA
    % Pressione totale in uscita (P04)
    P04 = (1 - DP_su_P3_target) * P03_primo;
    
    % 6. AGGIORNAMENTO DELLE STRUCT DI OUTPUT
    % Aggiornamento combustibile
    propCombust.f = f;
    propCombust.m_f = m_f;
    
    % Aggiornamento camera
    propCamera.A_ref = A_ref;
    propCamera.h_ref = h_ref;
    propCamera.V     = V;
    propCamera.Lc    = Lc;
    propCamera.U_ref = U_ref;
    propCamera.q_ref = q_ref;
    propCamera.M_ref = M_ref;
end