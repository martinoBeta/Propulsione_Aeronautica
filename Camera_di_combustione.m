function [P04, T04, Q_dot, propCamera, propCombust] = Camera_di_combustione( ...
    P03_primo, T03_primo, propCamera, propFluidi, propMotore, propCombust)
% CAMERA_DI_COMBUSTIONE
% Funzione che svolge il ciclo termodinamico reale della camera di combustione,
% restituendo le condizioni termodinamiche in uscita e le caratteristiche
% geometriche per il dimensionamento della camera.
%
% INPUT:
%   P03_primo  : pressione totale in ingresso (dal dump diffuser) [Pa]
%   T03_primo  : temperatura totale in ingresso (dal dump diffuser) [K]
%   propCamera : struct con parametri geometrici noti della camera
%   propFluidi : struct con proprietà termodinamiche dei fluidi
%   propMotore : struct con parametri globali del motore        <<< AGGIUNTO
%   propCombust: struct con proprietà del combustibile
%
% OUTPUT:
%   P04        : pressione totale in uscita dalla camera [Pa]
%   T04        : temperatura totale in uscita dalla camera [K]
%   Q_dot      : calore liberato durante la combustione [W]
%   propCamera 
%   propCombust

  
    % 1. ESTRAZIONE VARIABILI DALLE STRUCT

    % Combustibile
    LHV   = propCombust.LHV;        % potere calorifico inferiore JP-7 [J/kg]

    % Motore
    eta_b = propMotore.eta_b;      % rendimento di combustione [-]
    m_a   = propMotore.mDotCore;   % portata aria che entra in camera [kg/s]
                                   % NOTA: si usa mDotCore (aria non spillata),
                                   % NON mAir totale né mdot
    T04   = propMotore.Tmax;       % temperatura target TIT in uscita camera [K]

    % Fluidi
    cp_a  = propFluidi.cpOx;       % cp aria in ingresso [J/(kg·K)]
    cp_g  = propFluidi.cp;         % cp gas combusti in uscita [J/(kg·K)]
    R     = propFluidi.R;          % costante del gas [J/(kg·K)]
    gamma = propFluidi.gamma;      % rapporto calori specifici gas combusti [-]

    % Camera
    r_m             = propCamera.r_m;             % raggio medio anulare [m]
    DP_su_qref      = propCamera.DP_su_qref;      % fattore perdita dinamica [-]
    DP_su_P3_target = propCamera.DP_su_P3_target; % perdita di pressione target [-]
    I               = propCamera.I;               % intensità di combustione [W/(m³·Pa)]

    % 2. BILANCIO ENERGETICO
    % Derivazione di f dal bilancio entalpico tra ingresso e uscita:
    %   m_a * cp_a * T03 + m_f * LHV * eta_b = (m_a + m_f) * cp_g * T04
    % Risolvendo per f = m_f / m_a:
    f   = (cp_g * T04 - cp_a * T03_primo) / (LHV * eta_b - cp_g * T04);
    m_f = f * m_a;          % portata massica combustibile [kg/s]
    
    % Calore liberato
    Q_dot = m_f * LHV * eta_b;     % [W]

    % 3. DIMENSIONAMENTO TRASVERSALE
    % Area di riferimento dalla correlazione ΔP/q_ref = costante
    termine_flusso = (m_a * sqrt(T03_primo)) / P03_primo;  % parametro flusso
    A_ref = sqrt( (R/2) * (termine_flusso^2) * (DP_su_qref / DP_su_P3_target) );

    % Altezza del canale anulare
    h_ref = A_ref / (2 * pi * r_m);    % [m]

    % Grandezze di verifica
    rho3  = P03_primo / (R * T03_primo);        % densità all'ingresso [kg/m³]
    U_ref = m_a / (rho3 * A_ref);              % velocità di riferimento [m/s]
    q_ref = 0.5 * rho3 * U_ref^2;             % pressione dinamica di riferimento [Pa]
    M_ref = U_ref / sqrt(gamma * R * T03_primo); % Mach di riferimento [-]
     
    % 4. DIMENSIONAMENTO VOLUMETRICO E LONGITUDINALE
    % Volume della camera da intensità di combustione: I = Q_dot / (V * P03)
    V  = Q_dot / (I * P03_primo);  % [m³]

    % Lunghezza assiale della camera
    Lc = V / A_ref;                % [m]
    
    % Verifica tempo di residenza:
    t_res = Lc/U_ref;
    if t_res < 8e-3
        error('Tempo di residenza minore di quello necessario (0.008s)')
    end

    % 5. CONDIZIONI DI USCITA
    P04 = (1 - DP_su_P3_target) * P03_primo;   % pressione totale uscita [Pa]
    % T04 è già assegnata sopra 
    
    % 6. AGGIORNAMENTO STRUCT DI OUTPUT
    propCombust.f   = f;
    propCombust.m_f = m_f;

    propCamera.A_ref = A_ref;
    propCamera.h_ref = h_ref;
    propCamera.V     = V;
    propCamera.Lc    = Lc;
    propCamera.U_ref = U_ref;
    propCamera.q_ref = q_ref;
    propCamera.M_ref = M_ref;
    propCamera.t_res = t_res;

end
