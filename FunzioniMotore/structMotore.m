function [motore] = structMotore()

%%
% 0  --> flusso indisturbato
% 2  --> uscita presa d'aria
% 3  --> uscita compressore
% 35 --> uscita diffusore
% 4  --> uscita combustore
% 5  --> uscita turbina
% 6  --> uscita postbruciatore
% 7  --> uscita ugello


%% Costanti universali
    Ru     = 8314;          % costante universale dei gas [J/(kmol·K)]


%% ------------------------------------------------------------------------
%                           PROPRIETA' FLUIDI
%--------------------------------------------------------------------------

    % Proprietà aria 
    aria.Mm = 28.97;
    aria.R  = Ru/aria.Mm;    
    aria.cp = 7/2*aria.R;
    aria.gamma = 1.4;
    

    % Proprietà gas combusti
    gas.R = aria.R;
    gas.gamma = 1.33;
    gas.cp = (gas.gamma * gas.R) / (gas.gamma - 1);

    % Proprietà combustibile (JP-7)
    combustibile.Mm = 321.4964;
    combustibile.cp = 1800;
    combustibile.LHV = 44.1e6;

    % salvataggio
    motore.fluidi.aria     = aria;
    motore.fluidi.gas      = gas;
    motore.fluidi.combustibile = combustibile;


%---------------------------------------------------------------------
%% PORTATE
%---------------------------------------------------------------------

motore.portate.mDot    = NaN;    % portata massica totale
motore.portate.mDotAir = NaN;   % portata massica in camera di combustione
motore.portate.mDotRaff= NaN;   % portata massica per raffredamento turbina
motore.portate.mDotGas = NaN;   % portata massica in usicta dalla camera che comprende il combustibile
motore.portate.mDotComb= NaN;   % portata massica del combustibile




%---------------------------------------------------------------------
%% FREE STREAM
%---------------------------------------------------------------------

%% Condizioni atmosferiche a 12000 m (ISA)
M0  = 0.85;             % numero di Mach di volo [-]
T0  = 216.65;           % temperatura statica [K]
P0  = 19280;            % pressione statica [Pa]

gamma = 1.4;
R = 287.05;

T00 = T0 * (1 + (gamma - 1)/2 * M0^2);  % temperatura totale [K]
P00 = P0 * (1 + (gamma - 1)/2 * M0^2)^(gamma/(gamma - 1)); % pressione totale [Pa]

rho0 = P0 / (R * T0);          % densità statica [kg/m³]
a0   = sqrt(gamma * R * T0);   % velocità del suono [m/s]
V0   = a0 * M0;                % velocità di volo [m/s]

motore.freestream.h12km.T0 = T0;
motore.freestream.h12km.P0 = P0;
motore.freestream.h12km.T00 = T00;
motore.freestream.h12km.P00 = P00;
motore.freestream.h12km.rho0 = rho0;
motore.freestream.h12km.M0 = M0;
motore.freestream.h12km.V0 = V0;
motore.freestream.h12km.a0 = a0;

%---------------------------------------------------------------------
%% PRESA D'ARIA
%---------------------------------------------------------------------

motore.presaAria.regime = "subsonico";
motore.presaAria.T2 = NaN;
motore.presaAria.P2 = NaN;
motore.presaAria.T02 = NaN;
motore.presaAria.P02 = NaN;
motore.presaAria.mach2 = 0.5;
motore.presaAria.etaD = 0.975;
motore.presaAria.piD = 0.95;

motore.presaAria.rho2 = NaN;
motore.presaAria.V2 = NaN;
motore.presaAria.A0 = NaN;
motore.presaAria.A2 = NaN;
motore.presaAria.CPR = NaN;

%---------------------------------------------------------------------
%% COMPRESSORE
%---------------------------------------------------------------------

motore.compressore.piC = NaN;
motore.compressore.etaP = 0.9;
motore.compressore.Utip = 400;
motore.compressore.UM = NaN;


motore.compressore.hubTip = 0.5;


