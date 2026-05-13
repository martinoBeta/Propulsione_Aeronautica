function [motore] = Ugello(motore)
% Calcolo parametri per ugello (subsonico), viene assunta espansione ottima



%% estrazione variabili
PU    = motore.freestream.h12km.P0; % pressione a z=12000m [Pa]
TU    = motore.freestream.h12km.T0; % temperatura esterna [K]
gamma = motore.fluidi.gas.gamma;
R     = motore.fluidi.gas.R;
Cp    = motore.fluidi.gas.cp;
T0I   = motore.turbina.T05;
P0I   = motore.turbina.P05;
mach  = motore.turbina.mach5;
mdot  = motore.portate.mDotGas; % portata
eta_n = motore.ugello.etaN;

%% calcolo gradenzze
TI  = T0I/(1+(gamma-1)*mach/2);
P0I = P0I*0.98; %Pressione totale persa per afterburner (non attivo)
NPR = P0I/PU; %Nozzle Pressure Ratio

TU_is = T0I*((NPR)^((1-gamma)/gamma)); % temperatura in uscita (ideale)
TU    = T0I - eta_n*(T0I-TU_is); % temperatura in uscita

Ue  = sqrt(2*Cp*(T0I-TU)); % velocità di efflusso
mach = Ue/sqrt(gamma*R*TU);    %mach di efflusso

T0U = TU*(1+((gamma-1)/2)*mach^2); % temperatura totale di efflusso
P0U = PU*(1+((gamma-1)/2)*mach^2)^(gamma/(gamma-1)); % pressione totale di efflusso

AStar = mdot*sqrt(R*T0I)/( P0I*sqrt(gamma)*(2/(gamma+1))^((gamma+1)/(2*(gamma-1)))); % area di gola
AE    = (AStar/mach)*((((2+(gamma-1))*(mach^2))/(gamma+1))^((gamma+1)/(2*(gamma-1)))); %area di efflusso
DE    = 2*sqrt(AE/pi); %diametro di efflusso
DStar = 2*sqrt(AStar/pi); %diametro di gola


%% assegnazione variabili
motore.ugello.mach6 = mach;
motore.ugello.Ue    = Ue;       % velocità di efflusso
motore.ugello.AStar = AStar;    % area di gola
motore.ugello.AE    = AE;       % area di efflusso
motore.ugello.DE    = DE;       % diametro di efflusso  

motore.ugello.P06   = P0U;
motore.ugello.T06   = T0U;

end