clear; clc;
addpath("../FunzioniMotore/")
addpath("../")

fprintf('=== TEST DIFFUSORE ===\n');

% Inizializzazione
motore = structMotore();

motore.portate.mDotAir = 30;

motore.compressore.mach3  = 0.35;
motore.compressore.T03    = 650;
motore.compressore.P03    = 200000;
motore.compressore.r_m_in = 0.25;

% Esecuzione diffusore
try
    motore = Diffusore(motore);
    d = motore.diffusore;

    fprintf('\nControllo campi output...\n');

    fields = fieldnames(d);

    if isempty(fields)
        error('Struct diffusore vuota: nessun output generato.');
    end

    % CONTROLLO AUTOMATICO
    for i = 1:numel(fields)
        f = fields{i};
        val = d.(f);

        % controllo campo vuoto
        if isempty(val)
            error(['Campo vuoto: ', f]);
        end

        % controllo numerico
        if isnumeric(val)
            if any(isnan(val(:)))
                error(['NaN trovato in: ', f]);
            end

            if any(isinf(val(:)))
                error(['Inf trovato in: ', f]);
            end
        end
    end

    fprintf('OK: tutti i campi sono validi.\n');

    % RISULTATI
    fprintf('\n=== RISULTATI ===\n');

    for i = 1:numel(fields)
        f = fields{i};

        val = d.(f);

        if isnumeric(val)
            fprintf('%-10s = %.6f\n', f, val);
        else
            fprintf('%-10s = (non numerico)\n', f);
        end
    end

    fprintf('\n=== TEST SUPERATO ===\n');

catch ME
    fprintf('\n!!! TEST FALLITO !!!\n');
    fprintf('Errore: %s\n', ME.message);
    error(ME.message);
end