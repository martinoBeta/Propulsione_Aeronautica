function [motore] = structRamjet()
%FUNZIONE NON COMPLETATA DATI NON ATTENDIBILI!!!!
%%
% 0  --> flusso indisturbato
% 2  --> uscita presa d'aria
% 3 --> uscita anulus
% 4  --> uscita camera di combustione
% 5  --> uscita ugello

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
%% FREE STREAM
%---------------------------------------------------------------------

%% Condizioni atmosferiche a 12000 m (ISA)
M0  = 3.5;             % numero di Mach di volo [-]
T0  = 133.65;           % temperatura statica [K]
P0  = 1296;            % pressione statica [Pa]

gamma = 1.4;
R = 287.05;

T00 = T0 * (1 + (gamma - 1)/2 * M0^2);  % temperatura totale [K]
P00 = P0 * (1 + (gamma - 1)/2 * M0^2)^(gamma/(gamma - 1)); % pressione totale [Pa]

rho0 = P0 / (R * T0);          % densità statica [kg/m³]
a0   = sqrt(gamma * R * T0);   % velocità del suono [m/s]
V0   = a0 * M0;                % velocità di volo [m/s]

motore.freestream.h25km.T0 = T0;
motore.freestream.h25km.P0 = P0;
motore.freestream.h25km.T00 = T00;
motore.freestream.h25km.P00 = P00;
motore.freestream.h25km.rho0 = rho0;
motore.freestream.h25km.M0 = M0;
motore.freestream.h25km.V0 = V0;
motore.freestream.h25km.a0 = a0;
end