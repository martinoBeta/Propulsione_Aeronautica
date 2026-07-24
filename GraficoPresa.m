%% DISEGNO PRESA D'ARIA TBCC - Mach 3.5
figure('Color','w', 'Name', 'TBCC Mach 3.5 - Flusso e Angoli');
hold on; axis equal; box off; axis off;

% =========================================================================
% 1. IMPORT DATI E CALCOLI PRELIMINARI
% =========================================================================
h      = ramjet.presaAria.hCatt;
L_sup  = ramjet.presaAria.LSuper;
d1     = ramjet.presaAria.delta1;
d2     = ramjet.presaAria.delta2;
d3     = ramjet.presaAria.delta3;
L_r12  = ramjet.presaAria.LRampa12;
L_r23  = ramjet.presaAria.LRampa23;
L_r34  = ramjet.presaAria.LRampa34;
wCatt  = ramjet.presaAria.wCatt;    
M0     = ramjet.freestream.h25km.M0;

% Aree e altezze
A2_turbo = motore.presaAria.A2;
h_comp   = 2*sqrt(A2_turbo / pi);
A2Ram    = ramjet.anulus.AIn;

% Deflessione totale del flusso
theta_flow = d1 + d2 + d3; 

% =========================================================================
% 2. CALCOLO COORDINATE RAMPE E ONDE
% =========================================================================
xB = 0;    yB = h;
xC = xB + L_r12 * cos(d1);          yC = yB - L_r12 * sin(d1);
xD = xC + L_r23 * cos(d1+d2);       yD = yC - L_r23 * sin(d1+d2);
xE = xD + L_r34 * cos(theta_flow);  yE = yD - L_r34 * sin(theta_flow);

% Shock-on-Lip
xShock = L_sup; 
yShock = 0;

% Offset di sicurezza
offsetLabbro = 0.05 * L_sup; 
xLip = xShock + offsetLabbro * cos(theta_flow); 
yLip = yShock - offsetLabbro * sin(theta_flow); 

% =========================================================================
% 3. QUOTE GEOMETRIA INTERNA
% =========================================================================
xHinge = xE + 0.80 * L_sup;  
xMax   = xHinge + 0.25 * L_sup; 

yFloor = -0.45 * h;              
yHinge = yFloor + sqrt(A2Ram/pi);   
yRoof  = yHinge + h_comp;         

% Funzione curve di Bezier Cubiche
bezier = @(p0, p1, p2, p3, t) (1-t).^3.*p0 + 3.*(1-t).^2.*t.*p1 + 3.*(1-t).*t.^2.*p2 + t.^3.*p3;
t = linspace(0, 1, 100)';

% =========================================================================
% 4. DISEGNO ELEMENTI STRUTTURALI
% =========================================================================
% --- Fusoliera e Rampe ---
plot([-0.15*L_sup, xMax], [h, h], 'k-', 'LineWidth', 1);
plot([xB, xC, xD, xE], [yB, yC, yD, yE], 'k-', 'LineWidth', 1.5);

% --- Onde d'urto ---
plot([xB, xShock], [yB, yShock], 'r-', 'LineWidth', 1.5); 
plot([xC, xShock], [yC, yShock], 'r-', 'LineWidth', 1.5); 
plot([xD, xShock], [yD, yShock], 'r-', 'LineWidth', 1.5); 
plot([xE, xShock], [yE, yShock], 'r-', 'LineWidth', 1.5); 
plot(xShock, yShock, 'ro', 'MarkerSize', 6, 'MarkerFaceColor', 'r');

text(xShock - 0.015*L_sup, yShock - 0.04*h, 'Shock point', 'Color', 'r', 'FontSize', 10, 'FontWeight', 'bold', 'HorizontalAlignment', 'right');

% --- Offset Labbro ---
plot([xShock, xLip], [yShock, yLip], '-', 'Color', [0.2 0.8 0.2], 'LineWidth', 4);
text(xLip + 0.01*L_sup, yLip - 0.04*h, 'Offset', 'Color', [0.2 0.8 0.2], 'FontSize', 10, 'FontWeight', 'bold', 'HorizontalAlignment', 'left');

% --- Tetto Turbogetto ---
P0_roof = [xE, yE];
P1_roof = [xE + 0.5*(xHinge-xE), yE];       
P2_roof = [xHinge - 0.2*(xHinge-xE), yRoof];
P3_roof = [xHinge, yRoof];
xRoof = bezier(P0_roof(1), P1_roof(1), P2_roof(1), P3_roof(1), t);
yRoofCurve = bezier(P0_roof(2), P1_roof(2), P2_roof(2), P3_roof(2), t);
plot(xRoof, yRoofCurve, 'k-', 'LineWidth', 1.5);
plot([xHinge, xMax], [yRoofCurve(end), yRoofCurve(end)], 'k-', 'LineWidth', 1.5);

