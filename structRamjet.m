function [ramjet] = structRamjet()
%FUNZIONE NON COMPLETATA DATI NON ATTENDIBILI!!!!
%%
% 0  --> flusso indisturbato
% 2  --> uscita presa d'aria
% 3  --> uscita anulus
% 4  --> uscita camera di combustione
% 5  --> uscita ugello

%% Costanti universali
Ru     = 8314;          % costante universale dei gas [J/(kmol·K)]

%% ------------------------------------------------------------------------
%                           PROPRIETA' FLUIDI
%--------------------------------------------------------------------------

% Proprietà aria 
aria.Mm    = 28.97;
aria.R     = Ru/aria.Mm;    
aria.cp    = 7/2*aria.R;
aria.gamma = 1.4;


% Proprietà gas combusti
gas.R     = aria.R;
gas.gamma = 1.33;
gas.cp    = (gas.gamma * gas.R) / (gas.gamma - 1);


% Proprietà combustibile (JP-7)
combustibile.Mm  = 321.4964;
combustibile.R   = Ru / combustibile.Mm;
combustibile.cp  = 7/2 *combustibile.R;
combustibile.LHV = 44.1e6;

% salvataggio
ramjet.fluidi.aria         = aria;
ramjet.fluidi.gas          = gas;
ramjet.fluidi.combustibile = combustibile;

%---------------------------------------------------------------------
%% PORTATE
%---------------------------------------------------------------------

ramjet.portate.mDot     = NaN;   % portata massica totale
ramjet.portate.mDotAir  = NaN;   % portata massica in camera di combustione
ramjet.portate.mDotGas  = NaN;   % portata massica in usicta dalla camera che comprende il combustibile
ramjet.portate.mDotComb = NaN;   % portata massica del combustibile


%---------------------------------------------------------------------
%% FREE STREAM
%---------------------------------------------------------------------

%% Condizioni atmosferiche a 12000 m (ISA)
M0  = 3.5;             % numero di Mach di volo [-]
T0  = 133.65;           % temperatura statica [K]
P0  = 1296;            % pressione statica [Pa]

gamma = 1.4;
R     = 287.05;

T00 = T0 * (1 + (gamma - 1)/2 * M0^2);  % temperatura totale [K]
P00 = P0 * (1 + (gamma - 1)/2 * M0^2)^(gamma/(gamma - 1)); % pressione totale [Pa]

rho0 = P0 / (R * T0);          % densità statica [kg/m³]
a0   = sqrt(gamma * R * T0);   % velocità del suono [m/s]
V0   = a0 * M0;                % velocità di volo [m/s]

ramjet.freestream.h25km.T0   = T0;
ramjet.freestream.h25km.P0   = P0;
ramjet.freestream.h25km.T00  = T00;
ramjet.freestream.h25km.P00  = P00;
ramjet.freestream.h25km.rho0 = rho0;
ramjet.freestream.h25km.M0   = M0;
ramjet.freestream.h25km.V0   = V0;
ramjet.freestream.h25km.a0   = a0;


%---------------------------------------------------------------------
%% PRESA D'ARIA
%---------------------------------------------------------------------

% COMPLETARE/CONTROLLARE

ramjet.presaAria.regime = "ipersonico";
ramjet.presaAria.T2     = NaN;
ramjet.presaAria.P2     = NaN;
ramjet.presaAria.T02    = NaN;
ramjet.presaAria.P02    = NaN;
ramjet.presaAria.M2     = NaN;
ramjet.presaAria.eta_d  = NaN;
ramjet.presaAria.pi_d   = NaN;

ramjet.presaAria.rho2       = NaN;
ramjet.presaAria.V2         = NaN;
ramjet.presaAria.A_ingresso = NaN;
ramjet.presaAria.A2         = NaN;
ramjet.presaAria.CPR        = NaN;
ramjet.presaAria.mach       = NaN;

%---------------------------------------------------------------------
%% ANULUS
%---------------------------------------------------------------------


ramjet.anulus.T03  = NaN;   % Temperatura totale in uscita
ramjet.anulus.P03  = NaN;   % Pressione totale in uscita
ramjet.anulus.A    = NaN;   % Area dell'anulus
ramjet.anulus.rRam = NaN;   % Raggio esterno del casing


%---------------------------------------------------------------------
%% CAMERA DI COMBUSTIONE
%---------------------------------------------------------------------
ramjet.camera.Tmax  = 2100;        % Temperatura massima  [K]
ramjet.camera.pi_ab = 0.96;        % Rendimento pneumatico
ramjet.camera.r     = NaN;         % Raggio camera di combustione/postbruciatore
ramjet.camera.LH    = 0.3;         % Rapporto lunghezza/diametro
ramjet.camera.B     = 0.25;        % Bloccaggio
ramjet.camera.etaC  = 0.98;        % Efficienza di combustione

ramjet.camera.mach    = NaN;          % Numero di mach
ramjet.camera.T04     = NaN;          % Temperatura in uscita
ramjet.camera.P04     = NaN;          % Pressione in uscita
ramjet.camera.f       = NaN;
ramjet.camera.d       = NaN;          % Diametro stabilizzatore di fiamma
ramjet.camera.L       = NaN;          % Lunghezza camera

%---------------------------------------------------------------------
%% UGELLO
%---------------------------------------------------------------------
ramjet.ugello.etaN  = 0.9;              % Rendimento
ramjet.ugello.P05   = NaN;              % Pressione totale in uscita
ramjet.ugello.T05   = NaN;              % Temperatura totale in uscita
ramjet.ugello.mach5 = NaN;              % Numero di Mach
ramjet.ugello.Ue    = NaN;              % velocità di efflusso
ramjet.ugello.AStar = NaN;              % area di gola
ramjet.ugello.AE    = NaN;              % area di efflusso
ramjet.ugello.DE    = NaN;              % diametro di efflusso


%---------------------------------------------------------------------
%% PERFORMANCE
%---------------------------------------------------------------------
ramjet.performance.F         = NaN;
ramjet.performance.etaGlobal = NaN;
ramjet.performance.TSFC      = NaN;

end