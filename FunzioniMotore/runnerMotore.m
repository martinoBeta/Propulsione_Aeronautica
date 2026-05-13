function [TSFC,motore] = runnerMotore(motore,parametri)
    motore = Parametri(motore,parametri);
    motore = PresaDaria(motore);
    motore = Compressore(motore);
    motore = StimaSpillaggio(motore);
    motore = Diffusore(motore);
    motore = CameraCombustione(motore);
    motore = Turbina(motore);
    motore = Ugello(motore); 
    motore = Performance(motore);
    TSFC = motore.performance.TSFC;
end