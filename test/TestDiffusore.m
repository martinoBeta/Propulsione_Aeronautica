clear; clc;
addpath("../FunzioniMotore/")
addpath("../")
fprintf('=== TEST DIFFUSORE ===\n');

%% Controlllo Diffusore


motore = structMotore();

% Portata
motore.portate.mDotAir = 30;

% Output compressore
motore.compressore.mach3  = 0.35;
motore.compressore.T03    = 650;
motore.compressore.P03    = 200000;
motore.compressore.r_m_in = 0.25;


motore = Diffusore(motore);

d = motore.diffusore;

requiredFields = { ...
    'T035','P035','mach35', ...
    'A3','A35','h3','h35', ...
    'LD','v3','v35'};

fprintf('\nControllo campi...\n');

for i = 1:length(requiredFields)

    fieldName = requiredFields{i};

    assert(isfield(d, fieldName), ...
        ['Campo mancante: ', fieldName]);

end

fprintf('OK campi presenti.\n');

fprintf('Controllo NaN...\n');

for i = 1:length(requiredFields)

    fieldName = requiredFields{i};

    value = d.(fieldName);

    assert(~isnan(value), ...
        ['Valore NaN trovato in: ', fieldName]);

end

fprintf('OK nessun NaN.\n');

fprintf('Controllo Inf...\n');

for i = 1:length(requiredFields)

    fieldName = requiredFields{i};

    value = d.(fieldName);

    assert(isfinite(value), ...
        ['Valore non finito trovato in: ', fieldName]);

end

fprintf('OK nessun Inf.\n');


fprintf('\n=== RISULTATI ===\n');

for i = 1:length(requiredFields)

    fieldName = requiredFields{i};

    fprintf('%-10s = %.6f\n', ...
        fieldName, d.(fieldName));

end

fprintf('\n=== TEST SUPERATO ===\n');