function [P0U, T0U, T05_iso, mach, Q, L_turbina, eta_n,coolPecentuale,SOT,eto] = turbina(P0I,T0I, mach, L_compressore,propFluidi,propMotore,TCool)
    %funzione che calcola prestazione della turbina
    %%
    propTurbina = propMotore.Turbina;
    
    % rendimento meccanico 
    eta_m = propTurbina.eta_m; 
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
    L_turbina = L_compressore/eta_m;
    
    %Temperatura ad uscita turbina isoentropica
    T5 = ((1-coolPecentuale)*cpGas*T0I + coolPecentuale*cpAir*TCool - L_turbina/mDot)/((1-coolPecentuale)*cpGas+coolPecentuale*cpAir);
   
    %miscelamento
    Tm = ((1-coolPecentuale)*cpGas*T0I + coolPecentuale*cpAir*TCool)/((1-coolPecentuale)*cpGas+ coolPecentuale*cpAir);

    % Calcolo della pressione a uscita della turbina
    betaP =  (T5/Tm)^(gammaCob/((gammaCob-1)*etaP));
    P0U = P0I * betaP;

    % temperatura isoentropica
    T05_iso = Tm*betaP^((gammaCob-1)/gammaCob);

    % Lavoro isoentropico non rafreddato
    % cpBalance = cpGas*(1-coolPecentuale) + cpAir*coolPecentuale;    % Cp bilanciato 
    L_iso_no_raff = cpGas*mDot*(1-coolPecentuale)*(T0I-T05_iso);

    % Lavoro isoenbtropico rafreddato
    L_iso_raff = mDot*((1-coolPecentuale)*cpGas*(T0I-T05_iso) +(coolPecentuale)*cpAir*(TCool-T05_iso));
 
    % rendimento adiabatico
   
    eta_n = L_turbina/L_iso_raff;
    eto = L_turbina/L_iso_no_raff;
    T0U = T5;

    Q = 0 ;       
end