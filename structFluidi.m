function [propFluidi] = structFluidi()
% Proprietà termodinamiche dei fluidi di lavoro (aria e cherosene)
% Condizioni di volo: quota 12000 m, Mach 0.85
%
    % Costanti universali
    Ru     = 8314;          % costante universale dei gas [J/(kmol·K)]


    % Proprietà aria 
    aria.Mm = 28.97;
    aria.R  = Ru/aria.Mm;    
    aria.cp = 7/2*aria.R;
    aria.gamma = 1.4;
    

    % Proprietà gas combusti
    gas.R = aria.R;
    gas.gamma = 1.33;
    gas.cp = (gas.gamma * gas.R) / (gas.gamma - 1);
    gas.cpG = NaN;



    % Proprietà combustibile (JP-7)
    combustibile.Mm = 321.4964;
    combustibile.R = Ru / combustibile.Mm;
    combustibile.cp = 7/2 * combustibile.R;
    combustibile.LHV = 44.1e6;
   


    

    MmOx   = 28.97;         % massa molare aria [kg/kmol]
    ROx    = Ru / MmOx;     % costante del gas aria [J/(kg·K)]  ≈ 287 J/(kg·K)
    cpOx   = 7/2 * ROx;     % cp aria (gas biatomico, gamma=1.4) [J/(kg·K)]

    % Proprietà gas combusti (miscela aria + prodotti combustione)
    R      = ROx;           % costante del gas miscela [J/(kg·K)]
    gamma  = 1.33;          % rapporto calori specifici gas combusti [-]
    cp     = (gamma * R) / (gamma - 1);  % cp gas combusti [J/(kg·K)]
    MmFuel = 321;
    RFuel = 24;
    cpFuel = 2000;
    LHV = 43e6;
    % % Condizioni atmosferiche a 12000 m (ISA)
    M0  = 0.85;             % numero di Mach di volo [-]
    T0  = 216.65;           % temperatura statica [K]
    P0  = 19280;            % pressione statica [Pa]

    T00 = T0 * (1 + (gamma - 1)/2 * M0^2);  % temperatura totale [K]
    P00 = P0 * (1 + (gamma - 1)/2 * M0^2)^(gamma/(gamma - 1)); % pressione totale [Pa]

    rho0 = P0 / (R * T0);          % densità statica [kg/m³]
    a0   = sqrt(gamma * R * T0);   % velocità del suono [m/s]
    v0   = a0 * M0;                % velocità di volo [m/s]

    % Assegnazione delle struct
    propFluidi.MmOx   = MmOx;
    propFluidi.MmFuel = MmFuel;
    propFluidi.ROx    = ROx;
    propFluidi.RFuel  = RFuel;
    propFluidi.cpOx   = cpOx;
    propFluidi.cpFuel = cpFuel;
    propFluidi.LHV    = LHV;       

    propFluidi.R      = R;
    propFluidi.gamma  = gamma;
    propFluidi.cp     = cp;
    propFluidi.M0     = M0;
    propFluidi.T0     = T0;
    propFluidi.T00    = T00;
    propFluidi.P0     = P0;
    propFluidi.P00    = P00;
    propFluidi.rho0   = rho0;
    propFluidi.a0     = a0;
    propFluidi.v0     = v0;

    propFluidi.aria = aria;
    propFluidi.gas = gas;
    propFluidi.combustibile = combustibile;

end
