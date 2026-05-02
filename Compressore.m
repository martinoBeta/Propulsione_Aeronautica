clear
clc


propFluidi = structFluidi();
propMotore = structMotore(structTurbina());


% NOTA IMPORTANTE:
% Le fonti sono da controllare e da approfondire


% FONTI RANGE R
% https://scispace.com/pdf/the-effect-of-reaction-on-axial-flow-compressor-performance-1rtbqaeawx.pdf?utm_source=chatgpt.com
% https://scholar.afit.edu/cgi/viewcontent.cgi?article=7109&context=etd&utm_source=chatgpt.com
% https://thesis.unipd.it/retrieve/44c7a9bb-a360-47c8-ba5d-b978c4fff945/Tesi_Crosato.pdf?utm_source=chatgpt.com
% R è circa 0.5, ho preso un range ampio da 0.3 a 0.7
% https://asmedigitalcollection.asme.org/turbomachinery/article-abstract/145/12/121008/1167686/Numerical-Investigation-of-the-Influence-of-the?redirectedFrom=fulltext&utm_source=chatgpt.com
R_range = 0.3:0.05:0.7;     % grado di reazione

U_range = 250:25:400;
beta_c_range =  6:1:20;    % rapporto di compressione totale

%FONTI RANGE ETA compressore
% Gas Turbine Engineering Handbook

%eta_c_range   = 0.80:0.02:0.90;   % rendimento compressore

eta_stadio = 0.88 : 0.01 : 0.92;  % rendimento singolo stadio compressore

eta_p_range = 0.88 : 0.01 : 0.92;       % rendimento politropico

%FONTI RANGE Mach ingresso
% Gas Turbine Engineering Handbook
% Fluid Mechanics and Thermodynamics of Turbomachinery
%Se è superiore a circa 0.6 si formano onde d'urto locali sulla paletta,
%troppo basso significa che per mantenere la portata di progetto
%servirebbe un'area molto grande
Mach_in_range = 0.25:0.05:0.55;   % Mach ingresso compressore


% Caso base 
R_base      = 0.5;
machIn_base = 0.35;
beta_c_base   = 12;
eta_c_base  = 0.85;
U_base      = 320;
mDot_base   = mDotDesign;

mDot_range = mDot_Design * (0.8:0.05:1.2);


%Analisi 1: vario pi_c, tengo fissi gli altri
for beta_c = beta_c_range
    R      = R_base;
    machIn = machIn_base;
    eta_c  = eta_c_base;
    U      = U_base;
    mDot   = mDot_base;

end
T02, P02, L_comp, l_comp, N_stadi, Mach_rel, Mach_abs, Va


function [T0U, P0U, L_comp, eta_c, Mach_rel, Mach_abs, Va] = compressore(T0I, P0I, mDot, beta_c, eta_p, U, R, N_stadi, machIn, propFluidi)

    gamma = propFluidi.gamma;
    Rgas  = propFluidi.R;
    cp    = propFluidi.cp;


    P0U = beta_c * P0I;

    T02s = T0I * beta_c^((gamma - 1)/gamma);
    T0U = T0I + (T02s - T0I)/eta_c;

    l_comp = cp * (T0U - T0I); % Lavoro specifico
    L_comp = mDot *  l_comp;

    eta_c = (beta_c^((gamma-1)/gamma) - 1) / (beta_c^((gamma-1)/(gamma*eta_p)) - 1);

    % Velocità assiale in ingresso

    T1 = T0I / (1 + (gamma - 1)/2 * machIn^2);

    a1 = sqrt(gamma * Rgas * T1);

    Va = machIn * a1;


    l_stadio = l_comp / N_stadi; % lavoro specifico per singolo stadio

    % Triangoli di velocità

    delta_Vt = l_stadio / U;

    Vt1 = 0;              % ingresso assiale
    Vt2 = delta_Vt;

    V1 = sqrt(Va^2 + Vt1^2);
    V2 = sqrt(Va^2 + Vt2^2);

    Wt1 = Vt1 - U;
    Wt2 = Vt2 - U;

    W1 = sqrt(Va^2 + Wt1^2);
    W2 = sqrt(Va^2 + Wt2^2);

    Mach_abs_1 = V1 / a1;
    Mach_abs_2 = V2 / a1;

    Mach_rel_1 = W1 / a1;
    Mach_rel_2 = W2 / a1;

    Mach_abs = max([Mach_abs_1, Mach_abs_2]);
    Mach_rel = max([Mach_rel_1, Mach_rel_2]);

end