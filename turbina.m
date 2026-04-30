function [P0U, T0U, mach, Q, L_turbina, eta_n] = turbina(P0I,T0I, mach, L_compressore,propFluidi,propMotore)
    % funzione che calcola prestazione della turbina
    
    %% 
    propTurbina = propMotore.Turbina;

    % portate
    mdot = propMotore.mdot;
    mAir = propMotore.mAir;
    cool_perc = propTurbina.cool_perc;
    gammaCob = propFluidi.gamma;
    
    
    % Aria spillata per rafreddamento turbina. 
    mcool = mAir*cool_perc;
    
    % Cp
    cpO = propFluidi.cpOx;
    cpF = propFluidi.cpFuel;
    
    
    % Lavoro ideale
    L_turbina = L_compressore;
    L_turbina_ideale = L_turbina/propTurbina.eta_b;

    %Calcolo del Delta T
    DeltaT = L_turbina_ideale/(cpO*(mdot));


    % Calcolo della temperatura e pression di uscita della turbina
    T0U = T0I - DeltaT;
    P0U_ideale = P0I*(T0I/T0U)^(gammaCob/(1-gammaCob));

    % Pressione di usicta reale Turbina utlizzando il rendimento pneumatico
    P0U = P0U_ideale*propTurbina.eta_p;

    


end