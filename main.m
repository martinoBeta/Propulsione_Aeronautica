% calcolo portata necessaria per mach 0.85 e 25Kn di spinta
rho_12000 = 0.31;
mach = 0.85;
R = 8314/29;
gamma = 1.3;
T_12000   = -56.5+273.15;
v_exitstimata = 900;
v_volo = mach * sqrt(R*gamma*T_12000);
% Spinta = mdot(ve-v_volo)
spinta = 25000;
mdot = spinta/(v_exitstimata-v_volo);





