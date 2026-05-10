function [motore] = runnerMotore(propFluidi,motore)
    motore = PresaDaria(motore);
    motore = compressore(motore);
    motore = Camera_di_combustione(motore,propFluidi);
    motore = turbina(propFluidi,motore);
    motore = ugello(motore,propFluidi); %% non è ancora stato cambiato. 
end