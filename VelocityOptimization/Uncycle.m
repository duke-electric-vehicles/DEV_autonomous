% Yukai Qian
% Duke Electric Vehicles

function X = Uncycle(XCYCLE)
% Uncycle  Remove first and last elements of vector.
%
%   X = Uncycle(XCYCLE)
%
%   XCYCLE  1-by-(N+2) vector.
%   X       1-by-N vector XCYCLE(2:end-1).
%
%   Example:
%   Use DX = Uncycle(gradient(Cycle(X)) to find gradient of X with
%   more accurate beginning and ending values, assuming periodic
%   trajectory of car.

X = XCYCLE(2:end-1);