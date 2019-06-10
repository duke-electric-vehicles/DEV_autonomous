% Yukai Qian
% Duke Electric Vehicles

function XCYCLE = Cycle(X, PERIOD)
% Cycle  Add last element of vector to beginning, and first to end.
%
%   XCYCLE = Cycle(X)
%   XCYCLE = Cycle(X, PERIOD)
%
%   X       1-by-N vector.
%   PERIOD  Cycle period.
%   XCYCLE  1-by-(N+2) vector [X(end) X X(1)].
%
%   Example:
%   Use DX = Uncycle(gradient(Cycle(X)) to find gradient of X with
%   more accurate beginning and ending values, assuming periodic
%   trajectory of car.

if nargin == 1
    XCYCLE = [X(end) X X(1)];
elseif nargin == 2
    XCYCLE = [X(end)-PERIOD X X(1)+PERIOD];
end