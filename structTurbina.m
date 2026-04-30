function [propTurbina] = structTurbina()
% ritorna le struct con i parametri della turbina
 
    eta_b = 0.9; % rendimento adiabatico
    eta_p = 0.98;% rendimento pneumatico

    %% Aria di rafreddamento dalle tabello
    Cooling_statore = @(x)  (x<1100)*0 + ...    %cooling air richiesta per TIN statore
                            (x>=1100 & x <= 1650).*(0.09/(1600-1100)*(x-1100)) + ...
                            (x>1650).*0.5;

    Cooling_rotore = @(x)   (x<1250)*0 + ...    %cooling air richiesta per TIN statore
                            (x>=1250 & x <= 1600).*(0.05/(1400-1250)*(x-1250)) + ...
                            (x>1600).*0.5;
    

    %% Creazione rendimento per statori da tabelle
    theta_val = [0,30,60,90,120];                       % gradi
    epsilon_val = [0.016,0.022,0.037,0.058,0.098];      % pagina 16 slide 15-La turbina assiale.pdf
    P  =polyfit(theta_val,epsilon_val,3);
    eps_stadio = @(x) polyval(P,x);                     %in gradi
    
    %% Impostare struct

    propTurbina.eta_b = eta_b; 
    propTurbina.eta_p = eta_p;
    propTurbina.Cooling_statore = Cooling_statore;
    propTurbina.Cooling_rotore = Cooling_rotore;
    propTurbina.eps_stadio = eps_stadio;



end