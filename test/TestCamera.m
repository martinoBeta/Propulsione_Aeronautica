clear; clc;
addpath("../FunzioniMotore/")
addpath("../")

fprintf('=== TEST CAMERA DI COMBUSTIONE ===\n');

% 1. Inizializzazione Struttura Motore
motore = structMotore(); 

% Dati ingresso
motore.portate.mDotAir = 30;

motore.compressore.mach3  = 0.35;
motore.compressore.T03    = 420;
motore.compressore.P03    = 200000;
motore.compressore.r_m_out = 0.3;

motore = Diffusore(motore);
motore.camera.TComb = 2200;

% 2. Esecuzione funzione
try
    motore = CameraCombustione(motore);
    c = motore.camera;
    p = motore.portate;

    %% 3. CONTROLLO AUTOMATICO CAMPI OUTPUT
    fprintf('\nControllo campi di output in motore.camera...\n');

    fields = fieldnames(c);

    if isempty(fields)
        error('motore.camera non contiene alcun campo di output.');
    end

    for i = 1:numel(fields)
        f = fields{i};
        val = c.(f);

        % campo vuoto
        if isempty(val)
            error(['Campo vuoto: ', f]);
        end

        % controllo numerico
        if isnumeric(val)
            if any(isnan(val(:))) || any(isinf(val(:)))
                error(['Valore NaN o Inf in campo: ', f]);
            end
        end
    end

    fprintf('OK: Tutti i campi sono presenti e validi.\n');

    %% 4. RISULTATI
    fprintf('\n=== RISULTATI DIMENSIONAMENTO ===\n');

    fprintf('Rapporto f (Global)    = %.4f\n', c.f);
    fprintf('Portata Combustibile   = %.4f kg/s\n', p.mDotComb);
    fprintf('Pressione Uscita (P04) = %.0f Pa\n', c.P04);
    fprintf('Lunghezza Camera (LC)  = %.4f m\n', c.LC);
    fprintf('Area Riferimento (ARef)= %.4f m^2\n', c.ARef);
    fprintf('Tempo Residenza (tRes) = %.6f s\n', c.tRes);

    if c.tRes < 0.008
        fprintf('NOTA: Warning tempo residenza basso.\n');
    end

    fprintf('\n=== TEST SUPERATO ===\n');

catch ME
    fprintf('\n!!! TEST FALLITO !!!\n');
    fprintf('Errore: %s\n', ME.message);
    error(ME.message);
end