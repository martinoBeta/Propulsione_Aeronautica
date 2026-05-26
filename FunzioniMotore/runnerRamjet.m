function [opt,ramjet] = runnerRamjet(ramjet,parametriRam)
    ramjet = Parametri(ramjet,parametriRam);
    ramjet = PresaDaria(ramjet);
    ramjet = Anulus(ramjet);
    ramjet = CameraCombustioneRamjet(ramjet);
    ramjet = UgelloRamjet(ramjet);
    ramjet = Performance(ramjet);

    % max_radius = max(motore.turbina.rt5,(motore.compressore.r_m_out+motore.compressore.hOut/2));%1/motore.performance.etaGlobal;%motore.performance.TSFC;
    opt = ramjet.performance.TSFC;% max_radius;

end