% Yukai Qian
% Duke Electric Vehicles

function OMEGA = AngVel(R, PHI, DT)
% AngVel  Angular velocity of yaw.
%
%   OMEGA = AngVel(R, PHI, DT)
%
%   R       (m)     1-by-N vector of radial coordinates.
%   PHI     (rad)   1-by-N vector of angular coordinates.
%   DT      (s)     1-by-N vector of cumulative times since start.
%   OMEGA   (rad/s) 1-by-N vector of angular velocities of yaw.

R = Cycle(R);
PHI = Cycle(PHI, 2*pi);

% Angle between velocity and y axis
theta = -atan(gradient(R) ./ gradient(PHI) ./ R) + PHI;

% Angular velocity of yaw
OMEGA = Uncycle(gradient(theta)) ./ DT;