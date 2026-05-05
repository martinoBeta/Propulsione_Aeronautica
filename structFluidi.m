function [propFluidi] = structFluidi()
%Proprieta Fluido
%% 
    Ru = 8314;
    MmOx = 28.97;
    R = Ru / MmOx;
    MmFuel = 321.4964;          %cherosene
    ROx = Ru/MmOx;
    RFuel = Ru/MmFuel;
    cpOx = 7/2*ROx;
    cpFuel = 7/2*RFuel;
    gamma = 1.33;
    cp = (gamma * R) / (gamma - 1);

    % Grandezze termodinamiche a 12000 m

    M0 = 0.85;
    T0 = 216.65; % Temperatura a 12 km
    T00 = T0 * (1 + (gamma - 1)/2 * M0^2);% Temperatura totale a 12 km



    P0 = 19280;  % Pressione a 12 Km
    P00 = P0 * (1 + (gamma - 1)/2 * M0^2)^(gamma/(gamma - 1));

    rho0 = P0 / (R * T0);
    a0 = sqrt(gamma * R * T0); % Velocità del suono
    v0 = a0 * M0;




    propFluidi.MmOx = MmOx;
    propFluidi.MmFuel = MmFuel;
    propFluidi.ROx = ROx;
    propFluidi.RFuel =  RFuel;
    propFluidi.cpOx = cpOx;
    propFluidi.cpFuel = cpFuel;

    
    propFluidi.R = R;
    propFluidi.gamma = gamma;
    propFluidi.cp = cp;
    propFluidi.M0 = M0;
    propFluidi.T0 = T0;
    propFluidi.T00 = T00;
    propFluidi.P0 = P0;
    propFluidi.P00 = P00;
    propFluidi.rho0 = rho0;
    propFluidi.a0 = a0;
    propFluidi.v0 = v0;
    


end