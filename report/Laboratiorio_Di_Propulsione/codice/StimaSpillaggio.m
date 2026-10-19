function [motore] = StimaSpillaggio(motore)
% STIMASPILLAGGIO stima lo spillagio dell'aria dal 
% compressore per potere poi raffreddare la turbina
% 
%   [motore] = StimaSpillaggio(motore)
    
    TMax  = motore.camera.T04;
    gammaGas = motore.fluidi.gas.gamma;
    propTurbina = motore.turbina;
    mDot = motore.portate.mDot;


    %SOT (non temperatura a fine turbina) [K]
    Sot = 2/(gammaGas+1)*TMax;   

    %Eps = mc/mtot.  percentuale di aria raffredata .
    raffPecentuale = propTurbina.coolingRotore(Sot) + propTurbina.coolingStatore(Sot); 
        

    motore.portate.mDotAir = mDot*(1-raffPecentuale);
    motore.portate.mDotRaff = mDot*raffPecentuale;
end