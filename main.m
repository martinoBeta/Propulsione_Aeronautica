clc
clear 
close all

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

%--------------------------------------------------------------------------
%                               PRESA D'ARIA
%--------------------------------------------------------------------------

%%
%--------------------------------------------------------------------------
%                               COMPRESSORE
%--------------------------------------------------------------------------

%%
%--------------------------------------------------------------------------
%                          CAMERA DI COMBUSTIONE
%--------------------------------------------------------------------------

%%
%--------------------------------------------------------------------------
%                                 TURBINA
%--------------------------------------------------------------------------

P0I = 50000;
T0I = 1000:1:1800;
mach = 0.3;

propFluidi = structFluidi();%
propMotore = structMotore(structTurbina());
L_compressore = 10.7e6;
mach = 0.3;
P0I = 300000;
T3 = 420;
TCool = T3;
    
etan = [];
coolPecentualeA = [];
Sota = [];
etos = [];
P0Is = [];
P0Us = [];
T0Is = [];
T0Us = [];
spinta = [];

for i = T0I
    [P0U, T0U, T05_iso, mach, Q, L_turbina, eta_n,coolPecentuale,SOT,eto] = turbina(P0I,i, mach, L_compressore,propFluidi,propMotore,TCool);
    etan = [etan, eta_n];
    coolPecentualeA = [coolPecentualeA,coolPecentuale];
    Sota = [Sota, SOT];
    etos = [etos, eto];
    P0Us = [P0Us,P0U];
    P0Is = [P0Is,P0I];
    T0Us = [T0Us,T0U];
    T0Is = [T0Is,T05_iso];
    [P0U, T0U, mach, Q, L, Ue, eta_n] = ugello(P0U,T0U, mach, propMotore.mdot);
    spinta = [spinta,mdot*(Ue-v_volo)];
end 


figure("name","rendimento isoentropico");
plot(T0I,etan);
title("Rendimento isoentropico")
xlabel("T04 (camera di combustione) [K]")
ylabel("\eta_n")
hold on
plot(T0I,etos);
legend("Isoentropico Raff","Isoentropico Non Raff")


figure("name","aria rafreddamento tubina");
plot(T0I,coolPecentualeA*100);
hold on
plot(T0I,propMotore.Turbina.CoolingRotore(Sota)*100)
hold on
plot(T0I,propMotore.Turbina.CoolingStatore(Sota)*100)
legend("Totale","Rotore","Statore");
title("percentuale di aria spillata da compressore per rafreddamento turbina")
xlabel("T04 (camera di combustione) [K]")
ylabel("Aria spillata per rafreddamento [%]")

figure("name","rendimento vs rafreddamento")
plot(coolPecentualeA*100,etos,"-");
title("Rendimento isoentropico vs aria spillata per rafreddamento")
xlabel("Aria spillata per rafreddamento [%]")
ylabel("\eta_n")

figure("name","pressioni")
yyaxis left
plot(T0I,P0Is,'b-');
hold on
plot(T0I,P0Us,'w-');
ylim([min(P0Us)-5000,max(P0Is)+5000]);
ylabel("pressure [Pa]")
yyaxis right
ylabel("Temperature")
plot(T0I,T0Is,'y-');
hold on
plot(T0I,T0Us,'r-');
ylim([min(T0Us)-50,max(T0I)+50]);
xlabel("T04 (camera di combustione) [K]");
legend("P0I",'P0U','T0U_iso','T0U');

figure("name","spinta")
plot(T0I,spinta)
xlabel("T04 (camera di combustione) [K]")
ylabel("Spinta [N]")

%--------------------------------------------------------------------------
%                                 UGELLO
%--------------------------------------------------------------------------