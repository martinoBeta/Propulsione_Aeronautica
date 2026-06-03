function [motore] = Turbina(motore)
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
    
    % TURBINA INPUT
    T04 = motore.camera.T04;                    %Temperatura in ingresso turbina        [K]
    P04 = motore.camera.P04;                    %Pressione in ingresso turbina          [Pa]
    machIn = propTurbina.mach4;                 %Mach in ingresso turbina               []
    
    % DATI DA COMPRESSORE
    uM = motore.compressore.UM;                 %Velocitò pallette a raggio medio       [m/s]
    rM = motore.compressore.rM3;                %Raggio medio da compressore            [m]
    lCompressore = motore.compressore.LC;       %Lavoro compressore                     [W]
    TRaff = motore.compressore.T03;             %Temperatura aria raffredamento turbina [K]
    
    % TURBINA CONSTANTI
    etaM = propTurbina.etaM;                    %Rendimento meccanico albero motore     []
    etaP = propTurbina.etaP;                    %Rendimento                             []

    % portate
    mDotAria = motore.portate.mDotAir;
    mDotComb = motore.portate.mDotComb;
    mDotRaff = motore.portate.mDotRaff;
    mDotGas = mDotAria+mDotComb + mDotRaff;                         %Portata massica                        [kg/s]

    % proprietà fluidi
    gammaGas = motore.fluidi.gas.gamma;                %Gamma gas combusti                     []
    cpGas = motore.fluidi.gas.cp;                      %cp Gas combusti                        [J/(kgK)]
    cpAir = motore.fluidi.aria.cp;                     %cp aria                                [J/(kgK)]
    RGas = motore.fluidi.gas.R;                        %Costante specifica di un gas combusti  [J/(kgK)]
    % ---------------------------------------------------------------------

    %% INIZIO CALCOLI
    %Eps = mc/mtot.  percentuale di aria raffredata .
    raffPecentuale = mDotRaff/mDotGas;
    
    
    %Lavoro turbina 
    lTurbina = lCompressore/etaM;
    
    %Temperatura ad uscita turbina isoentropica
    T05 = ((1-raffPecentuale)*cpGas*T04 + raffPecentuale*cpAir*TRaff - lTurbina/mDotGas)/((1-raffPecentuale)*cpGas+raffPecentuale*cpAir);
   
    %Temperatura di miscelamento
    T0M = ((1-raffPecentuale)*cpGas*T04 + raffPecentuale*cpAir*TRaff)/((1-raffPecentuale)*cpGas+ raffPecentuale*cpAir);

    %Calcolo della pressione a uscita della turbina
    betaP =  (T05/T04)^(gammaGas/((gammaGas-1)*etaP));
    P0U = P04 * betaP;

    % temperatura isoentropica
    T05Iso = T04*betaP^((gammaGas-1)/gammaGas);



    % Lavoro isoentropico rafreddato
    lIsoRaff = mDotGas*((1-raffPecentuale)*cpGas*(T04-T05Iso) +(raffPecentuale)*cpAir*(TRaff-T05Iso));
 
    % rendimento adiabatico
   
    etaN = lTurbina/lIsoRaff;
    T0U = T05;
    
    % INLET TURBINE
    T4 = T04 /(1+(gammaGas-1)/2*machIn.^2);
    P4 =  P04 / (1 + (gammaGas - 1)/2 * machIn^2)^(gammaGas/(gammaGas - 1));
    v4z = machIn*sqrt(RGas*gammaGas*T4);
    rho4 = P4 / (RGas * T4);
    A4 = mDotGas*(1-raffPecentuale)/(rho4*v4z);

    % OUTLET TURBINE
    v5z = v4z;                  %velocità assiale costante
    T5 = T05 - v5z^2/(2*cpGas);
    mach5 = sqrt((2/(gammaGas-1)) * ((T05/T5) - 1));
    P5 =  P0U / (1 + (gammaGas - 1)/2 * mach5^2)^(gammaGas/(gammaGas - 1));
    rho5 = P5 / (RGas * T5);
    A5 = mDotGas/(rho5*v5z);
    
    h5 = A5/(2*pi*rM);
    rt5 = rM + h5/2;
    rh5 = rM - h5/2;


    %% STADIO
    % Raggio medio uguale a quello del compressore e turbina monoalbero(Quindi anche U) 
    U = uM;

    

    % STATORE
    % assunzione che cooling viene applicato prima di espandere in turbina
    % espansione in statore fino a mach 1: (tutte queste quantità dopo espansione fino a mach 1)

        statore.Tmisc = T04/(1+(gammaGas-1)/2);
        statore.P = P04 / (1 + (gammaGas - 1)/2)^(gammaGas/(gammaGas - 1));
        statore.rho = statore.P / (RGas * statore.Tmisc);
        % velocità del suono dopo statore
        statore.a = sqrt(statore.Tmisc*gammaGas*RGas);
        % calcolo velocita all uscita dello statore
        statore.vz = v4z;
        statore.v = sqrt(gammaGas*RGas*statore.Tmisc);
        statore.vt = sqrt(statore.v^2-statore.vz^2);
        statore.T = T0M - statore.v^2/(2*cpGas);
        % angolo statore.alpha
        statore.alpha = atan(statore.vt/statore.vz)*180/pi;
        % area all'uscita dello statore
        statore.AOut = mDotGas/(statore.rho*statore.v);
        

        % Velocità Relative
        statore.wz = statore.vz;
        statore.wt = statore.vt- U;
        statore.w = sqrt(statore.wz^2+statore.wt^2);
        statore.AIn = A4;


     % ROTORE
        % ricavo w3 da risoluzione problema pagina 20 cioè tutte le velocità
        % di uscita dal rotore
        rotore.w = sqrt((statore.a^2 + statore.w^2*(gammaGas-1)/2)/((gammaGas-1)/2+1/(propTurbina.rotore.wmachOut^2)));
        rotore.vz = statore.vz;
        rotore.wz = rotore.vz;
        rotore.wt = -sqrt(rotore.w^2-rotore.wz^2);
        rotore.vt = U + rotore.wt;
        rotore.v = sqrt(rotore.vt^2+rotore.vz^2);
        
        % proprietà fluido rotore all'uscita
        rotore.T0 = T0M - U*(statore.vt-rotore.vt)/cpGas;
        rotore.T = rotore.T0 - rotore.v^2/(2*cpGas);
        % P0 e T0 rimane invariata nello statore, statore ideale
        rotore.P0 = P04*(rotore.T0/T04)^(gammaGas/((gammaGas-1)*etaP));
        rotore.P = rotore.P0/(1+(gammaGas-1)/2*rotore.wmachOut^2)^((gammaGas)/(gammaGas-1));
        rotore.rho = rotore.P/(RGas*rotore.T);
      

      
      % SEZIONI
      % entrata rotore
      rotore.AIn = mDotGas/(statore.rho*statore.vz);
      rotore.hIn = rotore.AIn/(2*pi*rM);
      rotore.rtIn = rM + rotore.hIn/2;
      rotore.rhIn = rM - rotore.hIn/2;
      % usicta rotore
      rotore.AOut = mDotGas/(rotore.rho*rotore.vz);




  % Grado di reazione 
  R = 1 - (statore.vt + rotore.vt)/(2*U);


  % Lavoro 
  lStadio = U*(statore.vt-rotore.vt)*mDotGas;
  nStadi = ceil(lTurbina/lStadio);
  etaStadio =(1-(rotore.T/T04))/(1-(rotore.T/T04)^(1/0.9));
  % lStadio/(mDotGas*cpGas*T04*(1-(P04/rotore.P0)^((1-gammaGas)/gammaGas)));
    
    






    


    % ---------------------------------------------------------------------
    % AGGIORNAMENTO DEGLI OUTPUT
    % output
    propTurbina.P05 = P0U;
    propTurbina.T05 = T0U;
    propTurbina.T05Iso = T05Iso;
    propTurbina.mach5 = mach5;
    propTurbina.rho4 = rho4;
    propTurbina.rho5 = rho5;
    propTurbina.rp = P0U/P04;
    
    % Lavoro e rendimento
    propTurbina.lTurbina = lTurbina;
    propTurbina.etaN = etaN;
       
    
    % Percentuale raffredamento
    propTurbina.TRaff = TRaff;

    % Sezioni
    propTurbina.A4 = A4;
    propTurbina.A5 = A5;
    propTurbina.h5 = h5;
    propTurbina.rt5 = rt5;
    propTurbina.rh5 = rh5;
    

    % STADIO
    propTurbina.U = U;
    propTurbina.R = R;
    propTurbina.lStadio = lStadio;
    propTurbina.nStadi = nStadi;
    propTurbina.etaStadio = etaStadio;
    
    
    % Aggiornameto della struct motore  
    propTurbina.statore = statore;
    propTurbina.rotore = rotore;
    motore.turbina = propTurbina;
    motore.portate.mDotGas = mDotGas;
    % ---------------------------------------------------------------------
    
end