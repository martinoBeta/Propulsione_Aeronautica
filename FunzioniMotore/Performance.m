function [motore] = Performance(motore)
    % Calcolo Delle Performance Del Motore
    %% 
    regime = motore.presaAria.regime;
    if regime == "subsonico"
        vVolo = motore.freestream.h12km.V0;
    elseif regime == "supersonico"
        vVolo = motore.freestream.h25km.V0;
    end


    uE = motore.ugello.Ue;
    mDotComb = motore.portate.mDotComb;

    % SPINTA
    mDotGas = motore.portate.mDotGas;
    mDotAria = motore.portate.mDot;
    f = motore.camera.f;

    F = mDotGas*uE - mDotAria*vVolo;

    % TSFC
    TSFC = mDotComb/F*3600; %kg/(hN)

    % RENDIMENTO TOTALE
    %F_is = CicloIdeale(motore,vVolo,mDotGas);
    LHV = motore.fluidi.combustibile.LHV;
    etaGlobal = F*vVolo/(mDotComb*LHV);
    
    % Rendimento Termodinamico 
    etaTh = (0.5*mDotGas*uE^2 - 0.5*mDotAria*vVolo^2)/(mDotComb*LHV);

    % Rendimento Propulsivo
    etaProp = F*vVolo/(0.5*mDotGas*uE^2 - 0.5*mDotAria*vVolo^2);

    % spinta specifica
    ISP = F/mDotAria;

    motore.performance.F         = F;
    motore.performance.etaGlobal = etaGlobal;
    motore.performance.TSFC     = TSFC;
    motore.performance.etaProp  = etaProp;
    motore.performance.etaTh    = etaTh;
    motore.performance.ISP      = ISP;




end