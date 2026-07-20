%% SCRIPT per presa d'aria supersonica con 3 onde oblique
ramjet = motore; 

% COSTANTI E PARAMETRI INGRESSO

R     = ramjet.fluidi.aria.R;
gamma = ramjet.fluidi.aria.gamma;

T00   = ramjet.freestream.h25km.T00;
P00   = ramjet.freestream.h25km.P00;
rho0  = ramjet.freestream.h25km.rho0;
M0    = ramjet.freestream.h25km.M0;
V0    = ramjet.freestream.h25km.V0;
mDot  = ramjet.portate.mDot;


% 1. OTTIMIZZAZIONE ANGOLI (CRITERIO OSWATITSCH)

% Funzione per il recupero totale di un singolo urto
recPressTot = @(Mn, gamma) ( ((gamma+1)/2 * Mn^2) / (1 + (gamma-1)/2 * Mn^2) )^(gamma/(gamma-1)) * ...
                    ( 1 / (2*gamma/(gamma+1) * Mn^2 - (gamma-1)/(gamma+1)) )^(1/(gamma-1));

% Ricerca del rapporto di pressione statica 'rRatio' che massimizza il recupero.
funObj = @(rRatio) -ottimizzaUrti(rRatio, M0, gamma, recPressTot);
options = optimset('Display','off');

% I limiti [1.05, 5] escludono onde di Mach non compressive (<= 1) e
% distacco urto/flusso subsonico prematuro (> 5).
recOpt = fminbnd(funObj, 1.05, 5, options); 

% Ricavo il Mach normale (costante per i 3 urti obliqui)
MnOpt = sqrt(1 + (recOpt-1)*(gamma+1)/(2*gamma));

% --- 1° Urto ---
theta1 = asin(MnOpt/M0);
delta1 = atan( 2*cot(theta1) * (M0^2*sin(theta1)^2 - 1) / (M0^2*(gamma+cos(2*theta1)) + 2) );
M1 = sqrt( (1+(gamma-1)/2*MnOpt^2) / (gamma*MnOpt^2 - (gamma-1)/2) ) / sin(theta1 - delta1);
pi1 = recPressTot(MnOpt, gamma);

% --- 2° Urto ---
theta2 = asin(MnOpt/M1);
delta2 = atan( 2*cot(theta2) * (M1^2*sin(theta2)^2 - 1) / (M1^2*(gamma+cos(2*theta2)) + 2) );
M2 = sqrt( (1+(gamma-1)/2*MnOpt^2) / (gamma*MnOpt^2 - (gamma-1)/2) ) / sin(theta2 - delta2);
pi2 = recPressTot(MnOpt, gamma);

% --- 3° Urto ---
theta3 = asin(MnOpt/M2);
delta3 = atan( 2*cot(theta3) * (M2^2*sin(theta3)^2 - 1) / (M2^2*(gamma+cos(2*theta3)) + 2) );
M3 = sqrt( (1+(gamma-1)/2*MnOpt^2) / (gamma*MnOpt^2 - (gamma-1)/2) ) / sin(theta3 - delta3);
pi3 = recPressTot(MnOpt, gamma);

% --- Urto Normale ---
M4 = sqrt( (M3^2+2/(gamma-1))/(2*gamma/(gamma-1)*M3^2-1) );
pi4 = recPressTot(M3, gamma);


% 2. CALCOLO GASDINAMICO A CASCATA

P01 = P00 * pi1;
P02 = P01 * pi2;
P03 = P02 * pi3;
P04 = P03 * pi4;
piTot = P04 / P00;

