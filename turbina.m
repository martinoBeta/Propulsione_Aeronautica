function [P0U, T0U, T05_iso, machOut, L_turbina, eta_n,coolPecentuale,SOT,eto,A4,A5] = turbina(propFluidi,propMotore)
    %funzione che calcola prestazione della turbina
    %%
    
    % INIZIALIZZAZIONE DELLE VARIABILI
    propTurbina = propMotore.Turbina;
    
    % TURBINA INPUT
    T0I = propTurbina.T0I;
    P0I = propTurbina.P0I;
    machIn = propTurbina.machIn;

    L_compressore = propMotore.Compressore.Lavoro; % NOTARE CAMBIARE NOME A QUELLO AGGIORNATO
    TCool =  propTurbina.TCool;
    
    % TURBINA CONSTANTI
    eta_m = propTurbina.eta_m; 
    etaP = propTurbina.eta_p; 

    % portate
    mDot = propMotore.mdot;

    % proprietà fluidi
    gammaCob = propFluidi.gamma;
    cpGas = propFluidi.cp;
    cpAir = propFluidi.cpOx;
    RGas = propFluidi.R;

    % SOT (non temperatura a fine turbina)
    SOT = 2/(gammaCob+1)*T0I;

    % eps = mc/mtot.  percentuale di aria raffredata .
    coolPecentuale = propTurbina.CoolingRotore(SOT) + propTurbina.CoolingStatore(SOT); 

    % lavoro turbina 
    L_turbina = L_compressore/eta_m;
    
    %Temperatura ad uscita turbina isoentropica
    T05 = ((1-coolPecentuale)*cpGas*T0I + coolPecentuale*cpAir*TCool - L_turbina/mDot)/((1-coolPecentuale)*cpGas+coolPecentuale*cpAir);
   
    %miscelamento
    T0m = ((1-coolPecentuale)*cpGas*T0I + coolPecentuale*cpAir*TCool)/((1-coolPecentuale)*cpGas+ coolPecentuale*cpAir);

    % Calcolo della pressione a uscita della turbina
    betaP =  (T05/T0m)^(gammaCob/((gammaCob-1)*etaP));
    P0U = P0I * betaP;

    % temperatura isoentropica
    T05_iso = T0m*betaP^((gammaCob-1)/gammaCob);

    % Lavoro isoentropico non rafreddato
    L_iso_no_raff = cpGas*mDot*(T0I-T05_iso);

    % Lavoro isoenbtropico rafreddato
    L_iso_raff = mDot*((1-coolPecentuale)*cpGas*(T0I-T05_iso) +(coolPecentuale)*cpAir*(TCool-T05_iso));
 
    % rendimento adiabatico
   
    eta_n = L_turbina/L_iso_raff;
    eto = L_turbina/L_iso_no_raff;
    T0U = T05;
    
    % INLET TURBINE
    T4 = T0I /(1+(gammaCob-1)/2*machIn.^2);
    P4 =  P0I / (1 + (gammaCob - 1)/2 * machIn^2)^(gammaCob/(gammaCob - 1));
    v4z = machIn*sqrt(RGas*gammaCob*T4);
    rho4 = P4 / (RGas * T4);
    A4 = mDot*(1-coolPecentuale)/(rho4*v4z);

    % OUTLET TURBINE
    v5z = v4z;                  %velocità assiale costante
    T5 = T05 - v4z^2/(2*cpGas);
    machOut = sqrt((2/(gammaCob-1)) * ((T05/T5) - 1));
    P5 =  P0U / (1 + (gammaCob - 1)/2 * machOut^2)^(gammaCob/(gammaCob - 1));
    rho4 = P5 / (RGas * T5);
    A5 = mDot/(rho4*v5z);
    
    %% STADIO

    % STATORE
    % assunzione che cooling viene applicato prima di espandere in turbina
    % espansione in statore fino a mach 1: (tutte queste quantità dopo espansione fino a mach 1)
    TStatore = T0I/(1+(1+gammaCob)/2);
    PStatore = P0I / (1 + (gammaCob - 1)/2)^(gammaCob/(gammaCob - 1));
    rhoStatore =  PStatore / (RGas * TStatore);
    vzStatore = v4z;
    vStatore = sqrt(gammaCob*RGas*TStatore);
    vtStatore = sqrt(vStatore^2-vzStatore^2);
    alpha = atan(vtStatore/vzStatore);
    AStatore = mDot/(rhoStatore*vStatore);
  
    %{
        






    %} 
end