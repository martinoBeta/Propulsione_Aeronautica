function [motore] = Performance(motore)
% PERFORMANCE Calcola le performance del motore, tra 
% cui spinta, TSFC e rendimenti.   
% 
%   [motore] = Performance(motore)  
 
    % Estrazione variabili del freestream
    regime = motore.presaAria.regime;
    if regime == "subsonico"
        vVolo = motore.freestream.h12km.V0;
    elseif regime == "supersonico"
        vVolo = motore.freestream.h25km.V0;
    end


    uE = motore.ugello.Ue;
    mDotComb = motore.portate.mDotComb;

    % spinta
    mDotGas = motore.portate.mDotGas;
    mDotAria = motore.portate.mDot;
    f = motore.camera.f;
    
    if regime == "subsonico"
        F = mDotGas*uE - mDotAria*vVolo;
        uEq = uE;
    elseif regime == "supersonico"
        AE = motore.ugello.AE;
        PU = motore.freestream.h25km.P0;
        PE = motore.ugello.PE;
        F = mDotGas*uE - mDotAria*vVolo + AE*(PE-PU);
        uEq = uE + (AE*(PE-PU))/mDotGas;
    end
    

    % TSFC
    TSFC = mDotComb/F*3600; %kg/(hN)

    % rendimento totale
    LHV = motore.fluidi.combustibile.LHV;
    etaGlobal = F*vVolo/(mDotComb*LHV);
    
    % Rendimento Termodinamico 
    etaTh = (0.5*mDotGas*uEq^2 - 0.5*mDotAria*vVolo^2)/(mDotComb*LHV);

    % Rendimento Propulsivo
    etaProp = F*vVolo/(0.5*mDotGas*uEq^2 - 0.5*mDotAria*vVolo^2);

    % spinta specifica
    F_s = F/mDotAria;

    motore.performance.F         = F;
    motore.performance.etaGlobal = etaGlobal;
    motore.performance.TSFC     = TSFC;
    motore.performance.etaProp  = etaProp;
    motore.performance.etaTh    = etaTh;
    motore.performance.F_s      = F_s;
    
end