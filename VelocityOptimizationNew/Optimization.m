% Yukai Qian, Gerry Chen
% Duke Electric Vehicles

clear; close all; format shortg; setgroot

global track mu m mg rho cdA cCor d c1 c2 r u 
global cEddy 
global regen 
global vAvg tMax pMax

time = datestr(now, 'yymmddHHMM');

%% Import track

trackName = 'GalotIdeal.mat';
track = load(trackName);
n     = length(track.ds);

%% Constants

mu    = 0.0015;     %          Rolling resistance coefficient
m     = 21+50;      % (kg)     Total mass
mg    = m*9.809;    % (N)      Gravity
rho   = 1.2;        % (kg/m^3) Air density at 20 C
cdA   = 0.033;      % (m^2)    Drag coefficient times area
cCor  = 120*180/pi; % (N/rad)  Tire cornering stiffness
c1    = 3.4e-4;     % (kg/m)   Wheel drag quadratic coefficient
c2    = 0.051;      % (N)      Wheel drag constant term
r     = 0.14;       % (ohm)    Motor resistance
u     = 12;         % (V)      Motor voltage
d     = 0.475;      % (m)      Wheel diameter

% Motor eddy current loss coefficients
cEddy = [-5.370e-10 -4.653e-6 -5.972e-3 0]; 

% State of motor re-gen function. 
% 'on' for re-gen on with maximum power pMax. 'off' for completely off. 
% Number r (0 < r < 1) for re-gen on with maximum power r*pMax.
regen = 'off'; 

%% Prepare for optimization

% Constraints
vAvg = 6.7;               % (m/s) Target average velocity
tMax = track.s(end)/vAvg; % (s)   Maximum time
pMax = 12*u;              % (W)   Maximum power to/from motor

% Options
options = optimoptions('fmincon', ...
                       'MaxFunctionEvaluations', 4e4, ...
                       'MaxIterations', 4e1, ...
                       'ObjectiveLimit', 0, ...
                       'Display', 'off');
                   
%% Optimize