motore.compressore.T03 = NaN;
motore.compressore.P03 = NaN;
motore.compressore.LC = NaN;
motore.compressore.etaC = NaN;
motore.compressore.machRel = NaN;
motore.compressore.MachAbs = NaN;
motore.compressore.CpStadio = NaN;
motore.compressore.deHaller = NaN;
motore.compressore.Va = NaN;
motore.compressore.beta1 = NaN;
motore.compressore.beta2 = NaN;
motore.compressore.rM2 = NaN;
motore.compressore.h2 = NaN;
motore.compressore.A3 = NaN;
motore.compressore.rM3 = NaN;
motore.compressore.h3 = NaN;
motore.compressore.DRotore = NaN;
motore.compressore.DStatore = NaN;
motore.compressore.RStadio = NaN;
motore.compressore.c_m = NaN;
motore.compressore.NStadi = NaN;

    %%  DIFFUSORE ANULARE  (tra compressore e camera)

    % M_in e rm dipendono dall'uscita del compressore: vengono aggiornati
    % nel main subito dopo la chiamata a compressore.m.

    motore.diffusore.vTargetCamera = 25;   % velocità target ingresso camera [m/s]
    motore.diffusore.pi_d            = 0.97; % rendimento pneumatico           [-]
    motore.diffusore.theta           = 3;    % semi-angolo di apertura [gradi]
                                                  % (limite distacco: < 8–10°)

    % Aggiornati nel main dopo compressore.m
    motore.diffusore.mach3  = NaN;  % Mach ingresso (= machOut compressore) [-]
    motore.diffusore.rMedio = NaN;  % raggio medio  (= rM3 compressore)  [m]
    motore.diffusore.T03    = NaN;
    motore.diffusore.P03    = NaN;
    motore.diffusore.T035   = NaN;
    motore.diffusore.P035   = NaN;
    motore.diffusore.mach35 = 0.2;

    % Calcolati da Diffusore.m
    motore.diffusore.A3     = NaN; % area ingresso          [m²]
    motore.diffusore.A35    = NaN; % area uscita            [m²]
    motore.diffusore.h3     = NaN; % altezza canale ingresso [m]
    motore.diffusore.h35    = NaN; % altezza canale uscita  [m]
    motore.diffusore.LD     = NaN; % lunghezza assiale       [m]
    motore.diffusore.v3     = NaN; % velocità ingresso      [m/s]
    motore.diffusore.v35    = NaN; % velocità uscita        [m/s]

%%  CAMERA DI COMBUSTIONE

    motore.camera.rMedio             = NaN;  % raggio medio camera anulare   [m]
    motore.camera.perditaDinamica      = 20;    % fattore perdita dinamica ΔP/q [-]
    motore.camera.perditaPressione = 0.06;  % perdita pressione totale      [-]
    motore.camera.I               = 100;   % intensità di combustione      [W/(m³·Pa)]
    motore.camera.etaB           = 0.98;  % rendimento di combustione     [-]

    % Calcolati da Camera_di_combustione.m
    motore.camera.ARef = NaN;  % area di riferimento                     [m²]
    motore.camera.hRef = NaN;  % altezza canale anulare                  [m]
    motore.camera.ALiner = NaN;
    motore.camera.V     = NaN;  % volume camera                           [m³]
    motore.camera.LC    = NaN;  % lunghezza camera                        [m]
    motore.camera.URef = NaN;  % velocità di riferimento                 [m/s]
    motore.camera.qRef = NaN;  % pressione dinamica di riferimento       [Pa]
    motore.camera.MRef = NaN;  % Mach di riferimento                     [-]
    motore.camera.tRes = NaN;
    motore.camera.f = NaN;
    motore.camera.T04 = NaN;
    motore.camera.mDotAirCalda = NaN;
    motore.camera.mDotAirFredda = NaN;
    motore.camera.P04 = NaN;
    motore.camera.QDot = NaN;
    motore.camera.TComb = 2300;
    motore.camera.phi = NaN;


