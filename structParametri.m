function [parametri,RangeParametri] = structParametri()
%FUNZIONE NON COMPLETATA DATI NON ATTENDIBILI!!!!
%%
% 0  --> flusso indisturbato
% 2  --> uscita presa d'aria
% 3 --> uscita anulus
% 4  --> uscita camera di combustione
% 5 --> uscita turbina
% 6  --> uscita ugello

% I seguenti parametri sono i parametri di base;
% Vettore colonna parametri

parametri = [ ...
    31;     % mDot     -> Portata massica in ingresso
    0.35;   % mach2    -> Mach ingresso compressore (M2)
    4;      % piC     -> Rapporto di compressione compressore
    400;    % Utip     -> Velocità periferica tip compressore
    5;      % theta    -> Angolo apertura diffusore
    25;     % vtargetcamera -> Velocità target verso camera di combustione
    1600;   % T04      -> Temperatura totale uscita camera / ingresso turbina
    2200;   % TComb    -> Temperatura di combustione
    80;     % I        -> Intesità di combustione
    0.3;    % mach4    -> Mach ingresso turbina
    0.9;    % wmachOut -> Mach relativo uscita rotore turbina
];

RangeParametri = [...
    30 80;
    0.3 0.4;
    3 11;
    360 410;
    2.5 4;
    25 40;
    1400 1700;
    2000 2400;
    80 100;
    0.3 0.4;
    0.8 0.9;
];


% oottimale
% [34.128224895878006	0.390307131066697	10.204026814709490  3.539356540888523e+02	3.116679083337874	25.200335799275233	1.528819575563447e+03	2.299761038395390e+03	80.227769177903994	0.337679065680598	0.845092242124904]

end
