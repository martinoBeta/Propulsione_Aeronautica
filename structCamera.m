function [propCamera] = structCamera()
    % Parametri di progetto per il dimensionamento
    propCamera.r_m = 0.35;        % Raggio medio
    propCamera.DP_qref = 20;     % Fattore di perdita dinamica
    propCamera.DP_su_P3_target = 0.06; %
    propCamera.I_target = 9e6;   % Intensità di combustione target 
end