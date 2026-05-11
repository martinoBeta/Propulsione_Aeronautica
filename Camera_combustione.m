function [P04, T04, Q_dot, propCamera, propCombust] = Camera_di_combustione( ...
    P03_primo, T03_primo, propCamera, propFluidi, motore, propCombust, modo)
% CAMERA_DI_COMBUSTIONE
% Funzione che svolge il ciclo termodinamico reale della camera di combustione,
% restituendo le condizioni termodinamiche in uscita e le caratteristiche
% geometriche per il dimensionamento della camera.
%
% INPUT:
%   P03_primo  : pressione totale in ingresso (dal dump diffuser) [Pa]
%   T03_primo  : temperatura totale in ingresso (dal dump diffuser) [K]
%   propCamera : struct con parametri geometrici noti della camera
%   propFluidi : struct con proprietà termodinamiche dei fluidi
%   motore     : struct con parametri globali del motore
%   propCombust: struct con proprietà del combustibile
%   modo       : 'design' oppure 'off_design'
%
% OUTPUT:
%   P04        : pressione totale in uscita dalla camera [Pa]
%   T04        : temperatura totale in uscita dalla camera [K]
%   Q_dot      : calore liberato durante la combustione [W]
%   propCamera : struct aggiornata con grandezze geometriche calcolate
%   propCombust: struct aggiornata con f, m_f, cp_g, cp_a

    % 1. ESTRAZIONE VARIABILI DALLE STRUCT

    % Combustibile
    LHV   = propCombust.LHV;        % potere calorifico inferiore JP-7 [J/kg]

    % Motore
    eta_b = motore.eta_b;           % rendimento di combustione [-]
    m_a   = motore.mDotCore;        % portata aria che entra in camera [kg/s]
    T04   = motore.Tmax;            % temperatura target TIT in uscita camera [K]

    % Fluidi
    R     = propFluidi.R;           % costante del gas [J/(kg·K)]
    gamma = propFluidi.gamma;       % rapporto calori specifici gas combusti [-]

    % Camera
    r_m             = propCamera.r_m;             % raggio medio anulare [m]
    DP_su_qref      = propCamera.DP_su_qref;      % fattore perdita dinamica [-]
    DP_su_P3_target = propCamera.DP_su_P3_target; % perdita di pressione target [-]
    I               = propCamera.I;               % intensità di combustione [W/(m³·Pa)]

    % Costante stechiometrica JP-7 (C12H25)
    f_stoich = 0.0634;

    % 2. DESIGN e BILANCIO ENERGETICO

    if strcmp(modo, 'design')
        % T04 è nota, calcola f iterativamente

        T04 = motore.Tmax;
        f   = 0.025;                % stima iniziale ragionevole per JP-7

        for k = 1:50
            % frazioni massiche prodotti JP-7 (C12H25, MM=169 kg/kmol)
            Y_CO2 = (f * 12*44/169) / (1+f);
            Y_H2O = (f * 12.5*18/169) / (1+f);
            Y_O2  = (0.232 - f*(18.25*32/169)) / (1+f);
            Y_N2  = 1 - Y_CO2 - Y_H2O - Y_O2;

            % cp specie a T04 [J/(kg·K)] — fit quadratico NASA
            cp_N2  = 939  + 0.2274*T04 - 3.5e-5*T04^2;
            cp_O2  = 880  + 0.2944*T04 - 5.2e-5*T04^2;
            cp_CO2 = 570  + 0.8228*T04 - 1.8e-4*T04^2;
            cp_H2O = 1520 + 0.4270*T04 - 5.0e-5*T04^2;

            cp_g = Y_N2*cp_N2 + Y_O2*cp_O2 + Y_CO2*cp_CO2 + Y_H2O*cp_H2O;

            % cp aria a T03_primo — fit quadratico NASA
            cp_a = 1007 + 0.0304*T03_primo - 1.524e-5*T03_primo^2;

            % bilancio energetico → f
            f_new = (cp_g*T04 - cp_a*T03_primo) / (LHV*eta_b - cp_g*T04);

            if abs(f_new - f) < 1e-7; break; end
            f = f_new;
        end
        f   = f_new;
        m_f = f * m_a;

        % --- CHECK 1: Equivalence ratio φ ---
        phi = f / f_stoich;
        if phi < 0.3
            warning('CAM: LEAN BLOWOUT — fiamma instabile, phi = %.3f (min 0.3)', phi)
        elseif phi > 1.2
            warning('CAM: MISCELA RICCA — combustione incompleta, phi = %.3f (max 1.2)', phi)
        end

        % Calore liberato
        Q_dot = m_f * LHV * eta_b;     % [W]

        % 3. DIMENSIONAMENTO TRASVERSALE
        termine_flusso = (m_a * sqrt(T03_primo)) / P03_primo;
        A_ref = sqrt( (R/2) * (termine_flusso^2) * (DP_su_qref / DP_su_P3_target) );

        % Altezza del canale anulare
        h_ref = A_ref / (2 * pi * r_m);    % [m]

        % Grandezze di verifica
        rho3  = P03_primo / (R * T03_primo);
        U_ref = m_a / (rho3 * A_ref);
        q_ref = 0.5 * rho3 * U_ref^2;
        M_ref = U_ref / sqrt(gamma * R * T03_primo);

        % --- CHECK 2: Velocità di riferimento ---
        if U_ref < 15
            warning('CAM: velocità troppo bassa, rischio flashback — U_ref = %.1f m/s (min 15)', U_ref)
        elseif U_ref > 40
            warning('CAM: velocità troppo alta, rischio blowout — U_ref = %.1f m/s (max 40)', U_ref)
        end

        % --- CHECK 3: Mach di riferimento ---
        if M_ref > 0.05
            warning('CAM: M_ref troppo alto, perdite eccessive — M_ref = %.4f (max 0.05)', M_ref)
        end

        % 4. DIMENSIONAMENTO VOLUMETRICO E LONGITUDINALE
        V  = Q_dot / (I * P03_primo);   % [m³]
        Lc = V / A_ref;                 % [m]

        % --- CHECK 4: Tempo di residenza ---
        t_res = Lc / U_ref;
        if t_res < 6e-3
            error('CAM: tempo di residenza insufficiente — t_res = %.4f s (min 0.006 per JP-7)', t_res)
        end

        % --- CHECK 5: Intensità di combustione ---
        I_calcolata = Q_dot / (V * P03_primo);
        if I_calcolata > 15e6
            warning('CAM: intensità troppo alta, stress termico — I = %.2e W/(m³·Pa) (max 15e6)', I_calcolata)
        elseif I_calcolata < 3e6
            warning('CAM: intensità troppo bassa, camera sovradimensionata — I = %.2e W/(m³·Pa) (min 3e6)', I_calcolata)
        end

        % --- CHECK 6: Rapporto L/D ---
        D_ref = sqrt(4 * A_ref / pi);
        LD    = Lc / D_ref;
        if LD < 1.5
            warning('CAM: camera troppo corta, combustione incompleta — L/D = %.2f (min 1.5)', LD)
        elseif LD > 4.0
            warning('CAM: camera troppo lunga, peso eccessivo — L/D = %.2f (max 4.0)', LD)
        end

        % 5. CONDIZIONI DI USCITA
        P04 = (1 - DP_su_P3_target) * P03_primo;

        % --- CHECK 7: Perdita di pressione effettiva ---
        DP_effettiva = 1 - P04/P03_primo;
        if DP_effettiva < 0.03
            warning('CAM: perdita di pressione sospettamente bassa — DP/P = %.3f (min 0.03)', DP_effettiva)
        elseif DP_effettiva > 0.08
            warning('CAM: perdita di pressione eccessiva — DP/P = %.3f (max 0.08)', DP_effettiva)
        end

    end

    if strcmp(modo, 'off_design')
        % m_f è nota (salvata da design point), trova T04_real

        m_f = propCombust.m_f;
        f   = m_f / m_a;

        % --- CHECK 1: Equivalence ratio φ (anche in off-design) ---
        phi = f / f_stoich;
        if phi < 0.3
            warning('CAM: LEAN BLOWOUT — fiamma instabile, phi = %.3f (min 0.3)', phi)
        elseif phi > 1.2
            warning('CAM: MISCELA RICCA — combustione incompleta, phi = %.3f (max 1.2)', phi)
        end

        % bilancio energetico ribaltato → T04_real, iterazione su cp_g(T04)
        T04 = T03_primo;                % valore iniziale
        for k = 1:50
            % frazioni massiche: f è fisso, solo T04 itera
            Y_CO2 = (f * 12*44/169) / (1+f);
            Y_H2O = (f * 12.5*18/169) / (1+f);
            Y_O2  = (0.232 - f*(18.25*32/169)) / (1+f);
            Y_N2  = 1 - Y_CO2 - Y_H2O - Y_O2;

            cp_N2  = 939  + 0.2274*T04 - 3.5e-5*T04^2;
            cp_O2  = 880  + 0.2944*T04 - 5.2e-5*T04^2;
            cp_CO2 = 570  + 0.8228*T04 - 1.8e-4*T04^2;
            cp_H2O = 1520 + 0.4270*T04 - 5.0e-5*T04^2;

            cp_g = Y_N2*cp_N2 + Y_O2*cp_O2 + Y_CO2*cp_CO2 + Y_H2O*cp_H2O;

            cp_a = 1007 + 0.0304*T03_primo - 1.524e-5*T03_primo^2;

            T04_new = (m_a*cp_a*T03_primo + m_f*LHV*eta_b) / ((m_a + m_f)*cp_g);

            if abs(T04_new - T04) < 0.01; break; end
            T04 = T04_new;
        end
        T04   = T04_new;
        Q_dot = m_f * LHV * eta_b;

        % grandezze geometriche non ricalcolate in off-design:
        % A_ref, h_ref, V, Lc, U_ref, q_ref, M_ref, t_res
        % restano quelle del design (geometria fisica non cambia)
        A_ref = propCamera.A_ref;
        h_ref = propCamera.h_ref;
        V     = propCamera.V;
        Lc    = propCamera.Lc;
        U_ref = propCamera.U_ref;
        q_ref = propCamera.q_ref;
        M_ref = propCamera.M_ref;
        t_res = propCamera.t_res;

        % --- CHECK: T04_real vs limite strutturale ---
        if T04 > motore.Tmax * 1.05
            warning('CAM: T04_real supera TIT massimo del 5%% — T04 = %.1f K', T04)
        end

    end

    % 6. AGGIORNAMENTO STRUCT DI OUTPUT
    propCombust.f    = f;
    propCombust.m_f  = m_f;
    propCombust.cp_g = cp_g;
    propCombust.cp_a = cp_a;

    propCamera.A_ref = A_ref;
    propCamera.h_ref = h_ref;
    propCamera.V     = V;
    propCamera.Lc    = Lc;
    propCamera.U_ref = U_ref;
    propCamera.q_ref = q_ref;
    propCamera.M_ref = M_ref;
    propCamera.t_res = t_res;

end
