%  vYukai Qian
% Duke Electric Vehicles

function RESULT = Eval(TRACK, M, V, OUTPUT)
% Eval  Evaluate total energy consumed and time spent per lap.
%
%   RESULT = Eval(TRACK, M, V)
%   RESULT = Eval(___, OUTPUT)
%
%   TRACK           Structure containing 1-by-N vectors of r, phi and 
%                   (optionally) z values.
%   M       (kg)    Mass.
%   V       (m/s)   1-by-N values of horizontal velocities.
%   OUTPUT          Value to output as RESULT. 'energy'/'time'/'maxpower'.
%                   'energy' by default.
%   RESULT          Total energy, time per lap or maximum power.

if nargin == 3
    OUTPUT = 'energy';
end

%% Import data

trackData = TRACK;

r = trackData.r;
phi = trackData.phi;
z = trackData.z;
    
%% Calculate

[ds, slope] = DispIncr(r, phi, z);
[dt, TCUML] = TimeIncr(ds, V);

if strcmp(OUTPUT, 'time')
    RESULT = TCUML(end);
elseif strcmp(OUTPUT, 'energy') || strcmp(OUTPUT, 'maxpower')
    omega = AngVel(r, phi, dt);
    f = Tract(M, V, omega, dt, slope);
    pTotal = PMotor(f, V);
    
    if strcmp(OUTPUT, 'maxpower')
        RESULT = max(abs(pTotal));
    else
        RESULT = trapz(TCUML, [pTotal, pTotal(1)]);
    end
end