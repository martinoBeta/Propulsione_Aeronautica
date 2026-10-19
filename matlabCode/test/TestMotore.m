clc;
clear;
addpath("../FunzioniMotore/")
addpath("../")

fprintf('=== TEST RUNNER MOTORE ===\n');

motore = structMotore();

try
    motore = runnerMotore(motore);

    fprintf('\nControllo completo struttura motore...\n');

    validateStruct(motore, 'motore');

    fprintf('OK: struttura motore valida.\n');
    fprintf('\n=== TEST SUPERATO ===\n');

catch ME
    fprintf('\n!!! TEST FALLITO !!!\n');
    fprintf('%s\n', ME.message);
    error(ME.message);
end


function validateStruct(S, name)

if isempty(S)
    error(['Struttura vuota: ', name]);
end

fields = fieldnames(S);

for i = 1:numel(fields)

    f = fields{i};
    v = S.(f);
    fullName = [name '.' f];

    if isempty(v)
        error(['Campo vuoto: ', fullName]);
    end

    if isnumeric(v)
        if any(isnan(v(:)))
            error(['NaN trovato in: ', fullName]);
        end
        if any(isinf(v(:)))
            error(['Inf trovato in: ', fullName]);
        end
    elseif isstruct(v)
        validateStruct(v, fullName);
    end

end

end