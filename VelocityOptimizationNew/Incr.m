% Yukai Qian, Gerry Chen
% Duke Electric Vehicles
%
% Incr  Increments of X.
%
%   X       1-by-N vector of X = X(t) values.
%   DX      1-by-N vector of increments from each X element to the next.

function DX = Incr(X)

DX = circshift(X, -1) - X;