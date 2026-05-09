function [propMotore] = structMotore()
% Parametri globali del motore turbojet-ramjet

    % Portate
    mdot  = 35;             % portata massica totale (aria + combustibile) [kg/s]
    

    % Parametri termodinamici ciclo
    Tmax  = 1700;           % temperatura massima ciclo (TIT) [K]
    eta_b = 0.98;           % rendimento di combustione [-]
    pi_b  = 0.97;           % rapporto di pressione camera di combustione [-]

    % Perdite e spillamenti
    % aria_spillata: frazione di mAir prelevata dopo il compressore
    aria_spillata = 0.15;   % [-] 
    mDotCool      = aria_spillata * mAir;   % portata aria spillata [kg/s]
    mDotCore      = mAir - mDotCool;        % portata aria che entra in camera [kg/s]

    % Presa d'aria
    eta_d_1 = 0.99;         % rendimento pneumatico presa d'aria (regime subsonico) [-]

    % Assemblaggio struct
    propMotore.mdot        = mdot;
    propMotore.mAir        = mAir;
    propMotore.mFuel       = mFuel;
    propMotore.FO          = FO;           
    propMotore.f           = f; % da vedere se devo trovarlo direttamente in camera di comb o già fatto
    propMotore.Tmax        = Tmax;
    propMotore.eta_b       = eta_b;
    propMotore.pi_b        = pi_b;
    propMotore.aria_spillata = aria_spillata;
    propMotore.mDotCool    = mDotCool;     
    propMotore.mDotCore    = mDotCore;    
    propMotore.eta_d_1     = eta_d_1;       

    %
   


    %% TUBINA
    % ---------------------------------------------------------------------


        eta_m = 0.92; % rendimento meccanico
        eta_p = 0.9;% rendimento adiabatico
    
        %% Aria di rafreddamento dalle tabelle
        CoolingStatore = @(x)  (x<1100)*0 + ...    %cooling air richiesta per TIN statore è SOT
                                (x>=1100 & x <= 1650).*(0.09/(1600-1100)*(x-1100)) + ...
                                (x>1650).*0.5;
    
        CoolingRotore = @(x)   (x<1250)*0 + ...    %cooling air richiesta per TIN statore la T è SOT
                                (x>=1250 & x <= 1600).*(0.05/(1400-1250)*(x-1250)) + ...
                                (x>1600).*0.5;

    
        %% Impostare struct
    
        Turbina.eta_m = eta_m; 
        Turbina.eta_p = eta_p;
        Turbina.CoolingStatore = CoolingStatore;
        Turbina.CoolingRotore = CoolingRotore;
        Turbina.epsStadio = epsStadio;
        % Lavoro
        Turbina.L_turbina = NaN;

        % IN
        Turbina.machIn = NaN;
        Turbina.P0I = NaN;
        Turbina.T0I = NaN;

        % Out
        Turbina.P0U = NaN;
        Turbina.T0U = NaN;
        Turbina.machOut = NaN;

        % Parametri di Rafreddamento
        Turbina.coolPecentuale = NaN;
        Turbina.TCool = NaN;

        % Stadio
        
        

    % Salvataggio Struct 
    propMotoTurbinare.Turbina = Turbina;
    % ---------------------------------------------------------------------
 


end
