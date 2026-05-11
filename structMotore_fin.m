function [Motore] = structMotore()
% STRUCTMOTORE  —  Struct unificata del motore
%
% Contiene TUTTI i parametri costanti di progetto del motore, organizzati
% in sotto-struct per componente. Le funzioni di calcolo di ogni modulo
% leggono i propri parametri da Motore.<Componente>.
%
% STRUTTURA:
%   Motore
%   ├── (parametri globali)
%   ├── .PresaDaria   — parametri presa d'aria
%   ├── .Compressore  — parametri compressore assiale
%   ├── .Diffusore    — parametri diffusore anulare
%   ├── .Camera       — parametri camera di combustione
%   ├── .Combustibile — proprietà del combustibile (JP-7)
%   ├── .Turbina      — parametri turbina assiale (con funzioni di raffreddamento)
%   └── .Ugello       — parametri ugello
%
% CHIAMATA:
%   Motore = structMotore();
%
% NOTA SUI CAMPI NaN:
%   I campi marcati con NaN sono calcolati dalle rispettive funzioni di modulo
%   e vengono scritti nel main dopo ogni chiamata. Servono come "placeholder"
%   per rendere la struttura completa e leggibile fin dall'inizio.

%%  PARAMETRI GLOBALI DEL MOTORE

    mdot  = 39;                     % portata massica totale (aria + comb.) [kg/s]
    FO    = 0.01;                   % rapporto combustibile/aria  mf/mAir   [-]
    mAir  = mdot / (1 + FO);       % portata aria totale                   [kg/s]
    mFuel = mdot - mAir;           % portata combustibile nominale          [kg/s]

    aria_spillata = 0.15;           % frazione spillata                     [-]
    mDotCool      = aria_spillata * mAir;   % portata aria spillata         [kg/s]
    mDotCore      = mAir - mDotCool;        % portata aria → camera         [kg/s]

    Tmax = 1700;                    % temperatura massima ciclo (TIT)       [K]

    Motore.mdot          = mdot;
    Motore.mAir          = mAir;
    Motore.mFuel         = mFuel;
    Motore.FO            = FO;
    Motore.aria_spillata = aria_spillata;
    Motore.mDotCool      = mDotCool;
    Motore.mDotCore      = mDotCore;
    Motore.Tmax          = Tmax;

%%  COMBUSTIBILE  (JP-7)

    Motore.Combustibile.nome = 'JP-7';
    Motore.Combustibile.LHV  = 44.1e6; % potere calorifico inferiore       [J/kg]

    % Calcolati da Camera_di_combustione.m
    Motore.Combustibile.f   = NaN;  % rapporto comb./aria locale           [-]
    Motore.Combustibile.m_f = NaN;  % portata combustibile effettiva       [kg/s]

%%  PRESA D'ARIA

% Modello subsonico
    Motore.PresaDaria.regime     = "subsonico"; % tipo di regime
    Motore.PresaDaria.T2         = NaN;         % temperatura statica in uscita [K]
    Motore.PresaDaria.P2         = NaN;         % pressione starica in uscita [Pa]
    Motore.PresaDaria.T02        = NaN;         % temperatura totale in uscita [K]
    Motore.PresaDaria.P02        = NaN;         % pressione totale in uscita [Pa]
    Motore.PresaDaria.M2         = 0.35;        % Mach in uscita [-]
    Motore.PresaDaria.eta_d      = 0.975;       % 
    Motore.PresaDaria.pi_d       = 0.985;       %
    
    Motore.PresaDaria.rho2       = NaN;         % densita aria in uscita [kg/m^3]
    Motore.PresaDaria.V2         = NaN;         % velocità in uscita [m/s]
    Motore.PresaDaria.A_ingresso = NaN;         % sezione in ingresso [m^2]
    Motore.PresaDaria.A2         = NaN;         % sezione uscita [m^2]
    Motore.PresaDaria.CPR        = NaN;         % 


    Motore.PresaDaria.eta_d = 0.99; % rendimento pneumatico presa d'aria [-]

    % Campi calcolati da PresaDaria.m
    Motore.PresaDaria.P02 = NaN;    % pressione totale uscita            [Pa]
    Motore.PresaDaria.T02 = NaN;    % temperatura totale uscita          [K]

