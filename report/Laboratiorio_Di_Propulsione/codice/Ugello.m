function [motore] = Ugello(motore)
% UGELLO Funzione che calcola le condizioni di uscita del 
% flusso dal ugello subsonico
% 
%  [motore] = Ugello(motore)


%% estrazione variabili
PU    = motore.freestream.h12km.P0; % pressione a z=12000m [Pa]
TU    = motore.freestream.h12km.T0; % temperatura esterna [K]
gamma = motore.fluidi.gas.gamma;
R     = motore.fluidi.gas.R;
Cp    = motore.fluidi.gas.cp;
T0I   = motore.turbina.T05;
P05   = motore.turbina.P05;
mach  = motore.turbina.mach5;
mdot  = motore.portate.mDotGas; % portata
eta_n = motore.ugello.etaN;
pi_n  = motore.ugello.piN;

% calcolo gradenzze
P0I = P05*pi_n;
TI  = T0I/(1 + (gamma-1)/2 * mach^2);
NPR = P0I/PU; %Nozzle Pressure Ratio

TE_is = T0I*((NPR)^((1-gamma)/gamma));   % temperatura in uscita (ideale)
TE    = T0I - eta_n*(T0I-TE_is);         % temperatura in uscita

Ue    = sqrt(2*Cp*(T0I-TE));    % velocità di efflusso
mach6 = Ue/sqrt(gamma*R*TE);    % mach di efflusso

T0U = T0I; % temperatura totale di efflusso
P0U = PU*(1+((gamma-1)/2)*mach6^2)^(gamma/(gamma-1)); % pressione totale di efflusso

AStar = (mdot/P0I)*sqrt(R*T0I/gamma)*((gamma+1)/2)^((gamma+1)/(2*(gamma-1))); % area di gola
AE    = (AStar/mach6)*((2/(gamma+1))*(1+(gamma-1)/2*mach6^2))^((gamma+1)/(2*(gamma-1))); %area di efflusso
DE    = 2*sqrt(AE/pi); %diametro di efflusso
DStar = 2*sqrt(AStar/pi); %diametro di gola


%% assegnazione variabili
motore.ugello.mach6 = mach6;
motore.ugello.Ue    = Ue;       % velocità di efflusso
motore.ugello.AStar = AStar;    % area di gola
motore.ugello.AE    = AE;       % area di efflusso
motore.ugello.DE    = DE;       % diametro di efflusso  

motore.ugello.P06   = P0U;
motore.ugello.T06   = T0U;

end