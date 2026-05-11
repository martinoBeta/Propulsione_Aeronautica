function [motore] = runnerMotore(motore,propFluidi)
    motore = PresaDaria(motore);
    motore = compressore(motore);
    motore = stimaSpillaggio(motore,propFluidi);
    motore = Camera_combustione(motore,propFluidi,"design");
    motore = turbina(motore,propFluidi);
    motore = ugello(motore,propFluidi); 
    motore = performance(motore);
end