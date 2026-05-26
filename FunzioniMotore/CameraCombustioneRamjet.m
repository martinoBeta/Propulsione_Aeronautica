function [ramjet] = CameraCombustioneRamjet(ramjet)
% CAMERA DI COMBUSTIONE / POSTBRUCIATORE
%
% Funzione che permette di dimensionare la camera di combustione del ramjet
% la quale può essere usata come postbruciatore
%

% Estrazione variabili
T0I           = ramjet.anulus.T03;     % Temperatura totale in ingresso
P0I           = ramjet.anulus.P03;     % Pressione totale in ingresso
mach          = ramjet.presaAria.mach;    % Numero di Mach
PiAB          = ramjet.camera.pi_ab;   % Perdita di carico
mDotAir       = ramjet.portate.mDot; % Portata di aria in ingresso
TMax          = ramjet.camera.Tmax;    % Temperatura massima raggiungibile
LH            = ramjet.camera.LH;      % Rapporto Lunghezza/Diametro
B             = ramjet.camera.B;       % Bloccaggio
ChamberRadius = ramjet.camera.r;       % Raggio camera

CpA = ramjet.fluidi.aria.cp;            % Cp dell'aria in ingresso
gammaA = ramjet.fluidi.aria.gamma;      % gamma dell'aria in ingresso
RA = ramjet.fluidi.aria.R;              % R dell'aria in ingresso


CpG    = ramjet.fluidi.gas.cp;           % Cp dei gas combusti
gammaG = ramjet.fluidi.gas.gamma;        % Gamma dei gas combusti
DeltaH = ramjet.fluidi.combustibile.LHV; % Entalpia di combustione
EtaC   = ramjet.camera.etaC;



% Calcolo grandezze

P0U = P0I*PiAB;
T0U = TMax;    
f        = (CpG*TMax - CpA*T0I)/(DeltaH*EtaC- CpG*TMax);
mDotFuel = mDotAir*f;         % Portata di carburante
mDotGas  = mDotFuel+mDotAir;  % Portata totale in uscita


ChamberLength = ChamberRadius*LH;
FlameHolderD  = B*ChamberRadius;  % Diametro degli stabilizzatori di fiamma

mach4 = sqrt(gammaG*RA*TMax);


% Assegnazione variabili

ramjet.camera.T04       = T0U;
ramjet.camera.P04       = P0U;
ramjet.camera.f         = f;
ramjet.camera.L         = ChamberLength;
ramjet.camera.d         = FlameHolderD;
ramjet.camera.mach4     = mach4;
ramjet.portate.mDotComb = mDotFuel;
ramjet.portate.mDotGas  = mDotGas;

end