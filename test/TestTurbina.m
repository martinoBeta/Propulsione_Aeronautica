clc;
clear;
addpath("../FunzioniMotore/")
addpath("../")

fprintf('=== TEST TURBINA ===\n');

motore = structMotore();

motore.portate.mDotGas = 30;
motore.portate.mDotRaff = 5;

motore.compressore.U_m    = 350;
motore.compressore.r_m_out = 0.25;
motore.compressore.L_c    = 8e6;
motore.compressore.T03    = 420;

motore.camera.T04 = 1500;
motore.camera.P04 = 1400000;

motore.turbina.mach4 = 0.35;
motore.turbina.raffPecentuale = 0.05;

motore.turbina.rotore.wmachOut = 0.85;

try
    motore = Turbina(motore);
    t = motore.turbina;

    fprintf('\nControllo turbina...\n');

    validate = @(S, name) validateStruct(S, name);

    validate(t, 'turbina');

    if ~isfield(t, 'statore')
        error('Campo mancante: statore');
    end
    validate(t.statore, 'statore');

    if ~isfield(t, 'rotore')
        error('Campo mancante: rotore');
    end
    validate(t.rotore, 'rotore');

    fprintf('OK: struttura valida.\n');

    fprintf('\n=== RISULTATI TURBINA ===\n');
    f = fieldnames(t);
    for i = 1:numel(f)
        val = t.(f{i});
        if isnumeric(val)
            fprintf('%-12s = %.6f\n', f{i}, val);
        end
    end

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

f = fieldnames(S);

for i = 1:numel(f)
    v = S.(f{i});

    if isempty(v)
        error(['Campo vuoto in ', name, ': ', f{i}]);
    end

    if isnumeric(v)
        if any(isnan(v(:)))
            error(['NaN in ', name, ': ', f{i}]);
        end
        if any(isinf(v(:)))
            error(['Inf in ', name, ': ', f{i}]);
        end
    elseif isstruct(v)
        validateStruct(v, [name '.' f{i}]);
    end
end

end