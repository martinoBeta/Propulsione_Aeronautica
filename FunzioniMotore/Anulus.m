function [ramjet] = Anulus(ramjet)
% funzione che permette di dimensionare l'anulus del ramjet

%% Estrazione Variabili
T0I           = ramjet.presaAria.T02;     % Temperatura totale in ingresso
P0I           = ramjet.presaAria.P02;     % Pressione totale in ingresso
machIn        = ramjet.presaAria.M2;      % Numero di Mach
rRam          = ramjet.turbina.rt5;       % Raggio interno
mdot          = ramjet.portate.mDot;      % Portata
rho           = ramjet.presaAria.rho2;
VIn           = ramjet.presaAria.V2;
machOut       = ramjet.anulus.mach3;
gamma         = ramjet.fluidi.aria.gamma;
R             = ramjet.fluidi.aria.R;

%% Calcolo Grandezze
AreaIn = mdot/(rho*VIn);
rIn    = sqrt(AreaIn/pi + rRam^2); % Raggio dell'anulus all'entrata

AreaOut = AreaIn * (machIn/machOut) * ((1 + (gamma-1)/2 * machOut^2) ...
          / (1 + (gamma-1)/2 * machIn^2)) ^ ((gamma+1)/(2*(gamma-1)));
rOut    = sqrt(AreaOut/pi + rRam^2);

TU = T0I/(1+(gamma-1)/2*machOut^2);
PU = P0I*(TU/T0I)^(gamma/(gamma-1));

U=sqrt(gamma*R*TU);

%% Assegnazione Variabili
ramjet.anulus.rIn  = rIn;
ramjet.anulus.rOut = rOut;
ramjet.anulus.AIn  = AreaIn;
ramjet.anulus.AOut = AreaOut;
ramjet.anulus.T03  = T0I;
ramjet.anulus.P03  = P0I;   % suppongo l'intero sistema ideale
ramjet.anulus.T3   = TU;
ramjet.anulus.P3   = PU;
ramjet.anulus.U    = U;


end