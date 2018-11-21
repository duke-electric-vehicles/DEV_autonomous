function [ v ] = velopt( v0,r,h,phi,tf )
%velopt.m - given the path and constraints, solves for optimal velocity
%profile
%   velopt(v,h,rmin,rmax,phi)
%       v0 - Nx1 vector: seed velocity profile
%       r - Nx1 vector: path
%       h - Nx1 vector: elevation data
%       phi - angular coordinate for polar
%       tf - final time (constrained)
%   returns: r - radial coordinate for polar
%   
%   Gerry Chen
%   Last Modified 4/26/2018
%   For Numerical Analysis Spring 2018

%     plotSols(v0,r,h,phi);
    
    fprintf('optimizing velocity...\n');
    
    Aeq = zeros(1,length(v0));
    Aeq(1,1) = 1; % initial v
    Aeq(1,end) = -1; % final v
    beq(1) = 0;
    lb = zeros(length(v0),1);
    ub = ones(length(v0),1)*13.41; % 30mph
    options = optimoptions(@fmincon,'MaxFunctionEvaluations',3000);
    problem = struct('objective',@(v) obj(r,phi,v,h),...
                     'x0',v0,'Aeq',Aeq,'beq',beq,'lb',lb,'ub',ub,...
                     'nonlcon',@(v) nonlcon(r,phi,v,tf),...
                     'solver','fmincon','options',options);
    v = fmincon(problem);
    
    fprintf('optimized velocity\n');
    
%     plotSols(v,r,h,phi);
end

%% utility functions
% note to self: dx means delta(x), xdot means dx/dt
function [theta,t] = preprocess(r,phi,v)
    % TODO: memoize
    dphi = gradient(phi);
    dr = gradient(r);
    t = cumsum(sqrt((r.*dphi).^2+dr.^2)./v);
    theta = pi/2+phi-atan(dr./(r.*dphi));
end
function [effort] = obj(r,phi,v,h)
    [theta,t] = preprocess(r,phi,v);
    hdot = gradient(h)./gradient(t);
    thetadot = gradient(theta)./gradient(t);
    vdot = gradient(v)./gradient(t);
    effort = trapz(t,v.*max(0,vdot+drag(hdot./v,v,thetadot)));
end
function [c,ceq] = nonlcon(r,phi,v,tf)
    [theta,t] = preprocess(r,phi,v);
    thetadot = gradient(theta)./gradient(t);
    c = abs(thetadot)-30;
    ceq = t(end)-tf; % end at the exact right time
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