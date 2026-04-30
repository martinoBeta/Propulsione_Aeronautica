function [propFluidi] = structFluidi()
%Proprieta Fluido
    Ru = 8314;
    MmOx = 28.97;
    R = Ru / MmOx;
    MmFuel = 321.4964;          %cherosene
    ROx = R/MmOx;
    RFuel = R/MmFuel;
    cpOx = 7/2*ROx;
    cpFuel = 7/2*RFuel;
    gamma = 1.4;
    cp = (gamma * R) / (gamma - 1);

    % Grandezze termodinamiche a 12000 m

    M1 = 0.85;
    T1 = 216.65; % Temperatura a 12 km
    p1 = 19280;  % Pressione a 12 Km
    rho1 = p1 / (R * T1);
    a1 = sqrt(gamma * R * T1); % Velocità del suono
    v1 = a1 / M1;




    propFluidi.MmOx = MmOx;
    propFluidi.MmFuel = MmFuel;
    propFluidi.ROx = ROx;
    propFluidi.RFuel =  RFuel;
    propFluidi.cpOx = cpOx;
    propFluidi.cpFuel = cpFuel;

    
    propFluidi.R = R;
    propFluidi.gamma = gamma;
    propFluidi.cp = cp;
    propFluidi.M1 = M1;
    propFluidi.T1 = T1;
    propFluidi.p1 = p1;
    propFluidi.rho1 = rho1;
    propFluidi.a1 = a1;
    propFluidi.v1 = v1;
    


end