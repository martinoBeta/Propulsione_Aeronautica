function [P0U, T0U, mach, Q, L, Ue, eta_n] = ugello(P0I,T0I, mach, mdot)
% Calcolo parametri per ugello (subsonico), viene assunta espansione ottima
% ed un ugello adiabatico
%
% INPUT:
% POI = Pressione totale in ingresso
% T0I = Temperatura totale in ingresso
% TI = Temperatura statica in ingresso
% PI = Pressione statica in ingresso
% mach = numero di mach
% mdot = portata
% L = lavoro compiuto
%
% OUTPUT:
% P0U = Pressione totale in uscita
% T0U = Temperatura totale in uscita
% mach = numero di mach in uscita
% Q = calore scambiato
% L = lavoro scambiato
% Ue = Velocità di efflusso
% eta_n = Rendimento


% costanti
PU = 19400; % pressione a z=12000m [Pa]
TU = 220.15; % temperatura esterna [K]
gamma = 1.33;
R = 286.58;
Cp = 3.5*R;

%calcolo gtadenzze statiche
TI = T0I/(1+(gamma-1)*mach/2);

NPR = P0I/PU; %Nozzle Pressure Ratio


T0U = T0I;
Q = 0;
L = 0;
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