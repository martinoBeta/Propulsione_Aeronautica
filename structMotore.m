function [propMotore] = structMotore(propTurbina)
% Parametri globali del motore turbojet-ramjet

    % Portate
    mdot  = 39;             % portata massica totale (aria + combustibile) [kg/s]
    FO    = 0.01;           % rapporto combustibile/aria  mf/mAir          [-]
    mAir  = mdot / (1 + FO);   % portata aria [kg/s]
    mFuel = mdot - mAir;       % portata combustibile [kg/s]
    f = 1.05;               % rapporto combustibile aria

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
    propMotore.Turbina = propTurbina;

end