prevSol    = load('1906221417');
nBest      = 2;
[~, index] = mink(prevSol.eTotal, nBest);
vPrev      = cell2mat(prevSol.v(index)');

nRst   = 30;            % Number of random restarts  
v0     = cell(1, nRst); % Starting points
v      = cell(1, nRst); % Solutions
eTotal = NaN(1, nRst);  % Total energies for respective solutions
flag   = NaN(1, nRst);  % Exit flags
output = cell(1, nRst); % Optimization process information
err    = cell(1, nRst); % Error information, if any

% Prepare for plotting starting solutions
figure('Position', [0 0 700 800]); hold on
view([15 20])
daspect([1 1 1e-2])

clrMap = jet;
rgb    = interp1(1:length(clrMap), clrMap, linspace(7, 60, nRst), ...
                 'linear');

xlabel $x$
ylabel $y$
zlabel Velocity~(m/s)
title  \textbf{Starting~Solutions}

% Prepare for plotting optimization results
edgeColor = [0.3 0.3 0.3];

nPoint = 200;
index = NaN(1, nPoint);

for tmp = 1:nPoint
    index(tmp) = find(track.s > (tmp-1)/nPoint * max(track.s), 1) - 1;
end

xPlot = track.x(index);
yPlot = track.y(index);
zPlot = track.z(index);

zMin = min(track.z);
zMax = max(track.z);

areaMin = 3^2;
areaMax = 10^2;

mkrAreaZ = areaMin + (areaMax-areaMin) * (zPlot-zMin)/(zMax-zMin);

% Optimize with fmincon() and plot results
for rst = 1:nRst
    try
        while 1
            % Generate random starting points
            while 1
                randWeight = rand(1, nBest-1);

                if sum(randWeight) < 1
                    break
                end
            end

            vTmp = [randWeight 1-sum(randWeight)] * vPrev;

            vRand = cumsum(0.005*rand(1, n));
            vRand = vRand - (0:n-1)/(n-1) .* vRand(end);
            vRand = circshift(vRand, randi(n));

            v0{rst} = vTmp + vRand;

            % Make starting points satisfy constraints
            if TimeTotal(v0{rst}) > tMax
                v0{rst} = TimeTotal(v0{rst})/tMax * v0{rst};
            end

            % Make starting points satisfy constraints
            if TimeTotal(v0{rst}) > tMax
                v0{rst} = TimeTotal(v0{rst})/tMax * v0{rst};
            end

            % Optimize with fmincon()
            [v{rst}, eTotal(rst), flag(rst), output{rst}] = ...
                fmincon(@Energy, v0{rst}, ...
                        [], [], [], [], [], [], ...
                        @Constr, options);

            % Break unless solution unfeasible
            if all(flag(rst) ~= [-2 -3])
                break
            end
        end
    catch exception
        err{rst} = exception;
    end
    
    % Plot starting solution
    figure(1)
    
    plot3(track.x, track.y, v0{rst}, 'Color', rgb(rst, :))
    
    % Prepare for scatter plots
    figure(rst+1)
    
    colormap(jet)
    
    % If fmincon failed skip plotting
    if ~isempty(err{rst})
        continue
    end
    
    vPlot = v{rst}(index);
    p     = Power(v{rst});
    pPlot = p(index);
    
    % Scatter plot with color as velocity and marker size as elevation
    subplot(1, 2, 1), hold on
    
    scatter(xPlot, yPlot, mkrAreaZ, vPlot, ...
            'filled', ...
            'MarkerEdgeColor', edgeColor)
    
    axis([-100 100 -500 500])
    axis equal
    grid on

    clrBar = colorbar;
    caxis([5.3 7.3])
    clrBarLabel(clrBar, 'Velocity (m/s)')
    
    title \textbf{Circle~size~shows~elevation.}

    % Scatter plot with color as power and marker size as velocity
    subplot(1, 2, 2)
    
    vMax = max(v{rst});
    vMin = min(v{rst});
    
    mkrAreaV = areaMin + (areaMax-areaMin) * (vPlot-vMin)/(vMax-vMin);
    
    scatter(xPlot, yPlot, mkrAreaV, pPlot, ...
            'filled', ...
            'MarkerEdgeColor', edgeColor)
        
    axis([-100 100 -500 500])
    axis equal
    grid on
        
    clrBar = colorbar;
    caxis([-43 144])
    clrBarLabel(clrBar, 'Power (W)')
    
    title \textbf{Circle~size~shows~velocity.}
end

%% Save result

for tmp = 1:nRst+1
    figure(tmp)
    
    saveas(gcf, sprintf('%s_%02i.fig', time, tmp))
end

if ~isstring(regen)
    regen = num2str(regen);
end
    
readme = sprintf('Re-gen %s; optimized on track %s', regen, trackName);
save(sprintf('%s', time), 'v0', 'v', 'eTotal', 'flag', 'output', 'readme')

%% Reset groot values

reset(groot)

%% Constraint function

function [C, CEQ] = Constr(V)
    global tMax pMax
    
    C = [TimeTotal(V) - tMax; ...
         max(abs(Power(V))) - pMax];
    CEQ = [];
end

%% Set groot default values

function setgroot()
    set(groot, 'defaultFigurePosition', [0 0 900 800])
    set(groot, 'defaultAxesTickLabelInterpreter', 'latex')
    set(groot, 'defaultColorbarTickLabelInterpreter', 'latex')
    set(groot, 'defaultTextInterpreter', 'latex')
    set(groot, 'defaultLegendInterpreter', 'latex')
    set(groot, 'defaultAxesFontSize', 12)
    set(groot, 'defaultAxesTitleFontSizeMultiplier', 1.1)
    set(groot, 'defaultColorbarFontSize', 12)
end

%% Set colorbar label

function clrBarLabel(CLRBAR, LABEL)
    CLRBAR.Label.String      = LABEL;
    CLRBAR.Label.Interpreter = 'latex';
end