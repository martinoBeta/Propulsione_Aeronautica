function [motore] = runnerMotore(motore,propFluidi)
    motore = PresaDaria(motore);
    motore = Compressore(motore);
    motore = StimaSpillaggio(motore);
    motore = Diffusore(motore);
    motore = Camera_combustione(motore);
    motore = Turbina(motore);
    motore = ugello(motore,propFluidi); 
    motore = performance(motore);
end