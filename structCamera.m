function [propCamera] = structCamera(structCompr)
% Parametri di progetto per il dimensionamento della camera di combustione

    propCamera.r_m             = ;      % raggio medio camera anulare [m]
    propCamera.DP_su_qref      = 20;    % fattore di perdita dinamica  [-]                                  
    propCamera.DP_su_P3_target = 0.06;  % perdita di pressione totale  [-]
    propCamera.I               = 80;   % intensità di combustione target [W/(m³·Pa)]                                      

end
% motore.comp.