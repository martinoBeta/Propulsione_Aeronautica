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





 %% QUESTI SONO DA ELIMINARE
% 
% % Parametri globali del motore turbojet-ramjet
% 
% 
% % Parametri termodinamici ciclo
% Tmax  = 1700;           % temperatura massima ciclo (TIT) [K]
% eta_b = 0.98;           % rendimento di combustione [-]
% pi_b  = 0.97;           % rapporto di pressione camera di combustione [-]
% 
% % Perdite e spillamenti
% % aria_spillata: frazione di mAir prelevata dopo il compressore
% 
% 
% % Assemblaggio struct
% 
% % motore.Tmax        = Tmax;
% % motore.eta_b       = eta_b;
% % motore.pi_b        = pi_b;
% % motore.eta_d_1     = eta_d_1;
% % motore.mDotCore = 0.9*mdot;
% % motore.mdot  = mdot;
% % 
% 
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
    gas.cpG = NaN;


    % Proprietà combustibile (JP-7)
    combustibile.Mm = 321.4964;
    combustibile.R = Ru / combustibile.Mm;
    combustibile.cp = 7/2 *combustibile.R;
    combustibile.LHV = 44.1e6;

    % salvataggio
    motore.fluidi.aria     = aria;
    motore.fluidi.gas      = gas;
    motore.fluidi.combustibile = combustibile;


%---------------------------------------------------------------------
%% PORTATE
%---------------------------------------------------------------------

motore.portate.mDot    = 35;    % portata massica totale
motore.portate.mDotAir = NaN;    % portata massica in camera di combustione
motore.portate.mDotRaff= NaN;    % portata masscia per raffredamento turbina






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
motore.presaAria.M2 = 0.35;
motore.presaAria.eta_d = 0.975;
motore.presaAria.pi_d = 0.985;

motore.presaAria.rho2 = NaN;
motore.presaAria.V2 = NaN;
motore.presaAria.A_ingresso = NaN;
motore.presaAria.A2 = NaN;
motore.presaAria.CPR = NaN;



% T0I, P0I, T_in, P_in, rho_in, V_in, A0, Ain, pi_d, CPR



%---------------------------------------------------------------------
%% COMPRESSORE
%---------------------------------------------------------------------

motore.compressore.pi_c = 7;
motore.compressore.eta_p = 0.9;
motore.compressore.Utip = 350;
motore.compressore.U_m = NaN;


motore.compressore.hubTip = 0.5;


motore.compressore.T03 = NaN;
motore.compressore.P03 = NaN;
motore.compressore.L_c = NaN;
motore.compressore.eta_c = NaN;
motore.compressore.Mach_rel = NaN;
motore.compressore.Mach_abs = NaN;
motore.compressore.Cp_stadio = NaN;
motore.compressore.deHaller = NaN;
motore.compressore.Va = NaN;
motore.compressore.beta1 = NaN;
motore.compressore.beta2 = NaN;
%motore.compressore.Ain_c = NaN; = area uscita presa
motore.compressore.r_m_in = NaN;
motore.compressore.h_in = NaN;
motore.compressore.Aout_c = NaN;
motore.compressore.r_m_out = NaN;
motore.compressore.h_out = NaN;
motore.compressore.D_rotore = NaN;
motore.compressore.D_statore = NaN;
motore.compressore.R_m = NaN;
motore.compressore.c_m = NaN;
motore.compressore.N_R = NaN;
motore.compressore.N_stadi = NaN;






%% TUBINA
% ---------------------------------------------------------------------

    %% COSTANTI
    etaM   = 0.92; % rendimento meccanico
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
    
    % Rendimento isoentropico rispetto a caso senza rafreddamento
    turbina.etaNRaff    = NaN;
            
    
    % IN
    turbina.mach4   = NaN;
    turbina.P04     = NaN;
    turbina.T04     = NaN;
    turbina.rho4    = NaN;

    
    % Out
    turbina.P05     = NaN;
    turbina.T05     = NaN;
    turbina.rho5    = NaN;
    turbina.mach5   = NaN;
    turbina.T05Iso  = NaN;
    turbina.rp      = NaN;

    % Parametri di Rafreddamento
    turbina.raffPecentuale  = NaN;
    turbina.Sot             = NaN;
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
            turbina.rotore.wmachOut = NaN;

            % geometria
            turbina.rotore.hIn      = NaN;
            turbina.rotore.rtIn     = NaN;
            turbina.rotore.rhIn     = NaN;
    
    
    
    
    % Salvataggio Struct
    motore.turbina  = turbina;
    % ---------------------------------------------------------------------


    %%  DIFFUSORE ANULARE  (tra compressore e camera)

    % M_in e rm dipendono dall'uscita del compressore: vengono aggiornati
    % nel main subito dopo la chiamata a compressore.m.

    motore.diffusore.vTargetCamera = 25;   % velocità target ingresso camera [m/s]
    motore.diffusore.pi_d            = 0.95; % rendimento pneumatico           [-]
    motore.diffusore.theta           = 8;    % semi-angolo di apertura [gradi]
                                                  % (limite distacco: < 8–10°)

    % Aggiornati nel main dopo compressore.m
    motore.diffusore.mach3  = NaN;  % Mach ingresso (= mach_out compressore) [-]
    motore.diffusore.rMedio = NaN;  % raggio medio  (= r_m_out compressore)  [m]
    motore.diffusore.T03    = NaN;
    motore.diffusore.P03    = NaN;
    motore.diffusore.T035   = NaN;
    motore.diffusore.P035   = NaN;
    motore.diffusore.mach35 = NaN;

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
    motore.camera.I               = 9e6;   % intensità di combustione      [W/(m³·Pa)]
    motore.camera.eta_b           = 0.98;  % rendimento di combustione     [-]
    motore.camera.pi_b            = 0.97;  % rapporto di pressione camera  [-]

    % Calcolati da Camera_di_combustione.m
    motore.camera.ARef = NaN;  % area di riferimento                     [m²]
    motore.camera.hRef = NaN;  % altezza canale anulare                  [m]
    motore.camera.V     = NaN;  % volume camera                           [m³]
    motore.camera.LC    = NaN;  % lunghezza camera                        [m]
    motore.camera.URef = NaN;  % velocità di riferimento                 [m/s]
    motore.camera.qRef = NaN;  % pressione dinamica di riferimento       [Pa]
    motore.camera.MRef = NaN;  % Mach di riferimento                     [-]
    motore.camera.tRes = NaN;
    motore.camera.f = NaN;
    motore.camera.T04 = 1600;
  
end
