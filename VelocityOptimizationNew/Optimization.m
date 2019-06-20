% Yukai Qian, Gerry Chen
% Duke Electric Vehicles

clear; close all; format shortg; setgroot

global track mu m mg rho cdA cCor c1 c2 r u cEddy regen vAvg tMax pMax

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
cdA   = 0.037;      % (m^2)    Drag coefficient times area
cCor  = 120*180/pi; % (N/rad)  Tire cornering stiffness
c1    = 3.4e-4;     % (kg/m)   Wheel drag quadratic coefficient
c2    = 0.051;      % (N)      Wheel drag constant term
r     = 0.13;       % (ohm)    Motor resistance
u     = 12;         % (V)      Motor voltage
cEddy = 0.03;       % (kg/s)   Eddy current loss constant
regen = 'off';      %          State of motor re-gen function. 'on' for
                    %            re-gen on with maximum power pMax. 'off'
                    %            for completely off. Number r (0 < r < 1)
                    %            for re-gen on with maximum power r*pMax.

%% Prepare for optimization

% Constraints
vAvg = 6.7;               % (m/s) Target average velocity
tMax = track.s(end)/vAvg; % (s)   Maximum time
pMax = 12*u;              % (W)   Maximum power to/from motor

% Options
options = optimoptions('fmincon', ...
                       'MaxFunctionEvaluations', 3e4, ...
                       'MaxIterations', 3e1, ...
                       'ObjectiveLimit', 0, ...
                       'Display', 'off');
                   
%% Optimize

prevSol = load('1906201230');
vPrev = cell2mat(prevSol.v([3 6 29])');

nRst   = 30;            % Number of random restarts  
v0     = cell(1, nRst); % Starting points
v      = cell(1, nRst); % Solutions
eTotal = NaN(1, nRst);  % Total energies for respective solutions
flag   = NaN(1, nRst);  % Exit flags
output = cell(1, nRst); % Optimization process information

% Prepare for plotting starting solutions
figure('Position', [0 0 700 800]); hold on
view([15 20])
daspect([1 1 1e-2])

clrMap = jet;
rgb = clrMap(4:2:62, :);

xlabel $x$
ylabel $y$
zlabel Velocity~(m/s)
title  \textbf{Starting~Solutions}

for rst = 1:nRst
    while 1
        % Generate random starting points
        while 1
            a = rand;
            b = rand;
            
            if a+b < 1
                break
            end
        end
        
        c = 1-a-b;
        
        vTmp = [a b c] * vPrev;
        
        vRand = cumsum(0.001*rand(1, n));
        vRand = vRand - (0:n-1)/(n-1) .* vRand(end);
        vRand = circshift(vRand, randi(n));
        v0{rst} = vTmp + vRand;

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
    
    % Plot starting solution
    figure(1)
    
    plot3(track.x, track.y, v0{rst}, 'Color', rgb(rst, :))
    
    % Prepare for scatter plots
    figure(rst+1)
    
    colormap(jet)
    edgeColor = [0.3 0.3 0.3];
    
    nPoint = 200;
    index = NaN(1, nPoint);
    
    for tmp = 1:nPoint
        index(tmp) = find(track.s > (tmp-1)/nPoint * max(track.s), 1) - 1;
    end
    
    xPlot = track.x(index);
    yPlot = track.y(index);
    zPlot = track.z(index);
    vPlot = v{rst}(index);
    p     = Power(v{rst});
    pPlot = p(index);
    
    % Scatter plot with color as velocity and marker size as elevation
    subplot(1, 2, 1), hold on
    
    zMin = min(track.z);
    zMax = max(track.z);
    
    areaMin = 3^2;
    areaMax = 10^2;
    mkrArea = areaMin + (areaMax-areaMin) * (zPlot-zMin)/(zMax-zMin);
    
    scatter(xPlot, yPlot, mkrArea, vPlot, ...
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
    
    areaMin = 3^2;
    areaMax = 10^2;
    mkrArea = areaMin + (areaMax-areaMin) * (vPlot-vMin)/(vMax-vMin);
    
    scatter(xPlot, yPlot, mkrArea, pPlot, ...
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