% Shomik Verma
% NA final project
% drag.m

function [f,losses] = drag(dh, v, thetadot)
    global m
    c = 1/2*1.225*.1*0.352/3;
    mu = .001*ones(length(v),1);
    g = 9.81;
    calpha = 1.06e-2;
    % Constant definitions: Elevation Change, Air Resistance, Turning, Rolling Resistance
    losses = [g*dh, c/m*v.^2, calpha*(v.*thetadot).^2, mu*g];
    f = sum(losses,2);
    
end
