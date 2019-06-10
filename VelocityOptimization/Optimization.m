% Yukai Qian
% Duke Electric Vehicles

close all; format shortg

global track m

%% Import data

track = load('Galot.mat');
r   = track.r;
phi = track.phi;
x   = track.x;
y   = track.y;
z   = track.z;

%% Prepare function for optimization

% Mass of car
mCar = 21;
mDriver = 50;
m = mCar + mDriver;

% Energy function
Energy = @(V) Eval(track, m, V);

% Initial guess
N = length(track.r);
v0 = smooth(v)';

% Constraints
Lower = zeros(1, N);
Upper = 10*ones(1, N);
tMax = 295; % Maximum time
pMax = 144; % Maximum power to/from motor

% Options
Options = optimoptions('fmincon', ...
                       'MaxFunctionEvaluations', 1e6, ...
                       'MaxIterations', 1e4);

%% Optimize

v = fmincon(Energy, v0, [], [], [], [], ...
            Lower, Upper, @(V) Constr(V, tMax, pMax), ...
            Options);

%% Constraint function

function [C, CEQ] = Constr(V, TMAX, PMAX)
    global track m
    
    % Time < TMAX,
    C = [Eval(track, m, V, 'time') - TMAX
         Eval(track, m, V, 'maxpower') - PMAX];
    CEQ = [];
end