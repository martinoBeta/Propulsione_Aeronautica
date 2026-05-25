function [opt,ramjet] = runnerRamjet(ramjet,parametriRam)
    ramjet = Parametri(ramjet,parametri);
    ramjet = PresaDaria(ramjet);
    ramjet = Compressore(ramjet);
    ramjet = StimaSpillaggio(ramjet);
    ramjet = Diffusore(ramjet);
    ramjet = CameraCombustione(ramjet);
    ramjet = Turbina(ramjet);
    ramjet = Ugello(ramjet); 
    ramjet = Performance(ramjet);

    % max_radius = max(motore.turbina.rt5,(motore.compressore.r_m_out+motore.compressore.hOut/2));%1/motore.performance.etaGlobal;%motore.performance.TSFC;
    opt = ramjet.performance.TSFC;% max_radius;

end