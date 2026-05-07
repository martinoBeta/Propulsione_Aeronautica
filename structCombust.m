function [propCombust] = structCombust(propFluidi)
% Parametri del combustibile e stato iniziale per la camera di combustione
%
% INPUT:
%   propFluidi : struct fluidi (serve per coerenza, LHV già dentro)
%
% OUTPUT:
%   propCombust : struct con proprietà combustibile inizializzate a NaN
%                 (verranno popolate da Camera_di_combustione.m)

    % Proprietà del combustibile (cherosene Jet-A)
    propCombust.nome  = 'Jet-A';
    propCombust.LHV   = propFluidi.LHV;    % potere calorifico inf. [J/kg]                                           

    % Valori calcolati - inizializzati a NaN, popolati da Camera_di_combustione.m
    propCombust.f     = 0;   % rapporto combustibile/aria locale nella camera [-]
    propCombust.m_f   = 0;   % portata combustibile [kg/s]

end
