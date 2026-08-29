function [ramjet] = UgelloRamjet(ramjet)
% UGELLORAMJET Funzione che calcola le condizioni di uscita 
% del flusso dal ugello del ramjet (supersonico)
% 
% [ramjet] = UgelloRamjet(ramjet)



%% estrazione variabili
PU    = ramjet.freestream.h25km.P0; % pressione a z=12000m [Pa]
TU    = ramjet.freestream.h25km.T0; % temperatura esterna [K]
gamma = ramjet.fluidi.gas.gamma;
R     = ramjet.fluidi.gas.R;
Cp    = ramjet.fluidi.gas.cp;
T0I   = ramjet.camera.T04;
P0I   = ramjet.camera.P04;
mach4  = ramjet.camera.mach4;
mdot  = ramjet.portate.mDotGas; % portata
eta_n = ramjet.ugello.etaN;
piC   = ramjet.ugello.piC;

%% calcolo gradenzze
TI  = T0I/(1 + (gamma-1)/2 * mach4^2);
PE  = piC*PU; % Pressione in uscita
NPR = P0I/PE; % Nozzle Pressure Ratio

TE_is = T0I*((NPR)^((1-gamma)/gamma)); % temperatura in uscita (ideale)
TE    = T0I - eta_n*(T0I-TE_is); % temperatura in uscita

Ue  = sqrt(2*Cp*(T0I-TE)); % velocità di efflusso
mach5 = Ue/sqrt(gamma*R*TE);    %mach di efflusso

T0U = T0I; % temperatura totale di efflusso
P0E = PE*(1+((gamma-1)/2)*mach5^2)^(gamma/(gamma-1)); % pressione totale di efflusso

AStar = (mdot/P0I)*sqrt(R*T0I/gamma)*((gamma+1)/2)^((gamma+1)/(2*(gamma-1))); % area di gola
AE    = (AStar/mach5)*((2/(gamma+1))*(1+(gamma-1)/2*mach5^2))^((gamma+1)/(2*(gamma-1))); %area di efflusso
DE    = 2*sqrt(AE/pi); %diametro di efflusso
DStar = 2*sqrt(AStar/pi); %diametro di gola


%% assegnazione variabili
ramjet.ugello.mach5 = mach5;
ramjet.ugello.Ue    = Ue;       % velocità di efflusso
ramjet.ugello.AStar = AStar;    % area di gola
ramjet.ugello.AE    = AE;       % area di efflusso
ramjet.ugello.DE    = DE;       % diametro di efflusso  
ramjet.ugello.PE    = PE;
ramjet.ugello.P0E   = P0E;

ramjet.ugello.P05   = P0E;
ramjet.ugello.T05   = T0U;

end