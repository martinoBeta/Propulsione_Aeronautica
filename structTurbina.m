function [propTurbina] = structTurbina()
% ritorna le struct con i parametri della turbina
 
    eta_b = 0.92; % rendimento meccanico
    eta_p = 0.9;% rendimento adiabatico

    %% Aria di rafreddamento dalle tabelle
    CoolingStatore = @(x)  (x<1100)*0 + ...    %cooling air richiesta per TIN statore è SOT
                            (x>=1100 & x <= 1650).*(0.09/(1600-1100)*(x-1100)) + ...
                            (x>1650).*0.5;

    CoolingRotore = @(x)   (x<1250)*0 + ...    %cooling air richiesta per TIN statore la T è SOT
                            (x>=1250 & x <= 1600).*(0.05/(1400-1250)*(x-1250)) + ...
                            (x>1600).*0.5;
    

    %% Creazione rendimento per statori da tabelle
    theta_val = [0,30,60,90,120];                       % gradi
    epsilon_val = [0.016,0.022,0.037,0.058,0.098];      % pagina 16 slide 15-La turbina assiale.pdf
    P  =polyfit(theta_val,epsilon_val,3);
    epsStadio = @(x) polyval(P,x);                     %in gradi
    
    % percentuale stadio 1 e 2 di lavoro suddiviso 
    LStadio1 = 0.6;     
    LStadio2 = 0.4;

    %% Impostare struct

    propTurbina.eta_b = eta_b; 
    propTurbina.eta_p = eta_p;
    propTurbina.CoolingStatore = CoolingStatore;
    propTurbina.CoolingRotore = CoolingRotore;
    propTurbina.epsStadio = epsStadio;
    propTurbina.LStadio1 = LStadio1;
    propTurbina.LStadio2 = LStadio2;



end