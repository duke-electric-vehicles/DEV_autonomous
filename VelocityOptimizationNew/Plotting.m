% For re-plotting after running Optimization.m

close all; setgroot

trackName = 'GalotIdeal.mat';
track = load(trackName);
n     = length(track.ds);

nRst = 10;

figure('Position', [0 0 700 800]); hold on
view([15 20])
daspect([1 1 1e-2])

clrMap = jet;
rgb = clrMap(7:6:61, :);

xlabel $x$
ylabel $y$
zlabel Velocity~(m/s)
title  \textbf{Starting~Solutions}

for rst = 1:nRst
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

reset(groot)

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

function clrBarLabel(CLRBAR, LABEL)
    CLRBAR.Label.String      = LABEL;
    CLRBAR.Label.Interpreter = 'latex';
end