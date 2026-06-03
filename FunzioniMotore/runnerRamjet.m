function [opt,ramjet] = runnerRamjet(ramjet,parametriRam, motore)
    ramjet = Parametri(ramjet,parametriRam);
    ramjet = PresaDaria(ramjet);
    ramjet = Anulus(ramjet,motore);
    ramjet = CameraCombustioneRamjet(ramjet, motore);
    ramjet = UgelloRamjet(ramjet);
    ramjet = Performance(ramjet);

    % max_radius = max(motore.turbina.rt5,(motore.compressore.rM3+motore.compressore.h3/2));%1/motore.performance.etaGlobal;%motore.performance.TSFC;
    opt = 1/ramjet.performance.ISP;% max_radius;

end