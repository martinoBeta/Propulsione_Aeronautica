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







% Parametri globali del motore turbojet-ramjet

% Portate
mdot  = 35;


% Parametri termodinamici ciclo
Tmax  = 1700;           % temperatura massima ciclo (TIT) [K]
eta_b = 0.98;           % rendimento di combustione [-]
pi_b  = 0.97;           % rapporto di pressione camera di combustione [-]

% Perdite e spillamenti
% aria_spillata: frazione di mAir prelevata dopo il compressore

eta_d_1 = 1; % cosa è sto valore???????

% Assemblaggio struct

motore.Tmax        = Tmax;
motore.eta_b       = eta_b;
motore.pi_b        = pi_b;
motore.eta_d_1     = eta_d_1;
motore.mDotCore = 0.9*mdot;
motore.mdot  = mdot;



%% ------------------------------------------------------------------------
%                           PROPRIETA' FLUIDI
%--------------------------------------------------------------------------


%% Aria 
motore.fluidi.aria.R     = 287.05;
motore.fluidi.aria.gamma = 1.40;
motore.fluidi.aria.cp    = 1004.5;

%% Combustibile JP-7
motore.fluidi.fuel.LHV = 43.5e6;   % [J/kg]

%% Gas combusti
motore.fluidi.gas.R     = 287.05;  
motore.fluidi.gas.gamma = 1.33;
motore.fluidi.gas.cp    = motore.fluidi.gas.gamma * motore.fluidi.gas.R / ...
                          (motore.fluidi.gas.gamma - 1);



%---------------------------------------------------------------------
%% PORTATE
%---------------------------------------------------------------------

motore.portate.mDotAir = 35; % portata massica totale







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

motore.presa.T2 = NaN;
motore.presa.P2 = NaN;
motore.presa.T02 = NaN;
motore.presa.P02 = NaN;
motore.presa.M2 = 0.35;
motore.presa.eta_d = 0.975;
motore.presa.pi_d = 0.985;

motore.presa.rho2 = NaN;
motore.presa.V2 = NaN;
motore.presa.A_cattura = NaN;
motore.presa.A_ingresso = NaN;
motore.presa.A2 = NaN;
motore.presa.CPR = NaN;



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
    eta_m   = 0.92; % rendimento meccanico
    eta_p   = 0.9;% rendimento adiabatico
    
    % Aria di rafreddamento dalle tabelle
    CoolingStatore  = @(x)  (x<1100)*0 + ...    %cooling air richiesta per TIN statore è SOT
        (x>=1100 & x <= 1650).*(0.09./(1600-1100).*(x-1100)) + ...
        (x>1650).*0.5;
    
    CoolingRotore   = @(x)   (x<1250)*0 + ...    %cooling air richiesta per TIN statore la T è SOT
        (x>=1250 & x <= 1600).*(0.05./(1400-1250).*(x-1250)) + ...
        (x>1600).*0.5;
    
    
    %% Impostare struct
    
    turbina.eta_m           = eta_m;
    turbina.eta_p           = eta_p;
    turbina.CoolingStatore  = CoolingStatore;
    turbina.CoolingRotore   = CoolingRotore;
    
    % Lavoro e Rendimento
    turbina.L_turbina   = NaN;
    turbina.eta_n       = NaN;
    
    % Rendimento isoentropico rispetto a caso senza rafreddamento
    turbina.eta_NC  = NaN;
    
    
    % IN
    turbina.machIn  = NaN;
    turbina.P04     = NaN;
    turbina.T04     = NaN;
    turbina.rho4    = NaN;

    
    % Out
    turbina.P05     = NaN;
    turbina.T05     = NaN;
    turbina.rho5    = NaN;
    turbina.mach5   = NaN;
    turbina.T05_iso = NaN;
    turbina.rp      = NaN;

    % Parametri di Rafreddamento
    turbina.coolPecentuale  = NaN;
    turbina.SOT             = NaN;
    turbina.TCool           = NaN;
    
    % Sezioni
    turbina.AIn     = NaN;
    turbina.AOut    = NaN;
    turbina.hOut    = NaN;
    turbina.rtOut   = NaN;
    turbina.rhOut   = NaN;
    
    
    % Stadio
        %velocità palette
        turbina.U   = NaN;
        % grado di reazione
        turbina.R   = NaN;
        % lavoro stadio
        turbina.L_stadio    = NaN;
        turbina.N_stadi     = NaN;
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



end
