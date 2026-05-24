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
    40;     % mDot     -> Portata massica in ingresso
    4;      % piC     -> Rapporto di compressione compressore
    1600;   % T04      -> Temperatura totale uscita camera / ingresso turbina
];

RangeParametri = [...
    20 80;
    3 30;
    1400 1401;
];


% oottimale
% [39.140244256121989	0.300000000000000	38.776308385574652	3.978941639812600e+02	3.840544421890678	29.037660536907595	1400	2.399999990378657e+03	97.568713852034122	0.312003183893379	0.835740539155935]
% [53.933186422137652	0.399999996011306	38.255812925925014	3.600016096457816e+02	2.660849121696416	28.560293448610700	1201	2.399999992138714e+03	80.055214222802050	0.395372152498520	0.824632818121281
end
