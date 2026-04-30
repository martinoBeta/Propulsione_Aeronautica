function [propMotore] = structMotore(propTurbina)
% ritorna le struct con i parametri del motore
    f=1.05;
    mdot=70;                    % portata in kg/s totale (incluso il combustibile)
    FO = 0.01;                  % mf/mOx motore 
    mAir = mdot/(1+FO);
    mFuel  = mdot - mAir;
    Tmax=1500;                  % temperatura massima
    eta_b=0.98;                 % rendimento adiabatico
    pi_b=0.97;                  % rendimento pneumatico
    aria_spillata = 0.15;       % percentuale di aria spillata per tutti i sistmi (raffreddamento turbina ...
                                % / cabin pressure serbatogli). SI APPLICA
                                % SU mAir NON mDot O mFuel cioè l'aria dopo
                                % subito dopo il compressore ad alta
                                % pressione

    eta_d_1 = 0.99;             % Efficienza della presa a regime subsonico



    propMotore.f=f;
    propMotore.mdot=mdot; 
    propMotore.mAir = mAir;
    propMotore.mFuel = mFuel;
    propMotore.f = FO; 
    propMotore.Tmax=Tmax;
    propMotore.eta_b=eta_b;
    propMotore.pi_b=pi_b;
    propMotore.aria_spillata = aria_spillata;



    % struct
    propMotore.Turbina = propTurbina;
end