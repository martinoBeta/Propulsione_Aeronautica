function [motore] = PresaDaria(motore)

    regime = motore.presaAria.regime;

    if regime == "subsonico"


        %% presaAria SUBSONICA

        R = motore.fluidi.aria.R;
        gamma = motore.fluidi.aria.gamma;

        P0   = motore.freestream.h12km.P0;
        rho0 = motore.freestream.h12km.rho0;
        V0   = motore.freestream.h12km.V0;
        T00  = motore.freestream.h12km.T00;
        P00  = motore.freestream.h12km.P00;

        mach2   = motore.presaAria.mach2;
        piD= motore.presaAria.piD;
        
        mDotAir = motore.portate.mDot;
       

        T02 = T00;
        P02 = piD * P00;

        T2 = T02 / (1 + (gamma - 1)/2 * mach2^2);

        P2 = P02 / (1 + (gamma - 1)/2 * mach2^2)^ ...
             (gamma/(gamma - 1));

        rho2 = P2 / (R * T2);

        a2 = sqrt(gamma * R * T2);
        V2 = mach2 * a2;

        A_ingresso = mDotAir / (rho0 * V0);

        A2 = mDotAir / (rho2 * V2);

        q0 = 0.5 * rho0 * V0^2;

        CPR = (P2 - P0) / q0;

        % OUTPUT
        motore.presaAria.A0 = A_ingresso;
        
        motore.presaAria.T02 = T02;
        motore.presaAria.P02 = P02;

        motore.presaAria.T2 = T2;
        motore.presaAria.P2 = P2;

        motore.presaAria.rho2 = rho2;
        motore.presaAria.V2 = V2;

        motore.presaAria.A0 = A_ingresso;
        motore.presaAria.A2 = A2;

        motore.presaAria.CPR = CPR;

    elseif regime == "supersonico"

        %% presaAria SUPERSONICA
