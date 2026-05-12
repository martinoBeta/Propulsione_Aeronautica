clc
clear 
close all
addpath("FunzioniMotore")
propFluidi = structFluidi();
motoreBase = structMotore();

motore = runnerMotore(motoreBase,propFluidi);


%% OTTIMIZZAZIONE


FS = 1; % fattore di sicurezza


best_N_stadi = 100000;
best_Ain     = 100000;

for Utip = Utip_range
for machIns = machIn_range
    for pi_c = pi_c_range

        motore = runnerMotore(motoreBase,propFluidi);
        if motore.compressore.Mach_rel  < FS*1.0  && ...  % Vincoli aerodinamici compressore
           motore.compressore.Cp_stadio < FS*0.5  && ...
           motore.compressore.deHaller  > 0.72/FS && ...
           motore.compressore.D_rotore  < FS*0.6  && ...
           motore.compressore.D_statore < FS*0.6  && ...
           motore.compressore.N_stadi   < 20     && ...  % Vincoli geometrici compressore
           motore.compressore.N_R       < 180    && ...
           motore.compressore.r_m_in   < 1.2     && ...
           motore.compressore.r_m_out   < 1.2 


            nuovaSoluzione = false;

            if N_stadi < best_N_stadi
                nuovaSoluzione = true;

            elseif N_stadi == best_N_stadi && Ain < best_Ain
                nuovaSoluzione = true;
            end

            if nuovaSoluzione

                best_N_stadi = N_stadi;
                best_Ain = Ain;

                best_machIn = machIns;
                best_Utip = Utip;
                best_pi_c = pi_c;

                best_T0U = T0U;
                best_P0U = P0U;
                best_L_comp = L_comp;
                best_eta_c = eta_c;

                best_Mach_rel = Mach_rel;
                best_Mach_abs = Mach_abs;

                best_Cp = Cp_stadio;
                best_deHaller = deHaller;

                best_D_rotore = D_rotore;
                best_D_statore = D_statore;
                best_R_m = R_m;

                best_Va = Va;
                best_beta1 = beta1;
                best_beta2 = beta2;

                best_Aout = Aout;

                best_r_m_in = r_m_in;
                best_h_in = h_in;

                best_r_m_out = r_m_out;
                best_h_out = h_out;

                best_c_m = c_m;
                best_N_R = N_R;

            end
        end
    end
end
end

if best_N_stadi == 100000
    error('Nessuna configurazione valida trovata')
end