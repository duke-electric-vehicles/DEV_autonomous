function [ r ] = pathopt( v,r0,h,rmin,rmax,phi )
%pathopt.m - given the velocity profile and constraints, solves for optimal
%path
%   pathopt(v,h,rmin,rmax,phi)
%       v - Nx1 vector: velocity profile
%       r0 - Nx1 vector: seed path
%       h - Nx1 vector: elevation data
%       rmin - Nx1 vector: lower bound on r
%       rmax - Nx1 vector: upper bound on r
%       phi - angular coordinate for polar
%   returns: r - radial coordinate for polar
%   
%   Gerry Chen
%   Last Modified 4/26/2018
%   For Numerical Analysis Spring 2018

    %plotSols(v,r0,h,rmin,rmax,phi);
    
    Aeq = zeros(1,length(r0));
    Aeq(1,1) = 1; % initial r
    Aeq(1,end) = -1; % final r
    beq(1) = 0;
    options = optimoptions(@fmincon,'MaxFunctionEvaluations',6000);
    problem = struct('objective',@(r) obj(r,phi,v,h),...
                     'x0',r0,'Aeq',Aeq,'beq',beq,'lb',rmin,'ub',rmax,...
                     'nonlcon',@(r) nonlcon(r,phi,v),...
                     'solver','fmincon','options',options);
    r = fmincon(problem);
    
    %plotSols(v,r,h,rmin,rmax,phi);
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
function [losses] = obj(r,phi,v,h)
    [theta,t] = preprocess(r,phi,v);
    hdot = gradient(h)./gradient(t);
    thetadot = gradient(theta)./gradient(t);
    vdot = gradient(v)./gradient(t);
    losses = trapz(t,v.*max(0,vdot+drag(hdot./v,v,thetadot)));
end
function [c,ceq] = nonlcon(r,phi,v)
    [theta,t] = preprocess(r,phi,v);
    thetadot = gradient(theta)./gradient(t);
    c = abs(thetadot)-30;
    ceq = theta(end)-theta(1)-2*pi; % end same angle started
end

function [] = plotSols(v,r,h,rmin,rmax,phi)
%plotSols - plots the solutions and loss mechanisms of a path
    [theta,t] = preprocess(r,phi,v);
    hdot = gradient(h)./gradient(t);
    thetadot = gradient(theta)./gradient(t);
    vdot = gradient(v)./gradient(t);
    [f,losses] = drag(hdot,v,thetadot);
    
    figure(3);clf;
    scatter(r.*cos(phi), r.*sin(phi),v)
    hold on
    plot(rmin.*cos(phi), rmin.*sin(phi),'r-');
    plot(rmax.*cos(phi), rmax.*sin(phi),'r-');
    axis square
    title('Path')
    xlabel('x (m)');
    ylabel('y (m)');
    
    figure(4);clf;
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
    drawnow()
end