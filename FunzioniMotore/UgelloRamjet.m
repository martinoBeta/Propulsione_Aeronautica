function [ramjet] = UgelloRamjet(ramjet)
% Calcolo parametri per ugello (supersonico), viene assunta espansione ottima



%% estrazione variabili
PU    = ramjet.freestream.h25km.P0; % pressione a z=12000m [Pa]
TU    = ramjet.freestream.h25km.T0; % temperatura esterna [K]
gamma = ramjet.fluidi.gas.gamma;
R     = ramjet.fluidi.gas.R;
Cp    = ramjet.fluidi.gas.cp;
T0I   = ramjet.camera.T04;
P0I   = ramjet.camera.P04;
mach  = ramjet.camera.mach4;
mdot  = ramjet.portate.mDotGas; % portata
eta_n = ramjet.ugello.etaN;

%% calcolo gradenzze
TI = T0I/(1 + (gamma-1)/2 * mach^2);
P0I = P0I*0.98; %Pressione totale persa per afterburner (non attivo)
NPR = P0I/PU; %Nozzle Pressure Ratio

TE_is = T0I*((NPR)^((1-gamma)/gamma)); % temperatura in uscita (ideale)
TE    = T0I - eta_n*(T0I-TE_is); % temperatura in uscita

Ue  = sqrt(2*Cp*(T0I-TE)); % velocità di efflusso
mach = Ue/sqrt(gamma*R*TE);    %mach di efflusso

T0U = T0I; % temperatura totale di efflusso
P0U = PU*(1+((gamma-1)/2)*mach^2)^(gamma/(gamma-1)); % pressione totale di efflusso

AStar = (mdot/P0I)*sqrt(R*T0I/gamma)*((gamma+1)/2)^((gamma+1)/(2*(gamma-1))); % area di gola
AE    = (AStar/mach)*((2/(gamma+1))*(1+(gamma-1)/2*mach^2))^((gamma+1)/(2*(gamma-1))); %area di efflusso
DE    = 2*sqrt(AE/pi); %diametro di efflusso
DStar = 2*sqrt(AStar/pi); %diametro di gola


%% assegnazione variabili
ramjet.ugello.mach5 = mach;
ramjet.ugello.Ue    = Ue;       % velocità di efflusso
ramjet.ugello.AStar = AStar;    % area di gola
ramjet.ugello.AE    = AE;       % area di efflusso
ramjet.ugello.DE    = DE;       % diametro di efflusso  

ramjet.ugello.P05   = P0U;
ramjet.ugello.T05   = T0U;

end