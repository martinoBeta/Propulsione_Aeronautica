function [P0U, T0U, mach, Q, L_turbina, eta_n] = turbina(P0I,T0I, mach, L_compressore,propFluidi,propMotore)
    % funzione che calcola prestazione della turbina
    %%
    clear
    clc

    propFluidi = structFluidi();
    propMotore = structMotore(structTurbina());
    L_compressore = 20.7e6;
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
   
    %% Calcolo lavoro STADIO1

    %% STADIO 2 (_2)
    L_stadio2 = L_compressore*propTurbina.LStadio2;


    % STATORE
    % calcolo velocità di ingresso
    vz1_2 = sqrt(T0I*R*gammaCob)*mach;

    %calcolo di aria compresa quella per rafreddare
    mCoolStatore1_2 = propMotore.mAir*propTurbina.CoolingStatore(T0I);
    mDotStatore1_2 = mDot+mCoolStatore1_2;
    
    % miscelazione adiabatica non area aggiunta per cooling
    T02_2 = (cp*T0I*mDot+cpO*Tcool*mCoolStatore1_2)/(mDot*cp+mCoolStatore1_2*cpO);
    T03_2 = T02_2;

   


    % ROTORE
    % miscleazione
    mCoolRotore1_2 = propMotore.mAir*propTurbina.CoolingRotore(T03_2);
    mDotRotore1_2 = mDotStatore1_2+mCoolRotore1_2;
    
    % miscelazione adiabatica non area aggiunta per cooling
    T04_2 = (cp*T0I*mDotStatore1_2+cpO*Tcool*mCoolRotore1_2)/(mDotStatore1_2*cp+mCoolRotore1_2*cpO);
    
    % impongop condizoni del secondo stadio (uscita vel assiale e R = 0.5)
    U = sqrt(L_stadio2/mDotRotore1_2)
    vt3_2 = U;
    vz3_2 = vz1_2;
    v3 = sqrt(vz3_2^2+vt3_2^2);

    wt3_2 = vt3_2 -U;
    wz3_2 = vz3_2;
    w3_2 = sqrt(wz3_2^2+wt3_2^2);
    alpha = atan(wt3_2/wz3_2);

    T3 = v3^3/(R*gammaCob);

    vz5_2 = vz3_2;
    vt5_2 = 0;
    v5_2 = sqrt(vz5_2^2 + vt5_2^2);

    wz5_2 = vz5_2;
    wt5_2 = U - vt5_2;
    w5_2 = sqrt(wz5_2^2+wt5_2^2);

    beta = atan(wt5_2/wz5_2);
  
    % L=cp​(T04_2−T05_2​); ricavo nuova temperatura totale
    % T05_2 = T04_2 - L_stadio2/cp;
    % T5 = T05_2 - v5^2/(2*cp) + propTurbina.epsStadio(abs(alpha-beta)*180/pi)*w5_2^2/2
    T5_2 = T04_2 - L_stadio2/cp - v5_2^2/(2*cp) + propTurbina.epsStadio(abs(alpha-beta)*180/pi)*w5_2^2/2;
    T05_2 =  T5_2 + v5_2^2/(2*cp);



    

    


    
    

    


end