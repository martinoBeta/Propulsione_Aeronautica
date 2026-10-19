function [opt,ramjet] = runnerRamjet(ramjet,parametriRam, motore)
    % RUNNERRAMJET Funzione che esegue il ciclo del ramjet
    % In uscita restituisce la spinta specifica da ottimizzare
    % e le complete condizioni del ramjet.
    %
    %   [opt,ramjet] = runnerRamjet(ramjet,parametriRam, motore
    
    ramjet = Parametri(ramjet,parametriRam);
    ramjet = PresaDaria(ramjet);
    ramjet = Anulus(ramjet,motore);
    ramjet = CameraCombustioneRamjet(ramjet, motore);
    ramjet = UgelloRamjet(ramjet);
    ramjet = Performance(ramjet);

    opt = -ramjet.performance.F_s;

end