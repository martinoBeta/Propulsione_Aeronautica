clear; clc;
addpath("../FunzioniMotore/") % Assicurati che il path sia corretto
addpath("../")

fprintf('=== TEST CAMERA DI COMBUSTIONE ===\n');

%% 1. Inizializzazione Struttura Motore
% Nota: In un caso reale useresti motore = structMotore();
motore = structMotore(); 

% Dati Fluidi (Aria e Gas)

% Combustibile (JP-7 o Kerosene)
% Portata
% Portata
motore.portate.mDotAir = 30;

% Output compressore
motore.compressore.mach3  = 0.35;
motore.compressore.T03    = 420;
motore.compressore.P03    = 200000;
motore.compressore.r_m_in = 0.3;


motore = Diffusore(motore);


motore.camera.TComb = 2200;     % Temp nel liner [K]
motore.camera.rMedio = 0.3;     % [m]

% 2. Esecuzione Funzione
try
    motore = cameraCombustione(motore);
    c = motore.camera;
    p = motore.portate;
    %
    % 3. Controllo Campi e Validità
    requiredFields = { ...
        'f', 'ARef', 'ALiner', 'hRef', 'V', 'Lc', ...
        'URef', 'qRef', 'MRef', 'tRes', 'P04', 'QDot'};

    fprintf('\nControllo campi di output in motore.camera...\n');
    for i = 1:length(requiredFields)
        fieldName = requiredFields{i};
        
        % Verifica esistenza
        assert(isfield(c, fieldName), ['Campo mancante: ', fieldName]);
        
        % Verifica NaN e Inf
        val = c.(fieldName);
        assert(~isnan(val) && isfinite(val), ['Errore valore in: ', fieldName]);
    end
    
    fprintf('OK: Tutti i campi sono presenti e validi.\n');

    %% 4. Risultati Principali
    fprintf('\n=== RISULTATI DIMENSIONAMENTO ===\n');
    fprintf('Rapporto f (Global)    = %.4f\n', c.f);
    fprintf('Portata Combustibile   = %.4f kg/s\n', p.mDotComb);
    fprintf('Pressione Uscita (P04) = %.0f Pa\n', c.P04);
    fprintf('Lunghezza Camera (Lc)  = %.4f m\n', c.Lc);
    fprintf('Area Riferimento (ARef)= %.4f m^2\n', c.ARef);
    fprintf('Tempo Residenza (tRes) = %.6f s\n', c.tRes);
    
    if c.tRes < 0.008
        fprintf('NOTA: Warning tempo residenza atteso corretto.\n');
    end

    fprintf('\n=== TEST SUPERATO ===\n');

catch ME
    fprintf('\n!!! TEST FALLITO !!!\n');
    fprintf('Errore: %s\n', ME.message);
end