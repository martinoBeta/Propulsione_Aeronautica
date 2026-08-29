function [parametri,RangeParametri] = structParametri()
% STRUCTPARAMETRI Funzione che inizializza i parametri di progetto del turbogetto
%
%  [parametri,RangeParametri] = structParametri()
% 0  --> flusso indisturbato
% 2  --> uscita presa d'aria
% 3 --> uscita anulus
% 4  --> uscita camera di combustione
% 5 --> uscita turbina
% 6  --> uscita ugello

% I seguenti parametri sono i parametri di base;
% Vettore colonna parametri

parametri = [ ...
    35;     % mDot     -> Portata massica in ingresso
    4;      % piC     -> Rapporto di compressione compressore
    400;    % Utip     -> Velocità periferica tip compressore
    1600;   % T04      -> Temperatura totale uscita camera / ingresso turbina 
    
];
RangeParametri = [...

    20 60
    3 30;
    330 410;
    1200 1700;
];

end
