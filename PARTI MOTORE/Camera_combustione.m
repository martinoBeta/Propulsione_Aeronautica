function [P04, T04, Q_dot, motore] = Camera_combustione( ...
          motore, propFluidi, modo)
% CAMERA_DI_COMBUSTIONE
    
    % Parametri della camera di combustione
    camera = motore.camera;
    rMedio = camera.rMedio;
    perditaDinamica = camera.perditaDinamica;     %DP su qref 
    perditaPressione = camera.perditaPressione;    %Dp su P3
    I = camera.I;  
    etaB = camera.etaB;
    mAriaCalda   = motore.portate.mDotAir; 

    % Costanti combustibile 
    comb = propFluidi.combustibile;
    LHV   = comb.LHV;        % potere calorifico inferiore JP-7 [J/kg]
    
    % Motore
                 % rendimento di combustione [-]
            % portata aria che entra in camera [kg/s]
    T04  = camera.Tmax;             % temperatura target TIT in uscita camera [K]
    T03Primo = motre.diffusore.T03Primo;
    P03Primo = motre.diffusore.P03Primo;
    % Fluidi
    R     = propFluidi.R;           % costante del gas [J/(kg·K)]
    gamma = propFluidi.gamma;       % rapporto calori specifici gas combusti [-]
    
    % Costante stechiometrica JP-7 (C12H25)
    fStoich = 0.0634;
    
    % 2. DESIGN e BILANCIO ENERGETICO
    if strcmp(modo, 'design')
        % T04 è nota, calcola f iterativamente
        T04 = motore.Tmax;
        f   = 0.025;                % stima iniziale ragionevole per JP-7
        for k = 1:50
            % frazioni massiche prodotti JP-7 (C12H25, MM=169 kg/kmol)
            yCO2 = (f * 12*44/169) / (1+f);
            yH2O = (f * 12.5*18/169) / (1+f);
            yO2  = (0.232 - f*(18.25*32/169)) / (1+f);
            yN2  = 1 - yCO2 - yH2O - yO2;
            
            % cp specie a T04 [J/(kg·K)] — fit quadratico NASA
            cpN2  = 939  + 0.2274*T04 - 3.5e-5*T04^2;
            cpO2  = 880  + 0.2944*T04 - 5.2e-5*T04^2;
            cpCO2 = 570  + 0.8228*T04 - 1.8e-4*T04^2;
            cpH2O = 1520 + 0.4270*T04 - 5.0e-5*T04^2;
            
            cpG = yN2*cpN2 + yO2*cpO2 + yCO2*cpCO2 + yH2O*cpH2O;
            
            % cp aria a T03Primo — fit quadratico NASA
            cpA = 1007 + 0.0304*T03Primo - 1.524e-5*T03Primo^2;
            
            % bilancio energetico → f
            fNew = (cpG*T04 - cpA*T03Primo) / (LHV*etaB - cpG*T04);
            if abs(fNew - f) < 1e-7; break; end
            f = fNew;
        end
        f   = fNew;
        mF  = f * mAriaCalda;
        
        % --- CHECK 1: Equivalence ratio φ ---
        phi = f / fStoich;
        if phi < 0.3
            warning('CAM: LEAN BLOWOUT — fiamma instabile, phi = %.3f (min 0.3)', phi)
        elseif phi > 1.2
            warning('CAM: MISCELA RICCA — combustione incompleta, phi = %.3f (max 1.2)', phi)
        end
        
        % Calore liberato
        QDot = mF * LHV * etaB;     % [W]
        
        % 3. DIMENSIONAMENTO TRASVERSALE
        termineFlusso = (mAriaCalda * sqrt(T03Primo)) / P03Primo;
        ARef = sqrt( (R/2) * (termineFlusso^2) * (perditaDinamica / perditaPressione) );
        
        % Altezza del canale anulare
        hRef = ARef / (2 * pi * rMedio);    % [m]
        
        % Grandezze di verifica
        rho3  = P03Primo / (R * T03Primo);
        URef = mAriaCalda / (rho3 * ARef);
        qRef = 0.5 * rho3 * URef^2;
        MRef = URef / sqrt(gamma * R * T03Primo);
        
        % --- CHECK 2: Velocità di riferimento ---
        if URef < 15
            warning('CAM: velocità troppo bassa, rischio flashback — URef = %.1f m/s (min 15)', URef)
        elseif URef > 40
            warning('CAM: velocità troppo alta, rischio blowout — URef = %.1f m/s (max 40)', URef)
        end
        
        % --- CHECK 3: Mach di riferimento ---
        if MRef > 0.05
            warning('CAM: MRef troppo alto, perdite eccessive — MRef = %.4f (max 0.05)', MRef)
        end
        
        % 4. DIMENSIONAMENTO VOLUMETRICO E LONGITUDINALE
        V  = QDot / (I * P03Primo);   % [m³]
        LC = V / ARef;                % [m]
        
        % --- CHECK 4: Tempo di residenza ---
        tRes = LC / URef;
        if tRes < 6e-3
            error('CAM: tempo di residenza insufficiente — tRes = %.4f s (min 0.006 per JP-7)', tRes)
        end
        
        % --- CHECK 5: Intensità di combustione ---
        ICalcolata = QDot / (V * P03Primo);
        if ICalcolata > 15e6
            warning('CAM: intensità troppo alta, stress termico — I = %.2e W/(m³·Pa) (max 15e6)', ICalcolata)
        elseif ICalcolata < 3e6
            warning('CAM: intensità troppo bassa, camera sovradimensionata — I = %.2e W/(m³·Pa) (min 3e6)', ICalcolata)
        end
        
        % --- CHECK 6: Rapporto L/D ---
        DRef = sqrt(4 * ARef / pi);
        LD   = LC / DRef;
        if LD < 1.5
            warning('CAM: camera troppo corta, combustione incompleta — L/D = %.2f (min 1.5)', LD)
        elseif LD > 4.0
            warning('CAM: camera troppo lunga, peso eccessivo — L/D = %.2f (max 4.0)', LD)
        end
        
        % 5. CONDIZIONI DI USCITA
        P04 = (1 - perditaPressione) * P03Primo;
        
        % --- CHECK 7: Perdita di pressione effettiva ---
        DPEffettiva = 1 - P04/P03Primo;
        if DPEffettiva < 0.03
            warning('CAM: perdita di pressione sospettamente bassa — DP/P = %.3f (min 0.03)', DPEffettiva)
        elseif DPEffettiva > 0.08
            warning('CAM: perdita di pressione eccessiva — DP/P = %.3f (max 0.08)', DPEffettiva)
        end
    end
    
    % 6. AGGIORNAMENTO STRUCT DI OUTPUT
    camera.f   = f;
    camera.mF  = mF;
    propFluidi.gas.cpG = cpG;
    
    camera.ARef = ARef;
    camera.hRef = hRef;
    camera.V    = V;
    camera.LC   = LC;
    camera.URef = URef;
    camera.qRef = qRef;
    camera.MRef = MRef;
    camera.tRes = tRes;
    
    motore.Camera = camera;
    
    if strcmp(modo, 'off_design')
        % mF è nota (salvata da design point), trova T04Real
        mF = comb.mF;
        f  = mF / mAriaCalda;
        
        % --- CHECK 1: Equivalence ratio φ ---
        phi = f / fStoich;
        if phi < 0.3
            warning('CAM: LEAN BLOWOUT — phi = %.3f (min 0.3)', phi)
        elseif phi > 1.2
            warning('CAM: MISCELA RICCA — phi = %.3f (max 1.2)', phi)
        end
        
        % bilancio energetico ribaltato → T04Real, iterazione su cpG(T04)
        T04 = T03Primo;                % valore iniziale
        for k = 1:50
            yCO2 = (f * 12*44/169) / (1+f);
            yH2O = (f * 12.5*18/169) / (1+f);
            yO2  = (0.232 - f*(18.25*32/169)) / (1+f);
            yN2  = 1 - yCO2 - yH2O - yO2;
            
            cpN2  = 939  + 0.2274*T04 - 3.5e-5*T04^2;
            cpO2  = 880  + 0.2944*T04 - 5.2e-5*T04^2;
            cpCO2 = 570  + 0.8228*T04 - 1.8e-4*T04^2;
            cpH2O = 1520 + 0.4270*T04 - 5.0e-5*T04^2;
            
            cpG = yN2*cpN2 + yO2*cpO2 + yCO2*cpCO2 + yH2O*cpH2O;
            cpA = 1007 + 0.0304*T03Primo - 1.524e-5*T03Primo^2;
            
            T04New = (mDotAir*cpA*T03Primo + mF*LHV*etaB) / ((mDotAir + mF)*cpG);
            if abs(T04New - T04) < 0.01; break; end
            T04 = T04New;
        end
        T04  = T04New;
        QDot = mF * LHV * etaB;
        
        % In off-design la geometria fisica non cambia
        ARef = camera.ARef;
        hRef = camera.hRef;
        V    = camera.V;
        LC   = camera.LC;
        URef = camera.URef;
        qRef = camera.qRef;
        MRef = camera.MRef;
        tRes = camera.tRes;
    end
    % --- CHECK: T04_real vs limite strutturale ---
    if T04 > motore.Tmax * 1.05
        warning('CAM: T04_real supera TIT massimo del 5%% — T04 = %.1f K', T04)
    end
end
