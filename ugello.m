function [motore] = ugello(motore,propFluidi)
% Calcolo parametri per ugello (subsonico), viene assunta espansione ottima



%% estrazione variabili
PU    = propFluidi.P0; % pressione a z=12000m [Pa]
TU    = propFluidi.T0; % temperatura esterna [K]
gamma = propFluidi.gamma;
R     = propFluidi.R;
Cp    = propFluidi.cp;
T0I   = motore.Ugello.T0I;
P0I   = motore.Ugello.P0I;
mach  = motore.Ugello.mach;
mdot  = motore.portate.mDotGas;

%% calcolo gradenzze
TI  = T0I/(1+(gamma-1)*mach/2);
P0I = P0I*0.97; %Pressione totale persa per afterburner
NPR = P0I/PU; %Nozzle Pressure Ratio

TU_is = T0I*((NPR)^((1-gamma)/gamma)); % temperatura in uscita (ideale)
TU    = T0I - eta_n*(T0I-TU_is); % temperatura in uscita

Ue  = sqrt(2*Cp*(T0I-TU)); % velocità di efflusso
mach = sqrt(gamma*R*TU); %mach di efflusso

T0U = TU*(1+((gamma-1)/2)*mach^2); % temperatura totale di efflusso
P0U = PU*(1+((gamma-1)/2)*mach^2)^(gamma/(gamma-1)); % pressione totale di efflusso

AStar = mdot*sqrt(R*T0I)/( P0I*sqrt(gamma)*(2/(gamma+1))^((gamma+1)/(2*(gamma-1)))); % area di gola
AE    = (A_star/mach)*((((2+(gamma-1))*(mach^2))/(gamma+1))^((gamma+1)/(2*(gamma-1)))); %area di efflusso
DE    = 2*sqrt(A_e/pi); %diametro di efflusso
DStar = 2*sqrt(A_star/pi); %diametro di gola
% possibile calcolo ingombri?


%% assegnazione variabili
Motore.Ugello.machE = mach;
Motore.Ugello.Ue    = Ue;   % velocità di efflusso
Motore.Ugello.AStar = AStar;   % area di gola
Motore.Ugello.AE    = AE;   % area di efflusso
Motore.Ugello.DE    = DE;   % diametro di efflusso  

end