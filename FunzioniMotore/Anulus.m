function [ramjet] = Anulus(ramjet)
% funzione che permette di dimensionare l'anulus del ramjet

%% Estrazione Variabili
T0I           = ramjet.presaAria.T02;     % Temperatura totale in ingresso
P0I           = ramjet.presaAria.P02;     % Pressione totale in ingresso
mach          = ramjet.presaAria.mach;    % Numero di Mach
rRam          = motore.turbina.rt5;       % Raggio interno
mdot          = ramjet.portate.mDotAir;   % Portata
rho           = ramjet.presaAria.rho2;
VI            = ramjet.presaAria.V2;

%% Calcolo Grandezze
AreaAnulus = mdot/(Rho*VI);
rAnulus    = sqrt((AreaAnulus/pi) + rRam);  % Raggio dell'anulus

%% Assegnazione Variabili
ramjet.anulus.rRam = rAnulus;
ramjet.anulus.A    = AreaAnulus;
ramjet.anulus.T03  = T0I;
ramjet.anulus.P03  = P0I;   % suppongo l'intero sistema ideale

end