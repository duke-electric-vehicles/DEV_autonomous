% Yukai Qian
% Duke Electric Vehicles

function [DS, SLOPE] = DispIncr(R, PHI, Z)
% DispIncr  Displacement increments and slopes.
%
%   DS = DispIncr(R, PHI)
%   [DS, SLOPE] = DispIncr(___, Z)
%
%   R       (m)     1-by-N vector of radial coordinates.
%   PHI     (rad)   1-by-N vector of angular coordinates.
%   Z       (m)     1-by-N vector of elevations. 0 by default.
%   DS      (m)     1-by-N vector of displacement increments.
%   SLOPE           1-by-N vector of slopes of track.

if nargin == 2
    Z = zeros(1, length(R));
end

R = Cycle(R);
PHI = Cycle(PHI, 2*pi);
Z = Cycle(Z);

% Displacement increments
DS = hypot(gradient(R), R .* gradient(PHI));

% Slope
SLOPE = gradient(Z) ./ DS;

DS = Uncycle(DS);
SLOPE = Uncycle(SLOPE);