%% TUBINA
% ---------------------------------------------------------------------

    %% COSTANTI
    etaM   = 0.95; % rendimento meccanico
    etaP   = 0.9;% rendimento adiabatico
    
    % Aria di rafreddamento dalle tabelle
    CoolingStatore  = @(x)  (x<1100)*0 + ...    %cooling air richiesta per TIN statore è SOT
        (x>=1100 & x <= 1650).*(0.09./(1600-1100).*(x-1100)) + ...
        (x>1650).*0.5;
    
    CoolingRotore   = @(x)   (x<1250)*0 + ...    %cooling air richiesta per TIN statore la T è SOT
        (x>=1250 & x <= 1600).*(0.05./(1400-1250).*(x-1250)) + ...
        (x>1600).*0.5;

 
    
    %% Impostare struct
    
    turbina.etaM            = etaM;
    turbina.etaP            = etaP;
    turbina.coolingStatore  = CoolingStatore;
    turbina.coolingRotore   = CoolingRotore;
    
    % Lavoro e Rendimento
    turbina.lTurbina    = NaN;
    turbina.etaN        = NaN;
    
    % IN
    turbina.mach4   = 0.5;
    turbina.rho4    = NaN;

    
    % Out
    turbina.P05     = NaN;
    turbina.T05     = NaN;
    turbina.rho5    = NaN;
    turbina.mach5   = NaN;
    turbina.T05Iso  = NaN;
    turbina.rp      = NaN;

    % Parametri di Rafreddamento
    turbina.TRaff           = NaN;
    
    % Sezioni
    turbina.A4          = NaN;
    turbina.A5          = NaN;
    turbina.h5          = NaN;
    turbina.rt5         = NaN;
    turbina.rh5         = NaN;
    
    
        % Stadio
        %velocità palette
        turbina.U   = NaN;
        % grado di reazione
        turbina.R   = NaN;
        % lavoro stadio
        turbina.lStadio     = NaN;
        turbina.nStadi      = NaN;
        turbina.etaStadio   = NaN;
            % Statore
                turbina.statore.a       = NaN;
                turbina.statore.alpha   = NaN;
                turbina.statore.AIn     = NaN;
                turbina.statore.AOut    = NaN;
                turbina.statore.T       = NaN;
                turbina.statore.P       = NaN;
                turbina.statore.rho     = NaN;
                % velocità
                turbina.statore.vz      = NaN;
                turbina.statore.vt      = NaN;
                turbina.statore.v       = NaN;
                turbina.statore.wz      = NaN;
                turbina.statore.wt      = NaN;
                turbina.statore.w       = NaN;
        
            % Rotore
                turbina.rotore.AIn      = NaN;
                turbina.rotore.AOut     = NaN;
                turbina.rotore.T        = NaN;
                turbina.rotore.T0       = NaN;
                turbina.rotore.P        = NaN;
                turbina.rotore.P0       = NaN;
                turbina.rotore.rho      = NaN;
                % velocità
                turbina.rotore.vz       = NaN;
                turbina.rotore.vt       = NaN;
                turbina.rotore.v        = NaN;
                turbina.rotore.wz       = NaN;
                turbina.rotore.wt       = NaN;
                turbina.rotore.w        = NaN;
                turbina.rotore.wmachOut = 0.85;
    
                % geometria
                turbina.rotore.hOut      = NaN;
                turbina.rotore.rtOut     = NaN;
                turbina.rotore.rhOut     = NaN;
                turbina.rotore.hIn      = NaN;
                turbina.rotore.rtIn     = NaN;
                turbina.rotore.rhIn     = NaN;
                

                
        
        
        
    
    % Salvataggio Struct
    motore.turbina  = turbina;
    % ---------------------------------------------------------------------



    %% UGELLO
    motore.ugello.etaN  = 0.95;             % Rendimento
    motore.ugello.piN   = 0.98;             % Perdita di pressione per postbruciatore
    motore.ugello.P06   = NaN;              % Pressione totale in uscita
    motore.ugello.T06   = NaN;              % Temperatura totale in uscita
    motore.ugello.mach6 = NaN;              % Numero di Mach
    motore.ugello.Ue    = NaN;              % velocità di efflusso
    motore.ugello.AStar = NaN;              % area di gola
    motore.ugello.AE    = NaN;              % area di efflusso
    motore.ugello.DE    = NaN;              % diametro di efflusso
    motore.ugello.PE    = NaN;              % pressione di efflusso


    %% PERFORMANCE
    motore.performance.F         = NaN;
    motore.performance.etaGlobal = NaN;
    motore.performance.TSFC      = NaN;
    motore.performance.etaProp   = NaN;
    motore.performance.etaTh     = NaN;

end
