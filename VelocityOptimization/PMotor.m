% Yukai Qian
% Duke Electric Vehicles

function [PTOT, POUT, PLOSS] = PMotor(F, V, U)
% PMotor  Total power, output power, power loss and efficiency of motor.
%
%   PTOT = PMotor(F, V)
%   PTOT = PMotor(F, V, U)
%   [PTOT, POUT, PLOSS, ETA] = PMotor(___)
%
%   F       (N)     1-by-N vector of tractive forces.
%   V       (m/s)   1-by-N vector of horizontal velocities.
%   U       (V)     Motor voltage. 12 by default.
%   PTOT    (W)     1-by-N vector of total powers.
%   POUT    (W)     1-by-N vector of output powers.
%   PLOSS   (W)     1-by-N vector of power losses.
%
%   Assuming PLOSS equals resistance loss.

if nargin == 2
    U = 12;
end

r = 1; % Ohm, motor resistance

% Output power
POUT = F.*V;

% Current
i = POUT/U;

% Power loss, total power, efficiency
PLOSS = r * i.^2;
PTOT = POUT + PLOSS;
