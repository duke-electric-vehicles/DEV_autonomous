function [ t, path_t ] = pathopt_new( t, path_t, track )
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
    
%     [dd,dt] = cartToPath(pathcenter,v);
%     l0 = cartToGuess(path0,pathcenter,theta);
    N = length(t);
    
    path = pathToCart(track, t);
    h = path(:,3);
    dd = sum(sqrt(sum(gradient(path')'.^2, 2)));
    dt = gradient(t);
    
    fprintf('total d: %.2f\n',sum(dd));
    fprintf('tEnd: %.2f\n',sum(dt));
    assert(abs(sum(dt)-210)<40);
    
    Aeq = zeros(1,N);
    Aeq(1,N+1) = 1; % initial l
    Aeq(1,N+N) = -1; % final l
    Aeq(2,1:N) = 1; % final time
    beq(1) = 0;
    beq(2) = 210; % tf
    lb = zeros(2*N,1);
    ub = ones(2*N,1);
    ub(1:N) = inf;
    options = optimoptions(@fmincon,'MaxFunctionEvaluations',3000);
    problem = struct('objective',@(vec) obj(cumsum(vec(1:N)), vec(N+1:N+N), track),...
                     'x0',[dt;path_t],'Aeq',Aeq,'beq',beq,...
                     'lb',lb,'ub',ub,...
                     'nonlcon',@(vec) nonlcon(cumsum(vec(1:N)), vec(N+1:N+N), track),...
                     'solver','fmincon','options',options);
    sol = fmincon(problem);
    
    t = cumsum(sol(1:N));
    path_t = sol(N+1:N+N);
    
    fprintf('optimized path\n');
    
    plotSols(t, path_t, track);
    
    fprintf('plotted\n');
end

% function [path] = pathToCart(pathcenter,theta,l)
%     N = [-sin(theta),cos(theta)];
%     path = pathcenter+l.*N;
% end
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
function [losses] = obj(t, path_t, track)
%     dl = diff(l);dl = [dl(1);dl]; % pre-diff (not centered)
    path = pathToCart(track, path_t);
    dpath = gradient(path')';
    
    [theta, dtheta] = calcTheta(dpath);
    
    dl = sqrt(sum(dpath.^2, 2));
    dt = gradient(t);
    v = dl ./ dt;
    thetadot = gradient(theta)./dl; % technically this should only be the horizontal part of dl
    vdot = gradient(v)./dt;
    hprime = dpath(:,3)./dl;
    powerInput = (max(0,vdot+drag(hprime,v,thetadot))) .* v;
    losses = sum(powerInput./motorEfficiency(powerInput,v) .* dt); % sum (accel*v dt)
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
function [c,ceq] = nonlcon(t, path_t, track)
    
    N = length(t);
    dt = gradient(t);
%     theta = theta + atan2(gradient(l),dd);
%     c = abs(thetadot)-30; % constrain steering strength
%     c = min(8-abs(dd./gradient(theta)))*1e-8; % 8m turning radius 
    path = pathToCart(track, path_t);
    dpath = gradient(path')';
    c = []; % use turning radius constraint for sonoma
%     ceq = l(end)-l(1); % end same horiz displacement as started
%     dl = gradient(l);
%     ceq = dl(1)-dl(end); % ending/start angle
    ceq(1) = atan2(dpath(1,2), dpath(1,1)) - atan2(dpath(N,2), dpath(N,1)); % start/end angle
    dl = sqrt(sum(dpath.^2, 2));
    ceq(2) = dl(1)/dt(1) - dl(end)/dt(end); % begin/end speed
end

% function [] = plotSols(t, path_t, track)
% %plotSols - plots the solutions and loss mechanisms of a path
%     
%     [path] = pathToCart(track, path_t);
%     
% %     figure(3);clf;
%     figure(1);
%     f = subplot(2,2,3);
%     cla(f);
% %     figure(4);clf;
%     plot(path(:,1),path(:,2),'k-')
%     hold on
%     plot(track(:,1,1),track(:,2,1),'r-')
%     plot(track(:,1,2),track(:,2,2),'r-')
%     axis square
%     title('Path')
%     xlabel('x (m)');
%     ylabel('y (m)');
%     
%     drawnow()
% end