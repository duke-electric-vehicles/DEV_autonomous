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
%   ECOMPNT (J)     5-by-N vector of energy consumed by air drag, rolling 
%                   resistance, cornering loss, wheel drag, and motor loss.

function [ETOTAL, ECOMPNT] = Energy(V)

% Time increments
dt = TimeIncr(V);

% Energy losses
if nargout == 1
    pTotal = Power(V);
else
    [pTotal, pCompnt] = Power(V);
    pCompnt = pCompnt([2:5 7], :);
    ECOMPNT = trapz([0 cumsum(dt)], [pCompnt pCompnt(:, 1)], 2);
end

ETOTAL = trapz([0 cumsum(dt)], [pTotal pTotal(1)]);