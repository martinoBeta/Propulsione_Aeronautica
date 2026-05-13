function [motore] = runnerMotore(motore)
    motore = PresaDaria(motore);
    motore = Compressore(motore);
    motore = StimaSpillaggio(motore);
    motore = Diffusore(motore);
    motore = CameraCombustione(motore);
    motore = Turbina(motore);
    motore = Ugello(motore); 
    motore = Performance(motore);
end