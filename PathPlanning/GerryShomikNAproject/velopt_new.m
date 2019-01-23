function [ v ] = velopt_new( v0,path,h,theta,tf )
%velopt.m - given the path and constraints, solves for optimal velocity
%profile
%   velopt(v,h,rmin,rmax,phi) % UPDATE THIS
%       v0 - Nx1 vector: seed velocity profile
%       r - Nx1 vector: path
%       h - Nx1 vector: elevation data
%       phi - angular coordinate for polar
%       tf - final time (constrained)
%   returns: r - radial coordinate for polar
%   
%   Gerry Chen
%   Last Modified 4/30/2018
%   For Numerical Analysis Spring 2018

%     plotSols(v0,r,h,phi);
    
    fprintf('optimizing velocity...\n');
    
    dd = cartToPath(path);
    hprime = gradient(h)./dd;
    
    Aeq = zeros(1,length(v0));
    Aeq(1,1) = 1; % initial v
    Aeq(1,end) = -1; % final v
    beq(1) = 0;
    lb = ones(length(v0),1)*3;
    ub = ones(length(v0),1)*13.41; % 30mph
    options = optimoptions(@fmincon,'MaxFunctionEvaluations',3000);
    problem = struct('objective',@(v) obj(dd,v,hprime,theta),...
                     'x0',v0,'Aeq',Aeq,'beq',beq,'lb',lb,'ub',ub,...
                     'nonlcon',@(v) nonlcon(dd,v,tf),...
                     'solver','fmincon','options',options);
    v = fmincon(problem);
    
    fprintf('optimized velocity\n');
    
%     plotSols(v,r,h,phi);
end

%% utility functions
% note to self: dx means delta(x), xdot means dx/dt
function [path] = pathToCart(pathcenter,theta,l)
    N = [-sin(theta),cos(theta)];
    path = pathcenter+l.*N;
end
function [dd] = cartToPath(cart,v)
    dx = gradient(cart(:,1));
    dy = gradient(cart(:,2));
    dd = sqrt(dx.^2+dy.^2);
end
function [l] = cartToGuess(cart0,cartcenter,theta)
    % dx . N
    N = [-sin(theta),cos(theta)];
    dx = cart0-cartcenter;
    l = sum(dx.*N,2);
end
function [losses] = obj(dd,v,hprime,theta)
    dtheta = gradient(theta);
    dtnew = dd./v;
    thetadot = dtheta./dtnew;
    vdot = gradient(v)./dtnew;
    
    powerInput = (max(0,vdot+drag(hprime,v,thetadot))) .* v;
    losses = sum(powerInput./motorEfficiency(powerInput,v) .* dtnew); % sum (accel*v dt)
%     if (l(end-1)~=0)
%         fprintf('hello')
%     end
%     losses = sum(l);
%     losses = trapz(cumtrapz(dtnew),v.*max(0,vdot+drag(hprime,v,thetadot)));
end

function [c,ceq] = nonlcon(dd,v,tf)
    c = [];
    dtnew = dd./v;
    ceq = sum(dtnew)-tf; % end at the exact right time
end

function [] = plotSols(v,r,h,phi)
%plotSols - plots the solutions and loss mechanisms of a path
    [theta,t] = preprocess(r,phi,v);
    hdot = gradient(h)./gradient(t);
    thetadot = gradient(theta)./gradient(t);
    [f,losses] = drag(hdot,v,thetadot);
    
    rSpline = spline(t,r);
    phif = spline(t,phi);
    tVals = linspace(0,t(end));
%     figure(1);clf;
    figure(1);
    subplot(2,2,1);cla;
    plot(ppval(rSpline,tVals).*cos(ppval(phif,tVals)),...
         ppval(rSpline,tVals).*sin(ppval(phif,tVals)),'b.')
    axis square
    title('Path')
    xlabel('x (m)');
    ylabel('y (m)');
    
%     figure(2);clf;
    subplot(2,2,2);cla;
    plot(t,v,'b-')
    ylim([0,15])
    drawnow();

%     figure(3);clf;
    subplot(2,2,3);cla;
    for loss=losses
        plot(phi,loss.*v);
        hold on
    end
    legend('elevation','air resistance','turning','rolling resistance')
    title('Losses vs \phi')
    xlabel('\phi - polar angular direction (rad)');
    ylabel('Loss (W)')
    drawnow()
end