%         ramjet = motore;
%         % Costanti 
%         R = ramjet.fluidi.aria.R;
%         gamma = ramjet.fluidi.aria.gamma;
% 
%         % Parametri aria ingresso  
%         T00 = ramjet.freestream.h25km.T00;  
%         P00 = ramjet.freestream.h25km.P00;  
%         rho0 = ramjet.freestream.h25km.rho0; 
%         M0 = ramjet.freestream.h25km.M0;   
%         V0 = ramjet.freestream.h25km.V0;   
%         mDot = ramjet.portate.mDot;
% 
%         %Parametri scelti
%         delta1 = ramjet.presaAria.delta1;
%         delta2 = ramjet.presaAria.delta2;
%         theta1 = ramjet.presaAria.theta1;
%         theta2 = ramjet.presaAria.theta2;
% 
%         % Calcolo valori dopo la prima onda d'urto obliqua:
%         M0t = M0*cos(theta1);
%         M0n = M0*sin(theta1);
% 
%         % utilizzo la relazione v0t = v1t, la velocità tangente prima e
%         % dopo l'urto rimane costante:
%         M1t = M0t*sqrt( ( (gamma+1)^2/(2*(gamma-1))*M0n^2 )/( (1+(gamma-1)/2*M0n^2)*(2*gamma/(gamma-1)*M0n^2-1) ) );
%         M1n = sqrt( (M0n^2+2/(gamma-1))/(2*gamma/(gamma-1)*M0n^2-1) );
% 
%         M1 = sqrt( M1t^2 + M1n^2 );
% 
%         % Calcolo valori dopo la seconda onda d'urto obliqua:
%         M1t_2 = M1*cos(theta2);
%         M1n_2 = M1*sin(theta2);
% 
%         % utilizzo la relazione v0t = v1t, la velocità tangente prima e
%         % dopo l'urto rimane costante:
%         M2t = M1t_2*sqrt( ( (gamma+1)^2/(2*(gamma-1))*M1n_2^2 )/( (1+(gamma-1)/2*M1n_2^2)*(2*gamma/(gamma-1)*M1n_2^2-1) ) );
%         M2n = sqrt( (M1n_2^2+2/(gamma-1))/(2*gamma/(gamma-1)*M1n_2^2-1) );
% 
%         M2 = sqrt( M2t^2 + M2n^2 );
% 
%         % Calcolo Mach dopo onda normale
% 
%         M3 = sqrt( (M2^2+2/(gamma-1))/(2*gamma/(gamma-1)*M2^2-1) );
% 
%         % Calcolo delle pressioni totali dopo ogni urto:
%         % Funzione per il rapporto di pressione totale
%         pr_total = @(Mn, g) ( ((g+1)/2 * Mn^2) / (1 + (g-1)/2 * Mn^2) )^(g/(g-1)) * ...
%                             ( 1 / (2*g/(g+1) * Mn^2 - (g-1)/(g+1)) )^(1/(g-1));
% 
%         % Recupero dopo la prima onda
%         pi_1 = pr_total(M0n, gamma); % rapporto di pressione
%         P01 = P00 * pi_1; % pressione totale
% 
%         % Recupero dopo la seconda onda
%         pi_2 = pr_total(M1n_2, gamma);
%         P02 = P01 * pi_2;
% 
%         % Recupero dopo onda normale
%         pi_3 = pr_total(M2, gamma);
%         P03 = P02 * pi_3;
% 
%         % Recupero totale delle sole onde oblique
%         piTot = P03/P00; 
% 
%         % Calcolo della temperatura e della densità: 
%         % La temperatura totale rimane costante:
%         T03 = T00;
%         T3 = T03 / (1 + (gamma - 1) / 2 * M3^2);
%         P3 = P03 / (1 + (gamma - 1) / 2 * M3^2)^(gamma/(gamma-1)); 
%         rho3 = P3 / (R * T3);
%         a3 = sqrt(rho3*R*T3);
%         V3 = M3*a3;
% 
%         % Calcolo l'efficienza termodinamica, per una seconda
%         % interpretazione dell'efficienza della presa oltre al recupero di
%         % pressione:
%         eta_d = ((piTot^((gamma-1)/gamma)) * (1 + (gamma-1)/2 * M0^2) - 1) / ((gamma-1)/2 * M0^2);
% 
%         % Dimensionamento della presa dinamica supersonica:
%         ACatt = mDot/(rho0*V0);
% 
%         % Imponogo che la larghezza sia il doppio dell'altezza della mia
%         % area di cattura che ha forma rettangolare, quindi W = 2H, 
%         % A = W*H = 2*H^2;
% 
%         hCatt = sqrt( ACatt/2 ); % altezza area cattura
%         wCatt = 2*hCatt; % larghezza area cattura
%         LSuper = hCatt/tan(theta1); % lunghezza tratto supersonico
%         LOnda1 = LSuper/cos(theta1); % lunghezza prima onda d'urto obliqua fino a Shock-Point
%         LRampa12 = LOnda1*sin(theta2+delta1-theta1)/sin(pi-theta2); % lunghezza primo tratto di rampa tra 1^ e 2^ onda obliqua
%         LOnda2 = LOnda1*sin(theta1-delta1)/sin(pi-theta2); % lunghezza seconda onda d'urto obliqua fino a Shock-Point
%         LRampa23 = LOnda2*cos(theta2-delta2); % lunghezza rampa tra 2^ onda obliqua e onda normale 
% 
%         % Impongo i parametri di offset labbro e angolo di carenatura:
%         deltaS = 0.1*LSuper;
%         delta3 = deg2rad(4);
% 
%         % Ricavo i dati per la progettazione della gola:
%         hGola = hCatt - LRampa12*sin(delta1) - LRampa23*sin(delta2);
%         AGola = mDot / (rho3 * V3);
%         wGola = AGola / hGola;
% 
%         ramjet.presaAria.T2         = T3;
%         ramjet.presaAria.P2         = P3;
%         ramjet.presaAria.T02        = T03;
%         ramjet.presaAria.P02        = P03;
%         ramjet.presaAria.M2         = M3;
%         ramjet.presaAria.eta_d      = eta_d;
%         ramjet.presaAria.rho2       = rho3;
%         ramjet.presaAria.V2         = V3;
%         ramjet.presaAria.CPR        = piTot;
%         ramjet.presaAria.LSuper     = LSuper;
%         ramjet.presaAria.LRampa12   = LRampa12;
%         ramjet.presaAria.LRampa23   = LRampa23;
%         ramjet.presaAria.hCatt      = hCatt;
%         ramjet.presaAria.hGola      = hGola;
%         ramjet.presaAria.ACatt      = ACatt;
%         ramjet.presaAria.wCatt      = wCatt;
%         ramjet.presaAria.wGola      = wGola;
%         ramjet.presaAria.A2         = AGola;
%         ramjet.presaAria.piTot      = piTot;
%         ramjet.presaAria.eta_d      = eta_d;
%         ramjet.presaAria.deltaS     = deltaS;
%         ramjet.presaAria.delta3     = delta3;
% 
%         motore = ramjet;
%     else
% 
%         error('Regime presaAria non valido')
% 
%     end
% 
% end
% SCRIPT per presa d'aria supersonica con 3 onde oblique
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



    end


% FUNZIONI LOCALI
end
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
