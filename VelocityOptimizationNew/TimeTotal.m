% Yukai Qian
% Duke Electric Vehicles
%
% TimeTotal  Total time per lap.
%
%   T = TimeTotal(V)
%
%   V       (m/s)   1-by-N vector of horizontal velocities.
%   T       (s)     Total time.

function T = TimeTotal(V)

T = sum(TimeIncr(V));