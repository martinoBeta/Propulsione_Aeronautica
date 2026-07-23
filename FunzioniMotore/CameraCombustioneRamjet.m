function [ramjet] = CameraCombustioneRamjet(ramjet, motore)

%% Estrazione variabili
T0I      = ramjet.anulus.T03;
P0I      = ramjet.anulus.P03;
machIn   = ramjet.camera.machIn;
U        = ramjet.anulus.U;
PiAB     = ramjet.camera.pi_ab;
mDotAir  = ramjet.portate.mDot;
TMax     = ramjet.camera.Tmax;
LH       = ramjet.camera.LH;
B        = ramjet.camera.B;
CpA      = ramjet.fluidi.aria.cp;
gammaA   = ramjet.fluidi.aria.gamma;
RA       = ramjet.fluidi.aria.R;
CpG      = ramjet.fluidi.gas.cp;
gammaG   = ramjet.fluidi.gas.gamma;
RG       = ramjet.fluidi.gas.R;         
DeltaH   = ramjet.fluidi.combustibile.LHV;
EtaC     = ramjet.camera.etaC;


%% Calcolo grandezze

ChamberArea = mDotAir * sqrt(T0I) / (P0I * machIn * sqrt(gammaA/RA) * ...
             (1 + (gammaA-1)/2 * machIn^2)^(-(gammaA+1)/(2*(gammaA-1))));
ChamberRadius = sqrt(ChamberArea / pi);
ChamberLength = 2 * ChamberRadius * LH;
FlameHolderD  = B * ChamberRadius;

T0U      = TMax;
P0U      = P0I*PiAB;
f        = (CpG*TMax-CpA*T0I)/(DeltaH*EtaC-CpG*TMax);
mDotFuel = mDotAir*f;
mDotGas  = mDotFuel+mDotAir;

mach4     = U/sqrt(gammaG*RG*TMax);

%% Assegnazione variabili
ramjet.camera.T04       = T0U;
ramjet.camera.P04       = P0U;
ramjet.camera.f         = f;
ramjet.camera.L         = ChamberLength;
ramjet.camera.d         = FlameHolderD;
ramjet.camera.r         = ChamberRadius;
ramjet.camera.A         = ChamberArea;
ramjet.camera.mach4     = mach4;
ramjet.portate.mDotComb = mDotFuel;
ramjet.portate.mDotGas  = mDotGas;
end