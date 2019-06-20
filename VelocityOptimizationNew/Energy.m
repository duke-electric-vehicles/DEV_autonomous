% Yukai Qian
% Duke Electric Vehicles
%
% Energy  Energy loss components including air drag, rolling resistance,
%         cornering loss, wheel loss and motor loss.
%
%   ETOT = Energy(V)
%   [ETOT, ECOMPNT] = Energy(___)
%
%   V       (m/s)   1-by-N vector of horizontal velocities.
%   ETOT    (J)     1-by-N vector of total energy loss.
%   ECOMPNT (J)     7-by-N vector of energy consumed by rolling resistance,
%                   air drag, cornering loss, wheel drag, and motor loss.

function [ETOT, ECOMPNT] = Energy(V)

% Time increments
dt = TimeIncr(V);

% Energy losses
if nargout == 1
    PTOT = Power(V);
else
    [PTOT, PCOMPNT] = Power(V);
    PCOMPNT = PCOMPNT([2:5 7], :);
    ECOMPNT = trapz([0 cumsum(dt)], [PCOMPNT PCOMPNT(:, 1)], 2);
end

ETOT = trapz([0 cumsum(dt)], [PTOT PTOT(1)]);