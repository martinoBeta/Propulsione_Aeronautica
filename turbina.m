function [motore] = turbina(propFluidi,motore)
    %funzione che calcola prestazione della turbina
    %% --------------------------------------------------------------------
    %  LIMITI / VINCOLI DI PROGETTO TURBINA
 
    %   Vincoli aerodinamici:
    %       T_max           1100 - 1700
    %       machIn          0.3 - 0.4
    %       rotore.wmachOut 0.8 - 0.9

    %   Vincoli Geometrici
    %   
    %   

    %   FATTORI LIMITANTI 
    %       Temperatura uscita del compressore comporta a un cambiamento di
    %       prestazioni dato che viene usata per rafreddare la turbina
    %% --------------------------------------------------------------------


    % ---------------------------------------------------------------------
    % INIZIALIZZAZIONE DELLE VARIABILI
    propTurbina = motore.turbina;
    statore = propTurbina.statore;
    rotore = propTurbina.rotore;
    propTurbina.T04 = motore.camera.T04;
    propTurbina.P04 = motore.camera.P04;
    
    % TURBINA INPUT
   
    T0I = propTurbina.T04;
    P0I = propTurbina.P04;
    machIn = propTurbina.machIn;
    
    % DATI DA COMPRESSORE
    U_m = motore.compressore.U_m;
    r_m = motore.compressore.r_m_in;
    L_compressore = motore.compressore.L_c; 
    TCool = motore.compressore.T03;
    
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
    % ---------------------------------------------------------------------

    %% INIZIO CALCOLI
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

    % Lavoro isoentropico rafreddato
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
    rho5 = P5 / (RGas * T5);
    AOut = mDot/(rho5*v5z);
    
    hOut = AOut/(2*pi*r_m);
    rtOut = r_m + hOut/2;
    rhOut = r_m - hOut/2;


    %% STADIO
    % Raggio medio uguale a quello del compressore e turbina monoalbero(Quindi anche U) 
    U = U_m;

    

    % STATORE
    % assunzione che cooling viene applicato prima di espandere in turbina
    % espansione in statore fino a mach 1: (tutte queste quantità dopo espansione fino a mach 1)
        statore.T = T0I/(1+(gammaCob-1)/2);
        statore.P = P0I / (1 + (gammaCob - 1)/2)^(gammaCob/(gammaCob - 1));
        statore.rho = statore.P / (RGas * statore.T);
        % velocità del suono dopo statore
        statore.a = sqrt(statore.T*gammaCob*RGas);
        % calcolo velocita all uscita dello statore
        statore.vz = v4z;
        statore.v = sqrt(gammaCob*RGas*statore.T);
        statore.vt = sqrt(statore.v^2-statore.vz^2);
        % angolo statore.alpha
        statore.alpha = atan(statore.vt/statore.vz)*180/pi;
        % area all'uscita dello statore
        statore.AOut = mDot/(statore.rho*statore.v);

        % Velocità Relative
        statore.wz = statore.vz;
        statore.wt = statore.vt- U;
        statore.w = sqrt(statore.wz^2+statore.wt^2);
        statore.AIn = AIn;
    

    % ROTORE
      % ricavo w3 da risoluzione problema pagina 20 cioè tutte le velocità
      % di uscita dal rotore
      rotore.w = sqrt((statore.a^2 + statore.w^2*(gammaCob-1)/2)/((gammaCob-1)/2+1/(propTurbina.rotore.wmachOut^2)));
      rotore.vz = statore.vz;
      rotore.wz = rotore.vz;
      rotore.wt = sqrt(rotore.w^2-rotore.wz^2);
      rotore.vt = U - rotore.wt;
      rotore.v = sqrt(rotore.vt^2+rotore.vz^2);

      % proprietà fluido rotore all'uscita
      rotore.T0 = T0I - U*(statore.vt-rotore.vt)/cpGas;
      rotore.T = rotore.T0 - rotore.v^2/cpGas;
      % P0 e T0 rimane invariata nello statore, statore ideale
      rotore.P0 = P0I*(rotore.T0/T0I)^(gammaCob/((gammaCob-1)*etaP));
      rotore.P = rotore.P0/(1+(gammaCob-1)/2*rotore.wmachOut^2)^((gammaCob)/(gammaCob-1));
      rotore.rho = rotore.P/(RGas*rotore.T);
      

      
      % SEZIONI
      % entrata rotore
      rotore.AIn = mDot/(statore.rho*statore.vz);
      rotore.hIn = rotore.AIn/(2*pi*r_m);
      rotore.rtIn = r_m + rotore.hIn/2;
      rotore.rhIn = r_m - rotore.hIn/2;
      % usicta rotore
      rotore.AOut = mDot/(rotore.rho*rotore.vz);




  % Grado di reazione 
  R = 1 - (statore.vt + rotore.vt)/(2*U);

  % Lavoro 
  L_stadio = U*(statore.v-rotore.v)*mDot;
  N_stadi = ceil(L_turbina/L_stadio)


    






    


    % ---------------------------------------------------------------------
    % AGGIORNAMENTO DEGLI OUTPUT
    % output
    propTurbina.P05 = P0U;
    propTurbina.T05 = T0U;
    propTurbina.T05_iso = T0U_iso;
    propTurbina.mach5 = machOut;
    propTurbina.rho4 = rho4;
    propTurbina.rho5 = rho5;
    propTurbina.rp = P0U/P0I;
    
    % Lavoro e rendimento
    propTurbina.L_turbina = L_turbina;
    propTurbina.eta_n = eta_n;
    
    % rendimento isoentropico rispetto a caso che non necessita rafreddamento
    propTurbina.eta_NC = eta_NC;             
    
    % Percentuale raffredamento
    propTurbina.coolPecentuale = coolPecentuale;
    propTurbina.SOT = SOT;
    propTurbina.TCool = TCool;

    % Sezioni
    propTurbina.AIn = AIn;
    propTurbina.AOut = AOut;
    propTurbina.hOut = hOut;
    propTurbina.rtOut = rtOut;
    propTurbina.rhOut = rhOut;
    

    % STADIO
    propTurbina.U = U;
    propTurbina.R = R;
    propTurbina.L_stadio = L_stadio;
    propTurbina.N_stadi = N_stadi;
    
    
    % Aggiornameto della struct motore  
    propTurbina.statore = statore;
    propTurbina.rotore = rotore;
    motore.turbina = propTurbina;
    % ---------------------------------------------------------------------
    
end