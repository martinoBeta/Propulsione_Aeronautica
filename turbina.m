function [P0U, T0U, mach, Q, L_turbina, eta_n] = turbina(P0I,T0I, mach, L_compressore,propFluidi,propMotore)
    % funzione che calcola prestazione della turbina
    %%
    clear
    clc
    propFluidi = structFluidi();
    propMotore = structMotore(structTurbina());
    L_compressore = 40000;
    mach = 0.3;
    T0I = propMotore.Tmax;
    P0I = 300000;
    Tcool = 600;

    %% 
    propTurbina = propMotore.Turbina;

    % portate
    mDot = propMotore.mAir*(1-propMotore.aria_spillata)+propMotore.mFuel;
    gammaCob = propFluidi.gamma;

    % Cp
    cpO = propFluidi.cpOx;
    cp = propFluidi.cp;

    % R di combusti
    R = cp * (gammaCob - 1)/gammaCob;
   


    %% STADIO 1
    % STATORE
    % calcolo velocità di ingresso
    vz1 = sqrt(T0I*R*gammaCob)*mach;

    %calcolo di aria compresa quella per rafreddare
    mCool_statore1 = propMotore.mAir*propTurbina.Cooling_statore(T0I);
    mDot_statore1 = mDot+mCool_statore1;
    
    % miscelazione adiabatica non area aggiunta per cooling
    T02 = (cp*T0I*mDot+cpO*Tcool*mCool_statore1)/(mDot*cp+mCool_statore1*cpO);
    T03 = T02;
    
    % T3 isoentropica 
    T3_is = T03*2/(1+gammaCob);
    v3_is = sqrt(gammaCob*R*T3_is);
    vz3 = vz1;
    
    % calcolo della T03 vera della turbina.
    T3 = (cp*T3_is + propTurbina.eps_stadio(180/pi*acos(vz3/v3_is))*v3_is^2/2)/cp;

    v3 = sqrt((T03-T3)*2*cp);
    vt3 = sqrt(v3^2-vz3^2);

    % angolo di variazione velocità
    alpha = 180/pi*acos(vz3/v3);

    % velocità tangenziale palette (inposto R = 0, e vt5 = 0)
    U = vt3/2;

    % velocita relativa
    wt3 = vt3 - U;
    wz3 = vz3;
    

    % ROTORE
    mCool_rotore1 = propMotore.mAir*propTurbina.Cooling_rotore(T03);
    mDot_rotore1 = mDot_statore1 + mCool_rotore1;

    % miscelazione adiabatica non area aggiunta per cooling
    T04 = (cp*T03*mDot_statore1+cpO*Tcool*mCool_statore1)/(mDot_statore1*cp+cpO*mCool_statore1);
    T4_is = T04 - v3^2/(2*cp);

    % calcolo velocità conoscendo vt5 = 0;
    v5 = vz3;

    % calcolo v5
    vz5 = vz3;
    vt5 = sqrt(v5^2-vz5^2);
    wt5 = U - vt5;
    wz5 = vz5;
    w5 = sqrt(wt5^2+wz5^2);
    beta = 180/pi*atan(wt5/wz5);
    deltaA = alpha - beta;

    % calcolo T4 statica per poi potere calcolare;
    T4 = (T4_is*cp + propTurbina.eps_stadio(deltaA)*w5^2/2)/cp;
    T5 = T4;
    T05 = T5 + v5^2/(2*cp);

    L_turbina = mDot_rotore1*cp*(T0I-T05);

    %rendimento totale-totale
    eta_tt = (T0I - T05) / ((T0I - T05) + (T3 - T3_is) + (T4 - T4_is)); 

    % Temperatura finale isentropica
    T05s = T0I - (T0I - T05) / eta_tt;
    
    % Ricava la pressione totale d'uscita
    P05 = P0I * (T05s / T0I)^(gammaCob / (gammaCob - 1));


    



    



    % Lavoro ideale
    % L_turbina = L_compressore;

    
    

    


end