% --- Paratia Mobile ---
dx_flap = xHinge - xE;
P0_flap = [xE, yE];
P1_flap = [xE + 0.35*dx_flap, yE - 0.25*dx_flap*tan(theta_flow)]; 
P2_flap = [xHinge - 0.35*dx_flap, yHinge];     
P3_flap = [xHinge, yHinge];
xFlap = bezier(P0_flap(1), P1_flap(1), P2_flap(1), P3_flap(1), t);
yFlap = bezier(P0_flap(2), P1_flap(2), P2_flap(2), P3_flap(2), t);
plot(xFlap, yFlap, '-', 'Color', [0.85 0.5 0], 'LineWidth', 2.5);
plot(xHinge, yHinge, 'o', 'MarkerSize', 6, 'MarkerFaceColor', [0.85 0.5 0], 'MarkerEdgeColor', 'k');

% --- Pavimento Ramjet ---
dx_floor = xHinge - xLip;
P0_floor = [xLip, yLip];
P1_floor = [xLip + 0.35*dx_floor, yLip - 0.25*dx_floor*tan(theta_flow)]; 
P2_floor = [xHinge - 0.35*dx_floor, yFloor];
P3_floor = [xHinge, yFloor];
xFloor = bezier(P0_floor(1), P1_floor(1), P2_floor(1), P3_floor(1), t);
yFloorCurve = bezier(P0_floor(2), P1_floor(2), P2_floor(2), P3_floor(2), t);
plot(xFloor, yFloorCurve, 'k-', 'LineWidth', 1.5);
plot([xHinge, xMax], [yFloor, yFloor], 'k-', 'LineWidth', 1.5);

% --- Linea divisoria orizzontale ---
plot([xHinge, xMax], [yHinge, yHinge], 'k-', 'LineWidth', 1.5);

% --- Faccia Compressore ---
plot([xMax, xMax], [yHinge, yRoofCurve(end)], 'm-', 'LineWidth', 3.5);
text(xMax - 0.02*L_sup, (yHinge + yRoofCurve(end))/2, 'Ingresso compressore', 'Color', 'm', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'right');

% =========================================================================
% 5. TESTI, FRECCE, ANGOLI
% =========================================================================
% Condizioni di volo
quiver(-0.25*L_sup, h*0.5, 0.15*L_sup, 0, 0, 'k', 'LineWidth', 2.5, 'MaxHeadSize', 0.5);
text(-0.28*L_sup, h*0.5, sprintf('M_0 = %.1f', M0), 'FontSize', 16, 'Color', 'k', 'HorizontalAlignment', 'right', 'FontWeight', 'bold');

text(xHinge + 0.5*(xMax-xHinge), yFloor + 0.5*(yHinge-yFloor), 'Post combustore \rightarrow', ...
     'FontSize', 11, 'HorizontalAlignment', 'center', 'FontAngle', 'italic', 'Color', [0.5 0.5 0.5]);

% --- Parametri Archi e Frecce ---
r_th   = 0.16 * L_sup;  
r_del  = 0.08 * L_sup;  
L_dash = 0.20 * L_sup;  
L_arr  = 0.08 * L_sup;  

% --- Rampa 1 ---
a_sh1 = atan2(yShock - yB, xShock - xB);
a_r1  = -d1;
plot([xB, xB + L_dash], [yB, yB], '--', 'Color', [0 0.7 0.9], 'LineWidth', 1.2); 
plot(xB + r_th*cos(linspace(0, a_sh1, 30)), yB + r_th*sin(linspace(0, a_sh1, 30)), '-', 'Color', [0 0.7 0.9], 'LineWidth', 1.5); 
plot(xB + r_del*cos(linspace(0, a_r1, 30)), yB + r_del*sin(linspace(0, a_r1, 30)), 'r-', 'LineWidth', 1.5); 
text(xB + r_th*1.12*cos(a_sh1/2), yB + r_th*1.12*sin(a_sh1/2), '\theta_1', 'Color', [0 0.7 0.9], 'FontSize', 11, 'FontWeight', 'bold');
text(xB + r_del*1.30*cos(a_r1/2), yB + r_del*1.30*sin(a_r1/2), '\delta_1', 'Color', 'r', 'FontSize', 11, 'FontWeight', 'bold');

