function [motore] = CameraCombustione(motore)
% CAMERACOMBUSTIONE Funzione che svolge il ciclo termodinamico reale della 
% camera di combustione, restituendo le condizioni termodinamiche in uscita 
% e le caratteristiche geometriche per il dimensionamento della camera.
%
%   [motore] = CameraCombustione(motore) 

  
    % 1. ESTRAZIONE VARIABILI DALLE STRUCT

    % Uscita Diffusore
    P03Primo = motore.diffusore.P035;
    T03Primo = motore.diffusore.T035;
    M03Primo = motore.diffusore.mach35;
    % Combustibile
    LHV   = motore.fluidi.combustibile.LHV;        % potere calorifico inferiore JP-7 [J/kg]

    % Motore
    etaB = motore.camera.etaB;     % rendimento di combustione [-]
    mDotAir  = motore.portate.mDotAir;   % portata aria che entra in camera [kg/s]
    T04   = motore.camera.T04;       % temperatura target TIT in uscita camera [K]
    
    % Fluidi
    cpA  = motore.fluidi.aria.cp;       % cp aria in ingresso [J/(kg·K)]
    Ra = motore.fluidi.aria.R;          % costante dell' aria [J/(Kg*K)]
    gammaA = motore.fluidi.aria.gamma;  % rapporto calori specifici aria [-]
    cpG  = motore.fluidi.gas.cp;        % cp gas combusti in uscita [J/(kg·K)]
    Rg   = motore.fluidi.gas.R;         % costante del gas [J/(kg·K)]
    gammaG = motore.fluidi.gas.gamma;   % rapporto calori specifici gas combusti [-]
    cpF     = motore.fluidi.combustibile.cp; % cp combustibile liquido [J/(kg·K)]
    % Ricavo pressione e temperatura statica per calcoli futuri:
    T3Statica = T03Primo / (1 + (gammaA-1)/2 * M03Primo^2);
    P3Statica = P03Primo / (1 + (gammaA-1)/2 * M03Primo^2)^(gammaA/(gammaA-1));

    % Calcolo la densità dell'aria in uscita dal diffusore
    rho3 = P3Statica / (Ra * T3Statica);  % [kg/s]

    % Camera
    rMedio            = motore.compressore.rM3;             % raggio medio anulare [m]
    perditaDinamica   = motore.camera.perditaDinamica;    % fattore perdita dinamica [-]
    perditaPressione  = motore.camera.perditaPressione;   % perdita di pressione target [-]
    I                 = motore.camera.I;                  % intensità di combustione [W/(m³·Pa)]

    % 2. BILANCIO ENERGETICO
    % Impongo un limite progettuale di temperatura affinchè la combustione
    % venga risolta in modo da non generare eccessivi gas combsuti:
    TComb = motore.camera.TComb; % [K]

    % Derivazione di fLiner e fGlobal dal bilancio entalpico tra ingresso e uscita:
    % Risolvendo per f = mDotComb / mDotAirCalda:
    Tfuel = 273.15;
    fLiner  = (cpG * TComb - cpA * T03Primo) / (LHV * etaB - cpG * TComb + cpF * Tfuel);
    fGlobal  = (cpG * T04 - cpA * T03Primo) / (LHV * etaB - cpG * T04 + cpF *Tfuel);
    
    % Rapporto di equivalenza:
    fStechio = 0.068;
    phi = fLiner/fStechio;

    % Suddivisone tra portata in ingresso nel liner e portata in ingresso 
    % nel casing, attraverso la formula di miscelazione adiabatica: 
    % mDotAirCalda*(cpG*TComb-cpA*T03Primo) = mDotAir*(cpG*T04-cpA*T03Primo)

    mDotAirCalda = mDotAir * (cpG*T04-cpA*T03Primo) / (cpG*TComb-cpA*T03Primo);  % portata aria calda [kg/s]

    mDotAirFredda = mDotAir - mDotAirCalda; % portata aria di cooling [kg/s]
    
    mDotComb = fGlobal * mDotAir;          % portata massica combustibile [kg/s]

    % Calore liberato
    QDot = mDotComb * LHV * etaB;     % [W]

    % 3. DIMENSIONAMENTO TRASVERSALE
    % Area di riferimento dalla correlazione ΔP/qRef = costante
    termine_flusso = (mDotAir * sqrt(T03Primo)) / P03Primo;  % parametro flusso
    ARef = sqrt((Rg/2) * (termine_flusso^2) * (perditaDinamica/perditaPressione));

    % Altezza del canale anulare
    hRef = ARef / (2*pi*rMedio);    % [m]

    % Grandezze di verifica
    URef = mDotAir / (rho3 * ARef);              % velocità di riferimento [m/s]
    qRef = 0.5 * rho3 * URef^2;                  % pressione dinamica di riferimento [Pa]
    MRef = URef / sqrt(gammaG * Rg * T03Primo);  % Mach di riferimento [-]

    % Per il tempo di residenza si utilizzino i parametri del liner:
    ALiner = ARef * (mDotAirCalda/mDotAir);  % Area di riferimento del Liner
    rhoLiner = P3Statica / (Rg*TComb);
    ULiner = (mDotAirCalda+mDotComb)/(ALiner*rhoLiner);
    MLiner = ULiner / sqrt(gammaG * Rg * TComb);
    
    % 4. DIMENSIONAMENTO VOLUMETRICO E LONGITUDINALE
    % Volume della camera da intensità di combustione: I = QDot / (V * P03)
    V  = QDot / (I * P03Primo);  % [m³]

    % Lunghezza assiale della camera
    Lc = V / ARef;                % [m]
    
    % Verifica tempo di residenza:
    tRes = Lc/URef;

    % 5. CONDIZIONI DI USCITA
    P04 = (1 - perditaPressione) * P03Primo;   % pressione totale uscita [Pa]
    % T04 è già assegnata sopra 
    
    % 6. AGGIORNAMENTO STRUCT DI OUTPUT
    motore.camera.f  = fGlobal;
    motore.portate.mDotComb = mDotComb;

    motore.camera.rMedio = rMedio;
    motore.camera.ARef = ARef;
    motore.camera.ALiner = ALiner;
    motore.camera.hRef = hRef;
    motore.camera.V     = V;
    motore.camera.LC    = Lc;
    motore.camera.URef = URef;
    motore.camera.qRef = qRef;
    motore.camera.MRef = MRef;
    motore.camera.tRes = tRes;
    motore.camera.mDotAirCalda = mDotAirCalda;
    motore.camera.mDotAirFredda = mDotAirFredda;
    motore.camera.P04 = P04;
    motore.camera.QDot = QDot;
    motore.camera.phi = phi;


end

