function [ t, path_t ] = pathopt_new( t, path_t, track )
%pathopt.m - given the velocity profile and constraints, solves for optimal
%path
%   pathopt(t, path_t, track)
%       t - Nx1 vector: initial guess time
%       path_t - Nx1 vector: initial guess path parameter
%       track - Nx3x2 array: inner and outer bounds of track (xyz)
%   returns: t, path_t
%   
%   Gerry Chen
%   Last Modified 11/21/2018
%   For DEV 2018-19
    
    fprintf('optimizing path...\n');
    
    N = length(t);
    
    path = pathToCart(track, t);
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