mX1 = (xB+xC)/2; 
y_sh1 = yB + (yShock-yB)/(xShock-xB)*(mX1-xB);
mY1 = ((yB+yC)/2 + y_sh1)/2;
quiver(mX1 - (L_arr*cos(a_r1))/2, mY1 - (L_arr*sin(a_r1))/2, L_arr*cos(a_r1), L_arr*sin(a_r1), 0, 'k', 'LineWidth', 2.5, 'MaxHeadSize', 0.5);

% --- Rampa 2 ---
a_sh2 = atan2(yShock - yC, xShock - xC);
a_r2  = -(d1 + d2);
plot([xC, xC + L_dash], [yC, yC], '--', 'Color', [0 0.7 0.9], 'LineWidth', 1.2); 
plot(xC + r_th*cos(linspace(0, a_sh2, 30)), yC + r_th*sin(linspace(0, a_sh2, 30)), '-', 'Color', [0 0.7 0.9], 'LineWidth', 1.5);
plot(xC + r_del*cos(linspace(0, a_r2, 30)), yC + r_del*sin(linspace(0, a_r2, 30)), 'r-', 'LineWidth', 1.5); 
text(xC + r_th*1.12*cos(a_sh2/2), yC + r_th*1.12*sin(a_sh2/2), '\theta_2', 'Color', [0 0.7 0.9], 'FontSize', 11, 'FontWeight', 'bold');
text(xC + r_del*1.30*cos(a_r2/2), yC + r_del*1.30*sin(a_r2/2), '\delta_2', 'Color', 'r', 'FontSize', 11, 'FontWeight', 'bold');

mX2 = (xC+xD)/2;
y_sh2 = yC + (yShock-yC)/(xShock-xC)*(mX2-xC);
mY2 = ((yC+yD)/2 + y_sh2)/2;
quiver(mX2 - (L_arr*cos(a_r2))/2, mY2 - (L_arr*sin(a_r2))/2, L_arr*cos(a_r2), L_arr*sin(a_r2), 0, 'k', 'LineWidth', 2.5, 'MaxHeadSize', 0.5);

% --- Rampa 3 ---
a_sh3 = atan2(yShock - yD, xShock - xD);
a_r3  = -(d1 + d2 + d3);
plot([xD, xD + L_dash], [yD, yD], '--', 'Color', [0 0.7 0.9], 'LineWidth', 1.2); 
plot(xD + r_th*cos(linspace(0, a_sh3, 30)), yD + r_th*sin(linspace(0, a_sh3, 30)), '-', 'Color', [0 0.7 0.9], 'LineWidth', 1.5);
plot(xD + r_del*cos(linspace(0, a_r3, 30)), yD + r_del*sin(linspace(0, a_r3, 30)), 'r-', 'LineWidth', 1.5);
text(xD + r_th*1.12*cos(a_sh3/2), yD + r_th*1.12*sin(a_sh3/2), '\theta_3', 'Color', [0 0.7 0.9], 'FontSize', 11, 'FontWeight', 'bold');
text(xD + r_del*1.30*cos(a_r3/2), yD + r_del*1.30*sin(a_r3/2), '\delta_3', 'Color', 'r', 'FontSize', 11, 'FontWeight', 'bold');

mX3 = (xD+xE)/2;
y_sh3 = yD + (yShock-yD)/(xShock-xD)*(mX3-xD);
mY3 = ((yD+yE)/2 + y_sh3)/2;
quiver(mX3 - (L_arr*cos(a_r3))/2, mY3 - (L_arr*sin(a_r3))/2, L_arr*cos(a_r3), L_arr*sin(a_r3), 0, 'k', 'LineWidth', 2.5, 'MaxHeadSize', 0.5);

% --- Freccia Flusso Interno ---
mX4 = (xE + xLip)/2 + 0.04*L_sup*cos(a_r3); 
mY4 = (yE + yLip)/2 + 0.04*L_sup*sin(a_r3); 
quiver(mX4 - (L_arr*cos(a_r3))/2, mY4 - (L_arr*sin(a_r3))/2, L_arr*cos(a_r3), L_arr*sin(a_r3), 0, 'k', 'LineWidth', 2.5, 'MaxHeadSize', 0.5);

% =========================================================================
% 6. LIMITI ASSI E VISTA FINALE
% =========================================================================
xlim([-0.40*L_sup, xMax + 0.15*L_sup]);
ylim([yFloor - 0.15*h, h + 0.15*h]);