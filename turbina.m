function [motore] = turbina(propFluidi,motore)
    %funzione che calcola prestazione della turbina
    %%
    
    % INIZIALIZZAZIONE DELLE VARIABILI
    propTurbina = motore.Turbina;
    
    % TURBINA INPUT
    T0I = propTurbina.T0I;
    P0I = propTurbina.P0I;
    machIn = propTurbina.machIn;

    L_compressore = motore.Compressore.L_compressore; % NOTARE CAMBIARE NOME A QUELLO AGGIORNATO
    TCool =  propTurbina.TCool;
    
    % TURBINA CONSTANTI
    eta_m = propTurbina.eta_m; 
    etaP = propTurbina.eta_p; 

    % portate
    mDot = motore.mdot;

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
    T0U_iso = T0m*betaP^((gammaCob-1)/gammaCob);

    % Lavoro isoentropico non rafreddato
    L_iso_no_raff = cpGas*mDot*(T0I-T0U_iso);

    % Lavoro isoenbtropico rafreddato
    L_iso_raff = mDot*((1-coolPecentuale)*cpGas*(T0I-T0U_iso) +(coolPecentuale)*cpAir*(TCool-T0U_iso));
 
    % rendimento adiabatico
   
    eta_n = L_turbina/L_iso_raff;
    eta_NC = L_turbina/L_iso_no_raff;
    T0U = T05;
    
    % INLET TURBINE
    T4 = T0I /(1+(gammaCob-1)/2*machIn.^2);
    P4 =  P0I / (1 + (gammaCob - 1)/2 * machIn^2)^(gammaCob/(gammaCob - 1));
    v4z = machIn*sqrt(RGas*gammaCob*T4);
    rho4 = P4 / (RGas * T4);
    AIn = mDot*(1-coolPecentuale)/(rho4*v4z);

    % OUTLET TURBINE
    v5z = v4z;                  %velocità assiale costante
    T5 = T05 - v5z^2/(2*cpGas);
    machOut = sqrt((2/(gammaCob-1)) * ((T05/T5) - 1));
    P5 =  P0U / (1 + (gammaCob - 1)/2 * machOut^2)^(gammaCob/(gammaCob - 1));
    rho4 = P5 / (RGas * T5);
    AOut = mDot/(rho4*v5z);
    
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



    % AGGIORNAMENTO DEGLI OUTPUT
    % output
    propTurbina.P0U = P0U;
    propTurbina.T0U = T0U;
    propTurbina.T0U_iso = T0U_iso;
    propTurbina.machOut = machOut;

    % Lavoro e rendimento
    propTurbina.L_turbina = L_turbina;
    propTurbina.eta_n = eta_n;
    
    % rendimento isoentropico rispetto a caso che non necessita rafreddamento
    propTurbina.eta_NC = eta_NC;             
    
    % Percentuale raffredamento
    propTurbina.coolPecentuale = coolPecentuale;
    propTurbina.SOT = SOT;

    % Sezioni
    propTurbina.AIn = AIn;
    propTurbina.AOut = AOut;



    motore.Turbina = propTurbina;

end