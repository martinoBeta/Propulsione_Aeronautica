
clear
    clc
    close all;


P0I = 50000;
T0I = 1100:1:1800;
mach = 0.3;

propFluidi = structFluidi();%
propMotore = structMotore(structTurbina());
L_compressore = 10.7e6;
mach = 0.3;
P0I = 300000;
T3 = 420;
TCool = T3;
    
etan = [];
coolPecentualeA = [];
Sota = [];

for i = T0I
    [P0U, T0U, mach, Q, L_turbina, eta_n,coolPecentuale,SOT] = turbina1(P0I,i, mach, L_compressore,propFluidi,propMotore,TCool);
    etan = [etan, eta_n];
    coolPecentualeA = [coolPecentualeA,coolPecentuale];
    Sota = [Sota, SOT];
end 

figure();
plot(T0I,etan,"-");
figure();
plot(T0I,coolPecentualeA,"-");
hold on
plot(T0I,propMotore.Turbina.CoolingRotore(Sota))
hold on
plot(T0I,propMotore.Turbina.CoolingStatore(Sota))
legend("total","rotore","statore");
figure
plot(T0I,Sota)






 function [P0U, T0U, mach, Q, L_turbina, eta_n,coolPecentuale,SOT] = turbina1(P0I,T0I, mach, L_compressore,propFluidi,propMotore,TCool)
    %funzione che calcola prestazione della turbina
    %%
    propTurbina = propMotore.Turbina;
    
    % rendimento meccanico 
    eta = propTurbina.eta_b; 
    etaP = propTurbina.eta_p; 

    % portate
    mDot = propMotore.mdot;

    % proprietà fluidi
    gammaCob = propFluidi.gamma;
    cpGas = propFluidi.cp;
    cpAir = propFluidi.cpOx;

    % SOT (non temperatura a fine turbina)
    SOT = 2/(gammaCob+1)*T0I;

    % eps = mc/mtot.  percentuale di aria raffredata .
    coolPecentuale = propTurbina.CoolingRotore(SOT) + propTurbina.CoolingStatore(SOT); 

    % lavoro turbina 
    L_turbina = L_compressore/eta;
    
    %Temperatura ad uscita turbina
    T5 = ((1-coolPecentuale)*cpGas*T0I + coolPecentuale*cpAir*TCool - L_turbina/mDot)/((1-coolPecentuale)*cpGas+coolPecentuale*cpAir);
   
    %miscelamento
    Tm = ((1-coolPecentuale)*cpGas*T0I + coolPecentuale*cpAir*TCool)/((1-coolPecentuale)*cpGas+ coolPecentuale*cpAir);

    % Calcolo della pressione a uscita della turbina
    betaP =  (T5/T0I)^(gammaCob/((gammaCob-1)*etaP));
    P0U = P0I * betaP;

    % temperatura isoentropica
    T05_iso = Tm*(P0I/P0U)^((1-gammaCob)/gammaCob);

    % rendimento adiabatico
    eta_n = L_turbina/(mDot*cpGas*(Tm-T05_iso));
    T0U = T5;

    Q = 0 ;       
end