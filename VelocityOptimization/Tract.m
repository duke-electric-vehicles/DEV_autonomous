% Yukai Qian
% Duke Electric Vehicles

function F = Tract(M, V, OMEGA, DT, SLOPE)
% Tract  Tractive force generated by the rear wheel.
%
%   F = Tract(M, V, OMEGA, DT)
%   F = Tract(___, SLOPE)
%
%   M       (kg)    Mass.
%   V       (m/s)   1-by-N vector of horizontal velocities.
%   OMEGA   (rad/s) 1-by-N vector of angular velocities.
%   DT      (s)     1-by-N vector of cumulative times since start.
%   SLOPE           1-by-N vector of slopes of track. 0 by default.
%   F       (N)     1-by-N vector of tractive forces.
%
%   Considering acceleration, rolling resistance, air drag, cornering loss
%   and elevation change.

if nargin == 4
    SLOPE = zeros(1, length(V));
end

mu  = 0.0015;      % Rolling resistance coefficient
g   = 9.809;      % (m/s^2) Local gravitational acceleration
rho = 1.2;        % (kg/m^3) Air density at 20 C
cdA = 0.037;        % (m^2) Drag coefficient times area
c   = 120*180/pi; % (N/rad) Tire cornering stiffness

% Acceleration
a = TimeDiff(V, DT);
fAcc = M*a;

% Rolling resistance
fRoll = mu*M*g;

% Air drag
fAir = 1/2 * rho * cdA * V.^2;

% Cornering loss
alpha = M*V.*abs(OMEGA) ./ c; % (rad) Tire slip angle.
fCor = c .* alpha.^2;

% Elevation change
fSlope = SLOPE*M*g;

% Tractive force
F = fAcc + fRoll + fAir + fCor + fSlope;