function [ramjet] = CameraCombustioneRamjet(ramjet)
% CAMERA DI COMBUSTIONE / POSTBRUCIATORE
%
% Funzione che permette di dimensionare la camera di combustione del ramjet
% la quale può essere usata come postbruciatore
%

% Estrazione variabili
T0I     = ramjet.anulus.T03;    % Temperatura totale in ingresso
P0I     = ramjet.anulus.P03;    % Pressione totale in ingresso
mach    = ramjet.camera.mach;   % Numero di Mach
PiAB    = ramjet.camera.pi_ab;  % Perdita di carico
mDotAir = ramjet.camera.mDotAir; % Portata di aria in ingresso
TMax    = ramjet.camera.Tmax;    % Temperatura massima raggiungibile

CpA = ramjet.aria.cp;   % Cp dell'aria in ingresso
gammaA = ramjet.aria.gamma; % gamma dell'aria in ingresso
RA = ramjet.aria.R;  % R dell'aria in ingresso


% Calcolo grandezze


% Assegnazione variabili

end