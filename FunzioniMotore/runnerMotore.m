function [opt,motore] = runnerMotore(motore,parametri)
    motore = Parametri(motore,parametri);
    motore = PresaDaria(motore);
    motore = Compressore(motore);
    motore = StimaSpillaggio(motore);
    motore = Diffusore(motore);
    motore = CameraCombustione(motore);
    motore = Turbina(motore);
    motore = Ugello(motore); 
    motore = Performance(motore);

    % max_radius = max(motore.turbina.rt5,(motore.compressore.r_m_out+motore.compressore.hOut/2));%1/motore.performance.etaGlobal;%motore.performance.TSFC;
    %opt = motore.performance.TSFC;% max_radius;

    opt = motore.performance.ISP;
end
