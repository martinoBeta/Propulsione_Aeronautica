function [propCameraTarget] = structCamera()
    % Parametri di progetto per il dimensionamento
    propCameraTarget.rm = 0.35;        % Raggio medio (ereditato dal compressore) [m]
    propCameraTarget.DP_qref = 20;     % Fattore di perdita dinamica (tipico camera anulare)
    propCameraTarget.i_target = 9e6;   % Intensità di combustione target [W/(m^3*Pa)]
end