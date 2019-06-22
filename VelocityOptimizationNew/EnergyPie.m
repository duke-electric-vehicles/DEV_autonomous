% Yukai Qian
% Duke Electric Vehicles 
%
% EnergyPie  Make pie chart showing energy loss percentages for given V.
%
%   EnergyPie(V)
%   HPIE = EnergyPie(V)
%
%   V       (m/s)   1-by-N vector of horizontal velocities.
%   HPIE            1-by-10 graphics array of pie chart component handles.

function HPIE = EnergyPie(V)

%% Prepare for plotting

% Energy loss components
[eTotal, eCompnt] = Energy(V);

% Percentages
percent = 100 * eCompnt/eTotal;

% Labels
label = {'Air drag'
         'Rolling resistance'
         'Cornering loss'
         'Wheel drag'
         'Motor loss'};

%% Make and stylize pie chart

% Make pie chart
fig = figure;

HPIE = pie(eCompnt);

set(fig, 'Position', [100 100 800 600])

% Get handle of labels
hLabel = findobj(HPIE, 'Type', 'text');

% Extract label extents
extentOld = cell2mat(get(hLabel, 'Extent'));

% Change labels
set(hLabel, 'Interpreter', 'latex')
set(hLabel, 'FontSize', 14)

for tmp = 1:5
    hLabel(tmp).String = ...
        [label{tmp} ':' sprintf('\n%.1f', percent(tmp)) '\%'];
end

% Extract new label extents
extentNew = cell2mat(get(hLabel, 'Extent'));

% Find offsets
offset = sign(extentOld(:, 1)) .* (extentNew(:, 3) - extentOld(:, 3)) / 2;

% Move labels
labelPosition = cell2mat(get(hLabel, 'Position')); 
labelPosition(:, 1) = labelPosition(:, 1) + offset; 

for tmp = 1:5
    hLabel(tmp).Position = labelPosition(tmp, :);
end

reset(groot)