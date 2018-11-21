function [] = plotSols(v,path,h,pathcenter,lmin,lmax,theta)
%plotSols - plots the solutions and loss mechanisms of a path
    
    %% calculate variables
    global m
    ddcenter = cartToPath(pathcenter,v);
    [dd,dt] = cartToPath(path,v);
    t = cumsum(dt);
    hdot = gradient(h)./dd;
    thetadot = gradient(theta)./gradient(t);
    vdot = gradient(v)./gradient(t);
    [f,losses] = drag(hdot,v,thetadot);
    losses = losses*m;
    powerInput = (max(0,vdot+f)*m) .* v;
    throttle = powerInput./motorEfficiency(powerInput,v);
    assert(size(losses,2)==4);
    
    xSpline = spline(t,path(:,1));
    ySpline = spline(t,path(:,2));
    tVals = linspace(0,t(end),75);
    
    pathmin = pathToCart(pathcenter,theta,lmin);
    pathmax = pathToCart(pathcenter,theta,lmax);
    
    figure(1);clf
    subplot(2,2,1);
    plot(ppval(xSpline,tVals),ppval(ySpline,tVals),'ko');
    hold on
    plot(pathmin(:,1), pathmin(:,2),'r-');
    plot(pathmax(:,1), pathmax(:,2),'r-');
    axis square
    title('Velocity Path')
    xlabel('x (m)');
    ylabel('y (m)');
    
    %figure(2);clf;
    subplot(2,2,2);
    plot(t,v,'k-')
    ylim([0,15])
    title('Velocity Profile')
    xlabel('t (s)');
    ylabel('v (m/s)');
    
    %figure(3);clf;
    subplot(2,2,3);
    plot(path(:,1),path(:,2),'k-')
    hold on
    plot(pathmin(:,1), pathmin(:,2),'r-');
    plot(pathmax(:,1), pathmax(:,2),'r-');
    axis square
    title('Path')
    xlabel('x (m)');
    ylabel('y (m)');
    
    %figure(4);clf;
    subplot(2,2,4);
    plot(t,throttle,'k--');
    hold on
    for loss=losses
        plot(t,loss.*v);
    end
    legend('throttle power','elevation','air resistance','turning','rolling resistance')
    title('Losses vs t')
    xlabel('t - time (s)');
    ylabel('Loss (W)')
    drawnow()
    
    figure(2);clf;
    plot(path(:,1),path(:,2),'k-');
    hold on
    scatter(path(:,1),path(:,2),10,v);
    plot(pathmin(:,1), pathmin(:,2),'r-');
    plot(pathmax(:,1), pathmax(:,2),'r-');
    axis square
    title('Path')
    xlabel('x (m)');
    ylabel('y (m)');
    
    figure(3);clf;
    plot(t,throttle)
    hold on
    for loss=losses
        plot(t,loss.*v);
    end
    legend('throttle power','elevation','air resistance','turning','rolling resistance')
    title('Losses vs t')
    xlabel('t (s)');
    ylabel('Loss (W)')
    
    fprintf('total energy consumed: %.2fJ\n',sum(throttle.*dt));
    fprintf('estimated score:       %.2fmi/kWh\n',(sum(ddcenter)/1610)/(sum(throttle.*dt)/3600/1000));
end

function [theta,t] = preprocess(r,phi,v)
    % TODO: memoize
    dphi = gradient(phi);
    dr = gradient(r);
    t = cumsum(sqrt((r.*dphi).^2+dr.^2)./v);
    theta = pi/2+phi-atan(dr./(r.*dphi));
end
function [dd,dt] = cartToPath(cart,v)
    dx = gradient(cart(:,1));
    dy = gradient(cart(:,2));
    dd = sqrt(dx.^2+dy.^2);
    dt = dd./v;
end
function [path] = pathToCart(pathcenter,theta,l)
    N = [-sin(theta),cos(theta)];
    path = pathcenter+l.*N;
end
function [r] = pathToPolar(r0,phi,l)
    dphi = gradient(phi);
    dr = gradient(r0);
    theta = pi/2+phi-atan(dr./(r0.*dphi));
    r = r0 + l./cos(pi/2+phi-theta);
end
function [dd,theta,t] = polarToPath(r,phi,v)
    dphi = gradient(phi);
    dr = gradient(r);
    dd = sqrt((r.*dphi).^2+dr.^2);
    dt = dd./v;
    t = cumsum(dt);
    theta = pi/2+phi-atan(dr./(r.*dphi));
end