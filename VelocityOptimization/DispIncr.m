% Yukai Qian
% Duke Electric Vehicles

function [DS, SLOPE] = DispIncr(s, Z)
% DispIncr  Displacement increments and slopes.
%
%   DS = DispIncr(R, PHI)
%   [DS, SLOPE] = DispIncr(___, Z)
%
%   s       (m)     1-by-N vector of distance parameter coordinates.
%   Z       (m)     1-by-N vector of elevations. 0 by default.
%   DS      (m)     1-by-N vector of displacement increments.
%   SLOPE           1-by-N vector of slopes of track.

if nargin == 1
    Z = zeros(1, length(s));
end
global totalS

S = Cycle(s, totalS); % make sure loop closure
Z = Cycle(Z);

% Displacement increments
DS = gradient(S);

% Slope
SLOPE = gradient(Z) ./ DS;

DS = Uncycle(DS);
SLOPE = Uncycle(SLOPE);