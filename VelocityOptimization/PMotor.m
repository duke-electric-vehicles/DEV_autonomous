% Yukai Qian
% Duke Electric Vehicles

function [PTOT, PLOSS, ETA] = PMotor(POUT, U)
% PMotor  Total power, power loss and efficiency of motor.
%
%   PTOT = PMotor(POUT)
%   PTOT = PMotor(POUT, U)
%   [PTOT, PLOSS, ETA] = PMotor(POUT, U)
%
%   POUT    (W) 1-by-N vector of output power.
%   U       (V) Motor voltage. 12 by default.
%   PTOT    (W) 1-by-N vector of total power.
%   PLOSS   (W) 1-by-N vector of power loss.
%   ETA     1-by-N vector of motor efficiency.
%
%   Assuming PLOSS equals resistance loss.

if nargin == 1
    U = 12;
end

R = 0.07; % Ohm, motor resistance

% Current
I = POUT/U;

PLOSS = R * I.^2;
PTOT = POUT + PLOSS;
ETA = POUT./PTOT;