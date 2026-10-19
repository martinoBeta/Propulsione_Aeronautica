function [opt,motore] = runnerMotore(motore,parametri)
% RUNNERMOTORE Funzione che esegue il ciclo del turbogetto
% In uscita restituisce la spinta specifica da ottimizzare
% e le complete condizioni del turbogetto.
%
%   [opt,motore] = runnerMotore(motore,parametri)

    motore = Parametri(motore,parametri);
    motore = PresaDaria(motore);
    motore = Compressore(motore);
    motore = StimaSpillaggio(motore);
    motore = Diffusore(motore);
    motore = CameraCombustione(motore);
    motore = Turbina(motore);
    motore = Ugello(motore); 
    motore = Performance(motore);

    opt = -motore.performance.F_s;
end
