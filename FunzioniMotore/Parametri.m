function [motore] = Parametri(motore,parametri)
%PARAMETRI Funzione che assegna i parametri di 
%progetto del motore in base al regime di volo.
%
%   [motore] = Parametri(motore,parametri)

    regime = motore.presaAria.regime;
    
        if regime == "subsonico"
            motore.portate.mDot = parametri(1);
            motore.compressore.piC = parametri(2);
            motore.compressore.Utip = parametri(3);
            motore.camera.T04 = parametri(4);   
           
        elseif regime == "supersonico"
            motore.portate.mDot = parametri(1);
            motore.camera.Tmax = parametri(2);
            motore.ugello.piC  = parametri(3);
        end


end