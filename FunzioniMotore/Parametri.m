function [motore] = Parametri(motore,parametri)
%PARAMETRI Summary of this function goes here
%   Detailed explanation goes here
% parametri = [ ...
%     35;     % mDot     -> Portata massica in ingresso
%     0.35;   % mach2    -> Mach ingresso compressore (mach2)
%     7;      % pi_c     -> Rapporto di compressione compressore
%     350;    % Utip     -> Velocità periferica tip compressore
%     5;      % theta    -> Angolo apertura diffusore
%     25;     % vtargetcamera -> Velocità target verso camera di combustione
%     1500;   % T04      -> Temperatura totale uscita camera / ingresso turbina
%     2300;   % TComb    -> Temperatura di combustione
%     80;     % I        -> Intensità di combustione
%     0.3;    % mach4    -> Mach ingresso turbina
%     0.9;    % wmachOut -> Mach relativo uscita rotore turbina
% ]; 
    
    regime = motore.presaAria.regime;
    
        if regime == "subsonico"
            motore.portate.mDot = parametri(1);
            motore.compressore.piC = parametri(2);
            motore.compressore.Utip = parametri(3);
            motore.camera.T04 = parametri(4);   
            motore.turbina.rotore.wmachOut = parametri(5);
        elseif regime == "supersonico"
            motore.portate.mDot = parametri(1);
            motore.camera.Tmax = parametri(2);
        end


end