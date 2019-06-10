% Yukai Qian
% Duke Electric Vehicles

function XDOT = TimeDiff(X, DT)
% TimeDiff  Time differential of X.
%
%   X       1-by-N vector of X = X(t) values.
%   DT      1-by-N vector of time increments.
%   XDOT    1-by-N vector of XDOT = dX(t)/dt values.

XDOT = Uncycle(gradient(Cycle(X))) ./ DT;