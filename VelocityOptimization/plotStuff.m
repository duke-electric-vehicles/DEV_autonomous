%% plotstuff

    power = Eval(track, m, v, 'power');

    plotVals = linspace(1,length(s)+1,2000);
% 
    vVals = spline(1:length(s)+1, [v,v(1)], plotVals);
    xVals = spline(1:length(s)+1, [x,x(1)], plotVals);
    yVals = spline(1:length(s)+1, [y,y(1)], plotVals);
    zVals = spline(1:length(s)+1, [z,z(1)], plotVals);
    pVals = spline(1:length(s)+1, [power,power(1)], plotVals);
    
%     vVals = v;
%     xVals = x;
%     yVals = y;
%     zVals = z;

    figure(1); clf;
    p1 = subplot(3,1,1);
    scatter(xVals, yVals-5, 10, zVals); title('elevation'); colorbar;
    p2 = subplot(3,1,2);
    scatter(xVals,  yVals, 10, vVals,'filled'); title('velocity'); colorbar;
    p3 = subplot(3,1,3);
    scatter(xVals, yVals-5, 10, pVals); title('electrical power'); colorbar;
    linkaxes([p1,p2,p3],'xy');
   
   
    figure(3);clf;
    p1 = subplot(2,1,1);
    plot(s,v0,'b:'); hold on;
    plot(s,v,'k-'); ylabel('v');
    yyaxis right; plot(s(2:end),diff(v),'r--'); ylabel('accel')
    legend('initial guess','solution','acceleration');
    p2 = subplot(2,1,2);
    plot(s,power);
    ylabel('power');
    linkaxes([p1,p2], 'x');
    
    drawnow()