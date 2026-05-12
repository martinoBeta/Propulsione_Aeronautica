function [motore] = ugello(motore,propFluidi)
% Calcolo parametri per ugello (subsonico), viene assunta espansione ottima



% estrazione variabili
PU    = propFluidi.P0; % pressione a z=12000m [Pa]
TU    = propFluidi.T0; % temperatura esterna [K]
gamma = propFluidi.gamma;
R     = propFluidi.R;
Cp    = propFluidi.cp;
T0I   = motore.Ugello.T0I;
P0I   = motore.Ugello.P0I;
mach  = motore.Ugello.mach;
mdot  = motore.portate.mDotGas;

%calcolo gradenzze
TI  = T0I/(1+(gamma-1)*mach/2);
P0I = P0I*0.97; %Pressione totale persa per afterburner
NPR = P0I/PU; %Nozzle Pressure Ratio

TU_is = T0I*((NPR)^((1-gamma)/gamma)); % temperatura in uscita (ideale)
TU    = T0I - eta_n*(T0I-TU_is); % temperatura in uscita

U_e  = sqrt(2*Cp*(T0I-TU)); % velocità di efflusso
mach = sqrt(gamma*R*TU); %mach di efflusso

T0U = TU*(1+((gamma-1)/2)*mach^2); % temperatura totale di efflusso
P0U = PU*(1+((gamma-1)/2)*mach^2)^(gamma/(gamma-1)); % pressione totale di efflusso

A_star = mdot*sqrt(R*T0I)/( P0I*sqrt(gamma)*(2/(gamma+1))^((gamma+1)/(2*(gamma-1)))); % area di gola
A_e    = (A_star/mach)*((((2+(gamma-1))*(mach^2))/(gamma+1))^((gamma+1)/(2*(gamma-1)))); %area di efflusso
D_e    = 2*sqrt(A_e/pi); %diametro di efflusso
D_star = 2*sqrt(A_star/pi); %diametro di gola
% possibile calcolo ingombri?


% assegnazione variabili
Motore.Ugello.mach_e = mach;
Motore.Ugello.Ue     = U_e;   % velocità di efflusso
Motore.Ugello.A_star = A_star;   % area di gola
Motore.Ugello.A_e    = A_e;   % area di efflusso
Motore.Ugello.D_e    = D_e;   % diametro di efflusso  

end