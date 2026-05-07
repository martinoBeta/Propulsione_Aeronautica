function [propDiffusore] = structDiffusore(propCompressore)
% Parametri geometrici e aerodinamici del diffusore anulare
% (dump diffuser tra compressore e camera di combustione)
%
% INPUT:
%   propCompressore : struct uscita del compressore, usata per leggere
%                     il numero di Mach all'uscita (M_in del diffusore)
%                     e il raggio medio (r_m_out)
%
% OUTPUT:
%   propDiffusore : struct con tutti i parametri di progetto del diffusore

    % Condizioni all'ingresso (= uscita compressore)
    % Il Mach in ingresso al diffusore è il Mach all'uscita del compressore.
    propDiffusore.M_in = propCompressore.mach_out;  % Mach ingresso diffusore [-]
                                                     
    % Parametri di progetto
    propDiffusore.v_target_camera = 25;   % velocità target all'ingresso camera [m/s] 
    propDiffusore.pi_d = 0.95;            % rendimento pneumatico del diffusore [-]
    propDiffusore.theta = 8;              % semi-angolo di apertura [gradi]                                          

    propDiffusore.rm = propCompressore.r_m_out;  % raggio medio anulare [m]

    % Campi calcolati da Diffusore.m (inizializzati)
    propDiffusore.Ain   = NaN;   % area sezione ingresso  [m²]
    propDiffusore.Aout  = NaN;   % area sezione uscita    [m²]
    propDiffusore.hin   = NaN;   % altezza canale ingresso [m]
    propDiffusore.hout  = NaN;   % altezza canale uscita   [m]
    propDiffusore.LD    = NaN;   % lunghezza assiale diffusore [m]
    propDiffusore.v_in  = NaN;   % velocità ingresso [m/s]
    propDiffusore.v_out = NaN;   % velocità uscita   [m/s]

end
