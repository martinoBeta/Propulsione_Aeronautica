function [motore] = Performance(motore)
    % Calcolo Delle Performance Del Motore
    %% 
    vVolo = motore.freestream.h12km.V0;
    uE = motore.ugello.Ue;
    mDotComb = motore.portate.mDotComb;

    % SPINTA
    mDotGas = motore.portate.mDotGas;

    F = mDotGas*(uE-vVolo);

    % TSFC
    TSFC = mDotComb/F*3600; %kg/(hN)

    % RENDIMENTO TOTALE
    F_is = CicloIdeale(motore,vVolo,mDotGas);
    etaGlobal = F/F_is;

    motore.performance.F         = F;
    motore.performance.etaGlobal = etaGlobal;
    motore.performance.TSFC     = TSFC;


end

function F_is = CicloIdeale(motore,vVolo,mDotGas)
    mDotAria = motore.portate.mDotAir;

    piC = motore.compressore.piC;
    P00 = motore.freestream.h12km.P00;
    P0 = motore.freestream.h12km.P0;
    T00 = motore.freestream.h12km.T00;
    gammaA = motore.fluidi.aria.gamma;
    gammaG = motore.fluidi.gas.gamma;
    cpA = motore.fluidi.aria.cp;
    cpG = motore.fluidi.gas.cp;
    
    P03_is = P00*piC;
    T03_is = T00*(1/piC)^((1-gammaA)/gammaA);
    T04_is = motore.camera.T04;
    T05_is = T04_is - cpA * mDotAria * (T03_is-T00)/(cpG*mDotGas);
    % T05_is = T04_is - (T03_is-T00);

    P05_is = P03_is*(T04_is/T05_is)^(gammaG/(1-gammaG));
    Mexit_is = sqrt( (2/(gammaG-1)) * ( (P05_is/P0)^((gammaG-1)/gammaG) - 1 ) );
    Texit_is = T05_is / (1 + (gammaG-1)/2 * Mexit_is^2);
    vExit_is = Mexit_is *sqrt(motore.fluidi.gas.R*gammaG*Texit_is);
    F_is = mDotGas*(vExit_is-vVolo);
end