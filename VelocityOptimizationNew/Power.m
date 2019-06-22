% Yukai Qian, Gerry Chen
% Duke Electric Vehicles
%
% Power  Total power and power components.
%
%   PTOT = Power(V)
%   [PTOT, PCOMPNT] = Power(___)
%
%   V       (m/s)   1-by-N vector of horizontal velocities.
%   PTOTAL  (W)     1-by-N vector of total powers.
%   PCOMPNT (W)     7-by-N vector of power consumed by acceleration, 
%                   air drag, rolling resistance, cornering loss, wheel 
%                   drag, elevation change and motor loss.

function [PTOTAL, PCOMPNT] = Power(V)

global r u d cEddy regen pMax

%% Output power

% Tractive force
f = Tract(V);

% Output power
PCOMPNT = f.*V;
pOut    = sum(PCOMPNT);

%% Eddy current loss

% Angular velocity in rpm
rpm = 60/(2*pi) * V/(d/2);

% Eddy current loss
pEddy = -polyval(cEddy, rpm);

%% Total power

% Current = total power / voltage:
%   i = PTOTAL/u;
% Motor power loss = eddy current loss + resistance loss:
%   pLoss = pEddy + r*i^2;
% Total power = output power + motor power loss:
%   PTOTAL = pOut + pLoss;
% Therefore, we have equation:
%   PTOTAL^2 - u^2/r * PTOTAL + u^2/r * (pOut + pEddy) = 0.
% It can be solved as follows.

b   = -u^2/r;
c   = -b * (pOut + pEddy);
det = b^2 - 4*c;

% Total power
PTOTAL = (-b - sqrt(det))/2;

% Disable re-gen if regen == 0 (false).
if strcmp(regen, 'off')
    PTOTAL = PTOTAL .* (pOut > 0);
elseif ~strcmp(regen, 'on')
    pRegenMax = regen*pMax;
    PTOTAL = PTOTAL .* (PTOTAL > -pRegenMax) ...
             - pRegenMax * (PTOTAL <= -pRegenMax);
end

%% Motor power loss

if nargout == 2
    PCOMPNT = [PCOMPNT; PTOTAL-pOut];
end