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
combustibile.Mm  = 170;
combustibile.LHV = 43.5e6;
combustibile.cp  = 2100;    % [J/(kg·K)]

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

%% Condizioni atmosferiche a 25000 m (ISA)
M0  = 3.5;             % numero di Mach di volo [-]
T0  = 221.65;           % temperatura statica [K]
P0  = 2549;            % pressione statica [Pa]

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

ramjet.presaAria.regime     = "supersonico";
ramjet.presaAria.T2         = NaN;
ramjet.presaAria.P2         = NaN;
ramjet.presaAria.T02        = NaN;
ramjet.presaAria.P02        = NaN;
ramjet.presaAria.M2         = NaN;
ramjet.presaAria.eta_d      = NaN;
ramjet.presaAria.rho2       = NaN;
ramjet.presaAria.V2         = NaN;
ramjet.presaAria.CPR        = NaN;

% Parametri fissi/scelti:
ramjet.presaAria.LSuper     = NaN;
ramjet.presaAria.LRampa12   = NaN;
ramjet.presaAria.LRampa23   = NaN;
ramjet.presaAria.hCatt      = NaN;
ramjet.presaAria.hGola      = NaN;
ramjet.presaAria.ACatt      = NaN;
ramjet.presaAria.A2         = NaN;
ramjet.presaAria.piTot      = NaN;
ramjet.presaAria.delta1     = deg2rad(16);
ramjet.presaAria.delta2     = deg2rad(20);
ramjet.presaAria.theta1     = deg2rad(30);
ramjet.presaAria.theta2     = deg2rad(43);
ramjet.presaAria.delta3     = NaN;
ramjet.presaAria.deltaS     = NaN;

%---------------------------------------------------------------------
%% ANULUS
%---------------------------------------------------------------------


ramjet.anulus.T03   = NaN;   % Temperatura totale in uscita
ramjet.anulus.P03   = NaN;   % Pressione totale in uscita
ramjet.anulus.T3    = NaN;   % Temperatura in uscita
ramjet.anulus.P3    = NaN;   % Pressione in uscita
ramjet.anulus.AIn   = NaN;   % Area di ingresso dell'anulus
ramjet.anulus.AOut  = NaN;   % Area di uscita
ramjet.anulus.rIn   = NaN;   % Raggio esterno all'entrata del casing
ramjet.anulus.rOut  = NaN;   % Raggio esterno all'uscita del casing
ramjet.anulus.mach3 = 0.6;   % Numero di mach in uscita
ramjet.anulus.U     = NaN;   % Velocità in uscita


%---------------------------------------------------------------------
%% CAMERA DI COMBUSTIONE
%---------------------------------------------------------------------
ramjet.camera.Tmax    = 2100;        % Temperatura massima  [K]
ramjet.camera.pi_ab   = 0.96;        % Rendimento pneumatico
ramjet.camera.r       = NaN;         % Raggio camera di combustione/postbruciatore
ramjet.camera.LH      = 0.3;         % Rapporto lunghezza/diametro
ramjet.camera.B       = 0.25;        % Bloccaggio
ramjet.camera.etaC    = 0.98;        % Efficienza di combustione
ramjet.camera.machIn  = 0.25;         % Numero di mach in ingresso

ramjet.camera.mach4   = NaN;          % Numero di mach in uscita
ramjet.camera.T04     = NaN;          % Temperatura in uscita
ramjet.camera.P04     = NaN;          % Pressione in uscita
ramjet.camera.f       = NaN;
ramjet.camera.d       = NaN;          % Diametro stabilizzatore di fiamma
ramjet.camera.L       = NaN;          % Lunghezza camera

%---------------------------------------------------------------------
%% UGELLO
%---------------------------------------------------------------------
ramjet.ugello.etaN  = 0.95;             % Rendimento
ramjet.ugello.P05   = NaN;              % Pressione totale in uscita
ramjet.ugello.T05   = NaN;              % Temperatura totale in uscita
ramjet.ugello.mach5 = NaN;              % Numero di Mach
ramjet.ugello.Ue    = NaN;              % velocità di efflusso
ramjet.ugello.AStar = NaN;              % area di gola
ramjet.ugello.AE    = NaN;              % area di efflusso
ramjet.ugello.DE    = NaN;              % diametro di efflusso
ramjet.ugello.PE    = NaN;              % Pressione di efflusso
ramjet.ugello.P0E   = NaN;              % Pressione totale di efflusso
ramjet.ugello.piC   = 2.5;


%---------------------------------------------------------------------
%% PERFORMANCE
%---------------------------------------------------------------------
ramjet.performance.F         = NaN;
ramjet.performance.etaGlobal = NaN;
ramjet.performance.etaTh     = NaN;
ramjet.performance.ISP       = NaN;
ramjet.performance.TSFC      = NaN;
ramjet.performance.etaProp   = NaN;

ramjet.turbina.rt5           = 0.4;

end