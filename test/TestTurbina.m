%% TEST TURBINA
% Script eseguibile direttamente con RUN

clc;
clear;
addpath("../FunzioniMotore/")
addpath("../")
fprintf('=== TEST TURBINA ===\n');

%

motore = structMotore();

% FLUIDI
motore.portate.mDotGas = 30;
motore.portate.mDotRaff  = 5;



% COMPRESSORE

motore.compressore.U_m    = 350;        % [m/s]
motore.compressore.r_m_in = 0.25;       % [m]
motore.compressore.L_c    = 8e6;        % [W]
motore.compressore.T03    = 420;        % [K]

% CAMERA DI COMBUSTIONE

motore.camera.T04 = 1500;               % [K]
motore.camera.P04 = 1400000;            % [Pa]

% TURBINA

motore.turbina.mach4            = 0.35;
motore.turbina.raffPecentuale   = 0.05;

% ROTORE
motore.turbina.rotore.wmachOut = 0.85;

motore = Turbina(motore);

t = motore.turbina;



requiredFields = { ...
    'P05','T05','T05Iso', ...
    'mach5','rho4','rho5', ...
    'rp','lTurbina','etaN', ...
    'etaNRaff','TRaff', ...
    'A4','A5','h5', ...
    'rt5','rh5', ...
    'U','R','lStadio','nStadi'};



fprintf('\nControllo campi turbina...\n');

for i = 1:length(requiredFields)

    fieldName = requiredFields{i};

    assert(isfield(t, fieldName), ...
        ['Campo mancante: ', fieldName]);

end

fprintf('OK campi presenti.\n');



fprintf('Controllo NaN...\n');

for i = 1:length(requiredFields)

    fieldName = requiredFields{i};

    value = t.(fieldName);

    assert(~isnan(value), ...
        ['Valore NaN trovato in: ', fieldName]);

end

fprintf('OK nessun NaN.\n');


fprintf('Controllo Inf...\n');

for i = 1:length(requiredFields)

    fieldName = requiredFields{i};

    value = t.(fieldName);

    assert(isfinite(value), ...
        ['Valore non finito trovato in: ', fieldName]);

end

fprintf('OK nessun Inf.\n');


fprintf('Controllo statore...\n');

requiredStatoreFields = { ...
    'T','P','rho','a', ...
    'vz','v','vt', ...
    'alpha','AOut', ...
    'wz','wt','w','AIn'};

for i = 1:length(requiredStatoreFields)

    fieldName = requiredStatoreFields{i};

    assert(isfield(t.statore, fieldName), ...
        ['Campo statore mancante: ', fieldName]);

    value = t.statore.(fieldName);

    assert(~isnan(value), ...
        ['NaN nello statore: ', fieldName]);

    assert(isfinite(value), ...
        ['Inf nello statore: ', fieldName]);

end

fprintf('OK statore.\n');


fprintf('Controllo rotore...\n');

requiredRotoreFields = { ...
    'w','vz','wz','wt', ...
    'vt','v','T0','T', ...
    'P0','P','rho', ...
    'AIn','hIn', ...
    'rtIn','rhIn','AOut'};

for i = 1:length(requiredRotoreFields)

    fieldName = requiredRotoreFields{i};

    assert(isfield(t.rotore, fieldName), ...
        ['Campo rotore mancante: ', fieldName]);

    value = t.rotore.(fieldName);

    assert(~isnan(value), ...
        ['NaN nel rotore: ', fieldName]);

    assert(isfinite(value), ...
        ['Inf nel rotore: ', fieldName]);

end

fprintf('OK rotore.\n');


fprintf('\n=== RISULTATI TURBINA ===\n');

for i = 1:length(requiredFields)

    fieldName = requiredFields{i};

    fprintf('%-12s = %.6f\n', ...
        fieldName, t.(fieldName));

end

fprintf('\n=== TEST SUPERATO ===\n');