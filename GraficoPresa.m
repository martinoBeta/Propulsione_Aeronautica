figure('Color', 'w'); hold on; grid on; axis equal;

% --- Parametri ---
h      = ramjet.presaAria.hCatt;
L_sup  = ramjet.presaAria.LSuper;
d1     = ramjet.presaAria.delta1;
d2     = ramjet.presaAria.delta2;
L_r12  = ramjet.presaAria.LRampa12;
L_r23  = ramjet.presaAria.LRampa23;
dS     = abs(ramjet.presaAria.deltaS);
d3     = abs(ramjet.presaAria.delta3);

% --- COORDINATE RAMPA SUPERIORE ---
xB = 0;    yB = h;
xC = L_r12 * cos(d1);
yC = yB - L_r12 * sin(d1);
xD = xC + L_r23 * cos(d1 + d2);
yD = yC - L_r23 * sin(d1 + d2);

% A' = Shock Point (sinistra) - convergenza onde
xAp = L_sup;  yAp = 0;

% A = Lip (destra) - inizio baffo
xA  = xAp + dS;  yA = 0;

% --- 1. Rampa superiore ---
plot([xB xC xD], [yB yC yD], 'k', 'LineWidth', 3);

% --- 2. Baffo curvo in A ---
%    Parte da A con angolo +d3 verso l'alto
%    e raccorda a 0 (orizzontale) verso destra
N       = 120;
t       = linspace(0, 1, N);
smooth  = t.^2 .* (3 - 2*t);
theta   = -d3 * (1 - smooth);    % d3 -> 0, verso destra

L_baffo = 2.0 * dS;
ds_arc  = L_baffo / (N - 1);

x_baffo    = zeros(1, N);
y_baffo    = zeros(1, N);
x_baffo(1) = xA;
y_baffo(1) = yA;

for i = 2:N
    x_baffo(i) = x_baffo(i-1) + ds_arc * cos(theta(i-1));
    y_baffo(i) = y_baffo(i-1) + ds_arc * sin(theta(i-1));
end

% Tratto orizzontale dopo il baffo (condotto interno)
L_condotto = 0.4 * L_sup;
plot(x_baffo, y_baffo, 'k', 'LineWidth', 3);
plot([x_baffo(end), x_baffo(end) + L_condotto], ...
     [y_baffo(end), y_baffo(end)], 'k', 'LineWidth', 3);

% --- 3. Linea tratteggiata di riferimento ---
plot([xAp - 0.4*L_sup, xA], [0 0], 'k:', 'LineWidth', 1);

% --- 4. Onde d'urto (convergono in A') ---
plot([xB  xAp], [yB  yAp], 'r', 'LineWidth', 1.5);
plot([xC  xAp], [yC  yAp], 'r', 'LineWidth', 1.5);
plot([xD  xAp], [yD  yAp], 'b', 'LineWidth', 2.0);

% --- 5. Segmento deltaS verde (A' -> A) ---
plot([xAp xA], [0 0], 'g', 'LineWidth', 3);

% --- 6. Etichette ---
text(xB,  yB,   ' B',  'VerticalAlignment','bottom','FontSize',10);
text(xAp, 0.03, 'A''', 'HorizontalAlignment','center', ...
     'Color','r','FontWeight','bold','FontSize',10);
text(xA,  0.03, ' A',  'FontWeight','bold','FontSize',10);

text((xAp+xA)/2, -0.06, sprintf('\\DeltaS = %.3f m', dS), ...
    'HorizontalAlignment','center','Color',[0 0.55 0],'FontSize',9);

i_label = round(N * 0.15);
text(x_baffo(i_label)+0.02, y_baffo(i_label)+0.03, ...
     sprintf('\\delta_3 = %.1f°', rad2deg(d3)),'FontSize',9);

title('Geometria Presa: A'' (Shock Point) e A (Lip)');
xlabel('Lunghezza [m]');
ylabel('Altezza [m]');