% Condizioni finali (ingresso camera combustione - Stazione 2)
T04 = T00; % Flusso adiabatico
T2 = T04 / (1 + (gamma - 1) / 2 * M4^2);
P2 = P04 / (1 + (gamma - 1) / 2 * M4^2)^(gamma/(gamma-1));
rho2 = P2 / (R * T2);
a2 = sqrt(gamma * R * T2); % a (velocita' del suono) resta minuscola per convenzione
V2 = M4 * a2;

% Efficienza termodinamica
etaD = ((piTot^((gamma-1)/gamma)) * (1 + (gamma-1)/2 * M0^2) - 1) / ((gamma-1)/2 * M0^2);


% 3. DIMENSIONAMENTO GEOMETRICO (Shock-on-lip condizione usata)

ACatt = mDot / (rho0 * V0);
hCatt = sqrt(ACatt / 2);
wCatt = 2 * hCatt;

% 1° Rampa
LSuper = hCatt / tan(theta1);
LOnda1 = hCatt / sin(theta1); 

% 2° Rampa
LRampa12 = LOnda1 * sin(theta2 + delta1 - theta1) / sin(pi - theta2);
LOnda2 = LOnda1 * sin(theta1 - delta1) / sin(pi - theta2);

% 3° Rampa
LRampa23 = LOnda2 * sin(theta3 + delta2 - theta2) / sin(pi - theta3);
LOnda3 = LOnda2 * sin(theta2 - delta2) / sin(pi - theta3);

% Rampa Gola (L'onda normale chiude perpendicolare al flusso M3)
LRampa34 = LOnda3 * cos(theta3 - delta3);

% Altezza gola (calcolata in maniera esatta sull'ultimo triangolo)
hGola = LOnda3 * sin(theta3 - delta3);
AGola = mDot / (rho2 * V2);
wGola = AGola / hGola;

deltaS = 0.1 * LSuper;
deltaCaren = deg2rad(4);


% 4. SALVATAGGIO IN STRUCT

ramjet.presaAria.delta1     = delta1;
ramjet.presaAria.delta2     = delta2;
ramjet.presaAria.delta3     = delta3;
ramjet.presaAria.theta1     = theta1;
ramjet.presaAria.theta2     = theta2;
ramjet.presaAria.theta3     = theta3;

ramjet.presaAria.T2         = T2;
ramjet.presaAria.P2         = P2;
ramjet.presaAria.T02        = T04;
ramjet.presaAria.P02        = P04;
ramjet.presaAria.M2         = M4;
ramjet.presaAria.eta_d      = etaD;
ramjet.presaAria.rho2       = rho2;
ramjet.presaAria.V2         = V2;
ramjet.presaAria.CPR        = piTot;
ramjet.presaAria.LSuper     = LSuper;
ramjet.presaAria.LRampa12   = LRampa12;
ramjet.presaAria.LRampa23   = LRampa23;
ramjet.presaAria.LRampa34   = LRampa34;
ramjet.presaAria.LOnda1     = LOnda1;
ramjet.presaAria.LOnda2     = LOnda2;
ramjet.presaAria.LOnda3     = LOnda3;
ramjet.presaAria.hCatt      = hCatt;
ramjet.presaAria.hGola      = hGola;
ramjet.presaAria.ACatt      = ACatt;
ramjet.presaAria.wCatt      = wCatt;
ramjet.presaAria.wGola      = wGola;
ramjet.presaAria.A2         = AGola;
ramjet.presaAria.piTot      = piTot;
ramjet.presaAria.deltaS     = deltaS;
ramjet.presaAria.deltaCaren = deltaCaren;

motore = ramjet;


% FUNZIONI LOCALI

function piTotVal = ottimizzaUrti(rRatio, M0, gamma, recPressTot)
    % Calcola il recupero totale a partire da un dato rapporto di pressione
    % statica
    Mn = sqrt(1 + (rRatio-1)*(gamma+1)/(2*gamma));
    
    % Controlli di sicurezza per Mn
    if Mn <= 1 || Mn >= M0; piTotVal = 0; return; end
    
    % Urto 1
    th1 = asin(Mn/M0);
    de1 = atan( 2*cot(th1) * (M0^2*sin(th1)^2 - 1) / (M0^2*(gamma+cos(2*th1)) + 2) );
    Mn21 = sqrt( (1+(gamma-1)/2*Mn^2) / (gamma*Mn^2 - (gamma-1)/2) );
    M1 = Mn21 / sin(th1 - de1);
    if ~isreal(M1) || M1 <= 1; piTotVal = 0; return; end
    
    % Urto 2
    if Mn >= M1; piTotVal = 0; return; end
    th2 = asin(Mn/M1);
    de2 = atan( 2*cot(th2) * (M1^2*sin(th2)^2 - 1) / (M1^2*(gamma+cos(2*th2)) + 2) );
    Mn22 = sqrt( (1+(gamma-1)/2*Mn^2) / (gamma*Mn^2 - (gamma-1)/2) );
    M2 = Mn22 / sin(th2 - de2);
    if ~isreal(M2) || M2 <= 1; piTotVal = 0; return; end
    
    % Urto 3
    if Mn >= M2; piTotVal = 0; return; end
    th3 = asin(Mn/M2);
    de3 = atan( 2*cot(th3) * (M2^2*sin(th3)^2 - 1) / (M2^2*(gamma+cos(2*th3)) + 2) );
    Mn23 = sqrt( (1+(gamma-1)/2*Mn^2) / (gamma*Mn^2 - (gamma-1)/2) );
    M3 = Mn23 / sin(th3 - de3);
    if ~isreal(M3) || M3 <= 1; piTotVal = 0; return; end
    
    % Recupero Totale (da minimizzare)
    pi1 = recPressTot(Mn, gamma);
    pi2 = recPressTot(Mn, gamma);
    pi3 = recPressTot(Mn, gamma);
    pi4 = recPressTot(M3, gamma); 

    piTotVal = pi1 * pi2 * pi3 * pi4;
end