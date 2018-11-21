function [ path,truetheta ] = pathopt_new( v,path0,h,pathcenter,lmin,lmax,theta )
%pathopt.m - given the velocity profile and constraints, solves for optimal
%path
%   pathopt(v,h,rmin,rmax,phi) % UPDATE THIS
%       v - Nx1 vector: velocity profile
%       r0 - Nx1 vector: seed path
%       h - Nx1 vector: elevation data
%       rmin - Nx1 vector: lower bound on r
%       rmax - Nx1 vector: upper bound on r
%       phi - angular coordinate for polar
%   returns: r - radial coordinate for polar
%   
%   Gerry Chen
%   Last Modified 4/30/2018
%   For Numerical Analysis Spring 2018
    
    fprintf('optimizing path...\n');
    
    [dd,dt] = cartToPath(pathcenter,v);
    l0 = cartToGuess(path0,pathcenter,theta);
    
    fprintf('total d: %.2f\n',sum(dd));
    fprintf('tEnd: %.2f\n',sum(dt));
    assert(abs(sum(dt)-210)<40);
    hprime = gradient(h)./dd;
    lmin = lmin.*ones(size(pathcenter,1),1);
    lmax = lmax.*ones(size(pathcenter,1),1);
    
    Aeq = zeros(1,length(pathcenter));
    Aeq(1,1) = 1; % initial l
    Aeq(1,end) = -1; % final l
    beq(1) = 0;
    options = optimoptions(@fmincon,'MaxFunctionEvaluations',6000);
    problem = struct('objective',@(l) obj(dd,l,v,hprime,theta),...
                     'x0',l0,'Aeq',Aeq,'beq',beq,'lb',lmin,'ub',lmax,...
                     'nonlcon',@(l) nonlcon(dd,l,theta),...
                     'solver','fmincon','options',options);
    l = fmincon(problem);
    
    [path] = pathToCart(pathcenter,theta,l);
%     r
    dl = gradient(l);
    truetheta = theta + atan2(dl,dd);
    
    fprintf('optimized path\n');
    
    plotSols(pathcenter,theta,l,lmin,lmax,v,dd,hprime);
    
    fprintf('plotted\n');
end

function [path] = pathToCart(pathcenter,theta,l)
    N = [-sin(theta),cos(theta)];
    path = pathcenter+l.*N;
end
function [dd,dt] = cartToPath(cart,v)
    dx = gradient(cart(:,1));
    dy = gradient(cart(:,2));
    dd = sqrt(dx.^2+dy.^2);
    dt = dd./v;
end
function [l] = cartToGuess(cart0,cartcenter,theta)
    % dx . N
    N = [-sin(theta),cos(theta)];
    dx = cart0-cartcenter;
    l = sum(dx.*N,2);
end
function [losses] = obj(dd,l,v,hprime,theta)
%     dl = diff(l);dl = [dl(1);dl]; % pre-diff (not centered)
    dl = gradient(l);
    theta = theta + atan2(dl,dd); % extra angle change due to new path
    dtheta = gradient(theta);
    ddnew = sqrt((dd-l.*dtheta).^2+dl.^2); % I think this is sensitive to direction of motion (CCW)
    dtnew = ddnew./v;
    thetadot = gradient(theta)./dtnew;
    vdot = gradient(v)./dtnew;
    powerInput = (max(0,vdot+drag(hprime,v,thetadot))) .* v;
    losses = sum(powerInput./motorEfficiency(powerInput,v) .* dtnew); % sum (accel*v dt)
end
function [f,losses] = lossesBreakdown(dd,l,v,hprime,theta)
    dtheta = gradient(theta);
    dl = gradient(l);
    ddnew = sqrt((dd+l.*dtheta).^2+dl.^2);
    dtnew = ddnew./v;
    thetadot = gradient(theta)./dtnew;
    vdot = gradient(v)./dtnew;
    [f,losses] = drag(hprime,v,thetadot);
    f = v.*max(0,vdot+f).*dtnew;
    losses = v.*losses.*dtnew;
end

%% utility functions
% note to self: dx means delta(x), xdot means dx/dt
function [c,ceq] = nonlcon(dd,l,theta)
    
    theta = theta + atan2(gradient(l),dd);
%     c = abs(thetadot)-30; % constrain steering strength
%     c = min(8-abs(dd./gradient(theta)))*1e-8; % 8m turning radius 
    c = []; % use turning radius constraint for sonoma
%     ceq = l(end)-l(1); % end same horiz displacement as started
    dl = gradient(l);
    ceq = dl(1)-dl(end); % ending/start angle
end

function [] = plotSols(pathcenter,theta,l,lmin,lmax,v,dd,hprime)
%plotSols - plots the solutions and loss mechanisms of a path
    
    [path] = pathToCart(pathcenter,theta,l);
    [pathmin] = pathToCart(pathcenter,theta,lmin);
    [pathmax] = pathToCart(pathcenter,theta,lmax);
    
%     figure(3);clf;
    figure(1);
    f = subplot(2,2,3);
    cla(f);
%     figure(4);clf;
    plot(path(:,1),path(:,2),'k-')
    hold on
    plot(pathmin(:,1),pathmin(:,2),'r-')
    plot(pathmax(:,1),pathmax(:,2),'r-')
    axis square
    title('Path')
    xlabel('x (m)');
    ylabel('y (m)');
    
    drawnow()
end