% Yukai Qian
% Duke Electric Vehicles

function [DT, TCUML] = TimeIncr(DS, V)
% Time
%
%   DT = TimeIncr(DS, V)
%   [DT, TCUML] = TimeIncr(___)
%
%   DS      (m)     1-by-N vector of displacement increments.
%   V       (m/s)   1-by-N vector of horizontal velocities.
%   DT      (s)     1-by-N vector of time increments.
%   TCUML   (s)     1-by-(N+1) vector of cumulative times since start.


% V = Cycle(V);

DT = DS ./ ...
     ((V + circshift(V,-1))/2); %mean([Uncycle(V); V(3:end)]);
TCUML = [0 cumsum(DT)];