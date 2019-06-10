%% plotstuff

    plotVals = linspace(1,length(s),2000);
% 
%     vVals = spline(1:length(s), v, plotVals);
%     xVals = spline(1:length(s), x, plotVals);
%     yVals = spline(1:length(s), y, plotVals);
%     zVals = spline(1:length(s), z, plotVals);
    
    vVals = v;
    xVals = x;
    yVals = y;
    zVals = z;

    figure(1); clf;
    p1 = subplot(2,1,1);
    scatter(xVals, yVals-5, 10, zVals); title('elevation'); colorbar;
    p2 = subplot(2,1,2);
    scatter(xVals,  yVals, 10, vVals,'filled'); title('velocity')
    linkaxes([p1,p2],'xy');
    colorbar
    
    power = Eval(track, m, v, 'power');
    figure(3);clf;
    p1 = subplot(2,1,1);
    plot(s,v0); hold on;
    plot(s,v); ylabel('v');
    legend('initial guess','solution');
    yyaxis right; plot(s(2:end),diff(v)); ylabel('accel')
    p2 = subplot(2,1,2);
    plot(s,power);
    ylabel('power');
    linkaxes([p1,p2], 'x');
    
    drawnow()