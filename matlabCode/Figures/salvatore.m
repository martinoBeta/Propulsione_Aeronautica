% salvatore è un codice per salvare le figure in formato svg in una cartella dedicata.
% Per usarlo bisogna avere le figure aperte e poi eseguire questo script.
% Le figure saranno salvate in una cartella "Figures" all'interno della directory di lavoro corrente. 
% Il nome del file svg sarà basato sul nome della figura, o se la figura non ha un nome, sarà il numero della figura.
% Le figure saranno salvate con un tema chiaro, e dimensioni di 24 cm di larghezza e 16 cm di altezza. 
% Questo garantsce che le figure escano pronte per essere inserite su overleaf
% serve il pacchetto \usepackage{svg}
% Sono da impostare le seguenti cose per tutte le figure basta farlo all'inizo dello script
% set(groot, ...
%    'defaultTextInterpreter', 'latex', ...
%    'defaultAxesTickLabelInterpreter', 'latex', ...
%    'defaultLegendInterpreter', 'latex', ...
%    'defaultColorbarTickLabelInterpreter', 'latex', ...
%    'defaultAxesFontSize', 14, ...
%    'defaultTextFontSize', 14, ...
%    'defaultLegendFontSize', 14);
%    'defaultAxesFontName', 'Latin Modern Roman');


folder = [pwd '/Figures'];
if ~exist(folder, 'dir')
    mkdir(folder)
end

figs = findall(groot, 'Type', 'figure');
W_cm = 24;
H_cm = 8;

for k = 1:length(figs)
    fig = figs(k);
    figure(fig);
    theme light

    fig.PaperUnits = 'centimeters';
    fig.PaperSize = [W_cm H_cm];
    fig.PaperPosition = [0 0 W_cm H_cm];
    fig.PaperPositionMode = 'manual';

    name = fig.Name;
    if isempty(name)
        name = sprintf('figura_%d', fig.Number);
    end
    name = regexprep(name, '[^\w\-]', '_');
    
    hTitle = get(gca,'Title');
    hTitle.Visible = 'off';  

    pdf_file = fullfile(folder, [name '.pdf']);
    print(fig, pdf_file, '-dpdf', '-vector');
    hTitle.Visible = 'on';  
    theme dark
end