%%  COMPRESSORE ASSIALE

    Motore.Compressore.pi_c    = 20;    % rapporto di pressione totale   [-]
    Motore.Compressore.eta_p   = 0.90;  % rendimento politropico         [-]
    Motore.Compressore.U       = 350;   % velocità periferica rotore     [m/s]
    Motore.Compressore.N_stadi = 8;     % numero di stadi                [-]
    Motore.Compressore.machIn  = 0.45;  % Mach assiale ingresso          [-]
    Motore.Compressore.hubTip  = 0.50;  % rapporto mozzo/punta           [-]

    % Campi calcolati da compressore.m
    Motore.Compressore.T03      = NaN;  % temperatura totale uscita      [K]
    Motore.Compressore.P03      = NaN;  % pressione totale uscita        [Pa]
    Motore.Compressore.L_c      = NaN;  % lavoro totale                  [W]
    Motore.Compressore.eta_c    = NaN;  % rendimento adiabatico          [-]
    Motore.Compressore.mach_out = NaN;  % Mach uscita                    [-]
    Motore.Compressore.Va       = NaN;  % velocità assiale               [m/s]
    Motore.Compressore.r_m_out  = NaN;  % raggio medio uscita            [m]
    Motore.Compressore.r_m_in   = NaN;  % raggio medio ingresso          [m]
    Motore.Compressore.Ain      = NaN;  % area sezione ingresso          [m²]
    Motore.Compressore.Aout     = NaN;  % area sezione uscita            [m²]
    Motore.Compressore.h_in     = NaN;  % altezza palettatura ingresso   [m]
    Motore.Compressore.h_out    = NaN;  % altezza palettatura uscita     [m]
    Motore.Compressore.deHaller = NaN;  % criterio de Haller W2/W1      [-]
    Motore.Compressore.Cp_stadio= NaN;  % coefficiente di pressione      [-]
    Motore.Compressore.Mach_rel = NaN;  % Mach relativo massimo          [-]
    Motore.Compressore.Mach_abs = NaN;  % Mach assoluto massimo          [-]
    Motore.Compressore.beta1    = NaN;  % angolo relativo ingresso rotore [°]
    Motore.Compressore.beta2    = NaN;  % angolo relativo uscita rotore  [°]
    Motore.compressore.D_rotore = NaN;
    Motore.compressore.D_statore= NaN;
    Motore.compressore.R_m      = NaN;  % raggio medio [m]
    Motore.compressore.c_m      = NaN   % 
    Motore.compressore.N_R      = NaN;
    Motore.compressore.N_stadi  = NaN;

%%  DIFFUSORE ANULARE  (tra compressore e camera)

% M_in e rm dipendono dall'uscita del compressore: vengono aggiornati
% nel main subito dopo la chiamata a compressore.m.

    Motore.Diffusore.v_target_camera = 25;   % velocità target ingresso camera [m/s]
    Motore.Diffusore.pi_d            = 0.95; % rendimento pneumatico           [-]
    Motore.Diffusore.theta           = 8;    % semi-angolo di apertura [gradi]
                                                  % (limite distacco: < 8–10°)

    % Aggiornati nel main dopo compressore.m
    Motore.Diffusore.M_in = NaN;  % Mach ingresso (= mach_out compressore) [-]
    Motore.Diffusore.rm   = NaN;  % raggio medio  (= r_m_out compressore)  [m]

    % Calcolati da Diffusore.m
    Motore.Diffusore.Ain   = NaN; % area ingresso          [m²]
    Motore.Diffusore.Aout  = NaN; % area uscita            [m²]
    Motore.Diffusore.hin   = NaN; % altezza canale ingresso [m]
    Motore.Diffusore.hout  = NaN; % altezza canale uscita  [m]
    Motore.Diffusore.LD    = NaN; % lunghezza assiale       [m]
    Motore.Diffusore.v_in  = NaN; % velocità ingresso      [m/s]
    Motore.Diffusore.v_out = NaN; % velocità uscita        [m/s]

