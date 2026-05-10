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
eta_m = 0.92; % rendimento meccanico
eta_p = 0.9;% rendimento adiabatico

% Aria di rafreddamento dalle tabelle
CoolingStatore = @(x)  (x<1100)*0 + ...    %cooling air richiesta per TIN statore è SOT
    (x>=1100 & x <= 1650).*(0.09./(1600-1100).*(x-1100)) + ...
    (x>1650).*0.5;

CoolingRotore = @(x)   (x<1250)*0 + ...    %cooling air richiesta per TIN statore la T è SOT
    (x>=1250 & x <= 1600).*(0.05./(1400-1250).*(x-1250)) + ...
    (x>1600).*0.5;


%% Impostare struct

Turbina.eta_m = eta_m;
Turbina.eta_p = eta_p;
Turbina.CoolingStatore = CoolingStatore;
Turbina.CoolingRotore = CoolingRotore;

% Lavoro e Rendimento
Turbina.L_turbina = NaN;
Turbina.eta_n = NaN;

% Rendimento isoentropico rispetto a caso senza rafreddamento
Turbina.eta_NC = NaN;


% IN
Turbina.machIn = NaN;
Turbina.P0I = NaN;
Turbina.T0I = NaN;

% Out
Turbina.P0U = NaN;
Turbina.T0U = NaN;
Turbina.machOut = NaN;
Turbina.T0U_iso = NaN;

% Parametri di Rafreddamento
Turbina.coolPecentuale = NaN;
Turbina.SOT = NaN;
Turbina.TCool = NaN;

% Sezioni
Turbina.AIn = NaN;
Turbina.AOut = NaN;


% Stadio



% Salvataggio Struct
motore.turbina = Turbina;
% ---------------------------------------------------------------------



end
