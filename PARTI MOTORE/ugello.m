function [motore] = ugello(motore,propFluidi)
% Calcolo parametri per ugello (subsonico), viene assunta espansione ottima


% estrazione variabili
PU = propFluidi.P0; % pressione a z=12000m [Pa]
TU = propFluidi.T0; % temperatura esterna [K]
gamma = propFluidi.gamma;
R = propFluidi.R;
Cp = propFluidi.cp;
T0I = motore.Ugello.T0I;
P0I = motore.Ugello.P0I;
mach = motore.Ugello.mach;

%calcolo gradenzze
TI = T0I/(1+(gamma-1)*mach/2);
NPR = P0I/PU; %Nozzle Pressure Ratio


T0U = T0I;
P0U = P0I;

pi_n = P0I/PU;

mach = sqrt(((P0U/PU)^((gamma-1)/gamma)-1)*(2/(gamma-1)));

Te = TI*(NPR^((1-gamma)/gamma));

Ue = sqrt(2*Cp*(T0I-Te));

eta_n = 1; % suppongo ugello ideale

A_star = mdot*sqrt(R*T0I)/( P0I*sqrt(gamma)*(2/(gamma+1))^((gamma+1)/(2*(gamma-1)))); % area di gola

A_e = (A_star/mach)*((((2+(gamma-1))*(mach^2))/(gamma+1))^((gamma+1)/(2*(gamma-1)))); %area di efflusso
D_e = 2*sqrt(A_e/pi);


end