%%  CAMERA DI COMBUSTIONE

    Motore.Camera.r_m             = 0.35;  % raggio medio camera anulare   [m]
    Motore.Camera.DP_su_qref      = 20;    % fattore perdita dinamica ΔP/q [-]
    Motore.Camera.DP_su_P3_target = 0.06;  % perdita pressione totale      [-]
    Motore.Camera.I               = 9e6;   % intensità di combustione      [W/(m³·Pa)]
    Motore.Camera.eta_b           = 0.98;  % rendimento di combustione     [-]
    Motore.Camera.pi_b            = 0.97;  % rapporto di pressione camera  [-]

    % Calcolati da Camera_di_combustione.m
    Motore.Camera.A_ref = NaN;  % area di riferimento                     [m²]
    Motore.Camera.h_ref = NaN;  % altezza canale anulare                  [m]
    Motore.Camera.V     = NaN;  % volume camera                           [m³]
    Motore.Camera.Lc    = NaN;  % lunghezza camera                        [m]
    Motore.Camera.U_ref = NaN;  % velocità di riferimento                 [m/s]
    Motore.Camera.q_ref = NaN;  % pressione dinamica di riferimento       [Pa]
    Motore.Camera.M_ref = NaN;  % Mach di riferimento                     [-]


%%  TURBINA ASSIALE

    Motore.Turbina.eta_m  = 0.92;  % rendimento meccanico (albero)        [-]
    Motore.Turbina.eta_p  = 0.90;  % rendimento politropico espansione    [-]
    Motore.Turbina.machIn = 0.10;  % Mach assiale ingresso turbina        [-]

    % Curve di raffreddamento da tabelle (funzioni anonime di SOT in [K])
    % Output = frazione di mAir richiesta come cooling air
    Motore.Turbina.CoolingStatore = @(x) ...
        (x <  1100) .* 0 + ...
        (x >= 1100 & x <= 1650) .* (0.09 / (1600 - 1100) .* (x - 1100)) + ...
        (x >  1650) .* 0.5;

    Motore.Turbina.CoolingRotore = @(x) ...
        (x <  1250) .* 0 + ...
        (x >= 1250 & x <= 1600) .* (0.05 / (1400 - 1250) .* (x - 1250)) + ...
        (x >  1600) .* 0.5;

    % Curva perdite di profilo statore (fit polinomiale di grado 3 da tabelle)
    theta_val   = [0, 30, 60, 90, 120];            % angolo di deflessione [°]
    epsilon_val = [0.016, 0.022, 0.037, 0.058, 0.098]; % coefficiente di perdita [-]
    P_fit = polyfit(theta_val, epsilon_val, 3);
    Motore.Turbina.epsStadio = @(x) polyval(P_fit, x);  % x in gradi

    % Temperatura aria di raffreddamento: aggiornata nel main con T02 (uscita presa)
    Motore.Turbina.TCool = NaN;  % [K]

    % Calcolati da turbina.m
    Motore.Turbina.P0U       = NaN;  % pressione totale uscita            [Pa]
    Motore.Turbina.T0U       = NaN;  % temperatura totale uscita          [K]
    Motore.Turbina.T05_iso   = NaN;  % temperatura isoentropica uscita    [K]
    Motore.Turbina.SOT       = NaN;  % temperatura statica ingresso pale   [K]
    Motore.Turbina.coolPerc  = NaN;  % frazione aria di raffreddamento    [-]
    Motore.Turbina.eta_t     = NaN;  % rendimento adiabatico              [-]
    Motore.Turbina.eto       = NaN;  % rendimento non raffreddato         [-]
    Motore.Turbina.L_turbina = NaN;  % lavoro prodotto                    [W]
    Motore.Turbina.machOut   = NaN;  % Mach uscita                        [-]
    Motore.Turbina.A4        = NaN;  % area sezione ingresso              [m²]
    Motore.Turbina.A5        = NaN;  % area sezione uscita                [m²]

%%  UGELLO

    Motore.Ugello.eta_n = 1.0;    % rendimento ugello (1 = ideale)        [-]
    Motore.Ugello.tipo  = 'CD';   % 'CD' = conv-div   [-]

    % Calcolati da ugello.m
    Motore.Ugello.mach_e = NaN;   % Mach di efflusso                      [-]
    Motore.Ugello.Ue     = NaN;   % velocità di efflusso                  [m/s]
    Motore.Ugello.A_star = NaN;   % area di gola                          [m²]
    Motore.Ugello.A_e    = NaN;   % area di efflusso                      [m²]
    Motore.Ugello.D_e    = NaN;   % diametro di efflusso                  [m]

end