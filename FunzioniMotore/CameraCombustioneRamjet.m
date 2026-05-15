function [ramjet] = CameraCombustioneRamjet(ramjet)
% CAMERA DI COMBUSTIONE / POSTBRUCIATORE
%
% Funzione che permette di dimensionare la camera di combustione del ramjet
% la quale può essere usata come postbruciatore
%

% Estrazione variabili
T0I  = ramjet.anulus.T03;    % Temperatura totale in ingresso
P0I  = ramjet.anulus.P03;    % Pressione totale in ingresso
mach = ramjet.camera.mach;   % Numero di Mach
PiAB = ramjet.camera.pi_ab;  % Perdita di carico
Mdot = ramjet.camera.


% Calcolo grandezze


% Assegnazione variabili

end