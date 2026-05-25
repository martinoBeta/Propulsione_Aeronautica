function [opt,motore] = runnerMotore(motore,parametri)
    motore = Parametri(motore,parametri);
    motore = PresaDaria(motore);
    motore = Compressore(motore);
    motore = StimaSpillaggio(motore);
    motore = Diffusore(motore);
    motore = CameraCombustione(motore);
    motore = Turbina(motore);
    motore = Ugello(motore); 
    motore = Performance(motore);

    % max_radius = max(motore.turbina.rt5,(motore.compressore.r_m_out+motore.compressore.hOut/2));%1/motore.performance.etaGlobal;%motore.performance.TSFC;
    %opt = motore.performance.TSFC;% max_radius;

    % Funzione obiettivo: TSFC + ingombro radiale 

    TSFC_ref = 0.12;   % valore di riferimento realistico
    A_ref    = 1;   % area massimo di riferimento (da scegliere)

    A_comp_in  = motore.presaAria.A2;
    A_comp_out = motore.compressore.Aout_c;
    A_diff_out = motore.diffusore.A35;
    A_camera   = motore.camera.ARef;
    A_turb_in  = motore.turbina.A4;
    A_turb_out = motore.turbina.A5;
    A_ugello   = motore.ugello.AE;

    A_max = max([A_comp_in, A_comp_out, A_diff_out, A_camera, ...
                  A_turb_in, A_turb_out, A_ugello]);

    J_TSFC = motore.performance.TSFC / TSFC_ref;
    J_A    = A_max / A_ref;
    
    % pesi
    wTSFC = 0.45;
    wR    = 0.55;
   
    opt = wTSFC*J_TSFC + wR*J_A;
end
