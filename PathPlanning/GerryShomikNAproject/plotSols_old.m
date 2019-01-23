function [] = plotSols_old(v,r,h,rmin,rmax,phi)
%plotSols - plots the solutions and loss mechanisms of a path
    
    %% calculate variables
    [theta,t] = preprocess(r,phi,v);
    %hdot = gradient(h)./gradient(t);
    hdot = 1/r.*gradient(h)./gradient(phi);
    thetadot = gradient(theta)./gradient(t);
    vdot = gradient(v)./gradient(t);
    [f,losses] = drag(hdot,v,thetadot);
    
    rSpline = spline(t,r);
    phiSpline = spline(t,phi);
    tVals = linspace(0,t(end),75);
    
    figure(1);clf
    subplot(2,2,1);
    plot(ppval(rSpline,tVals).*cos(ppval(phiSpline,tVals)),...
         ppval(rSpline,tVals).*sin(ppval(phiSpline,tVals)),'ko');
    hold on
    plot(rmin.*cos(phi), rmin.*sin(phi),'r-');
    plot(rmax.*cos(phi), rmax.*sin(phi),'r-');
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
    drawnow();
    
    %figure(3);clf;
    subplot(2,2,3);
    plot(r.*cos(phi), r.*sin(phi),'k-')
    hold on
    plot(rmin.*cos(phi), rmin.*sin(phi),'r-');
    plot(rmax.*cos(phi), rmax.*sin(phi),'r-');
    axis square
    title('Path')
    xlabel('x (m)');
    ylabel('y (m)');
    
    %figure(4);clf;
    subplot(2,2,4);
    dphi = gradient(phi);
    dr = gradient(r);
    plot(t,f.*v,'k--');
    hold on
    for loss=losses
        plot(t,loss.*v);
    end
%     legend('total losses','elevation','air resistance','turning','rolling resistance')
    title('Losses vs \phi')
    xlabel('\phi - polar angular direction (rad)');
    ylabel('Loss (W)')
    drawnow()
    
    figure(2);clf;
    subplot(2,1,1)
    plot(r.*cos(phi), r.*sin(phi),'k-');
    hold on
    scatter(r.*cos(phi), r.*sin(phi),10,v);
    plot(rmin.*cos(phi), rmin.*sin(phi),'r-');
    plot(rmax.*cos(phi), rmax.*sin(phi),'r-');
    axis square
    title('Path')
    xlabel('x (m)');
    ylabel('y (m)');
    
    subplot(2,1,2);
    plot(t,v,'k-')
    ylim([0,15])
    title('Velocity Profile')
    xlabel('t (s)');
    ylabel('v (m/s)');
    axis square
    drawnow();
    
    figure(3);clf;
    dphi = gradient(phi);
    dr = gradient(r);
    for loss=losses
        plot(phi,loss.*v);
        hold on
    end
    legend('elevation','air resistance','turning','rolling resistance')
    title('Losses vs \phi')
    xlabel('\phi - polar angular direction (rad)');
    ylabel('Loss (W)')
end

function [theta,t] = preprocess(r,phi,v)
    % TODO: memoize
    dphi = gradient(phi);
    dr = gradient(r);
    t = cumsum(sqrt((r.*dphi).^2+dr.^2)./v);
    theta = pi/2+phi-atan(dr./(r.*dphi));
end