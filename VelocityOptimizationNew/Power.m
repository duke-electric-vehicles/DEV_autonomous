% Yukai Qian, Gerry Chen
% Duke Electric Vehicles
%
% Power  Total power and power components.
%
%   PTOT = Power(V)
%   [PTOT, PCOMPNT] = Power(___)
%
%   V       (m/s)   1-by-N vector of horizontal velocities.
%   PTOT    (W)     1-by-N vector of total powers.
%   PCOMPNT (W)     7-by-N vector of power consumed by acceleration, 
%                   rolling resistance, air drag, cornering loss, wheel 
%                   drag, elevation change and motor loss.

function [PTOT, PCOMPNT] = Power(V)

global r u cEddy regen pMax

%% Output power

% Tractive force
f = Tract(V);

% Output power
PCOMPNT = f.*V;
POUT = sum(PCOMPNT);

%% Total power

% Current
i = POUT/u;

% Motor power loss
PMOTOR = r*i.^2 + cEddy*V.^2;

% Total power
PTOT = POUT + PMOTOR;

% Disable re-gen if regen == 0 (false).
if strcmp(regen, 'off')
    PTOT = PTOT .* (POUT > 0);
elseif ~strcmp(regen, 'on')
    pRegenMax = regen*pMax;
    PTOT = PTOT .* (PTOT > -pRegenMax) - pRegenMax * (PTOT <= -pRegenMax);
end

%% Motor power loss

if nargout == 2
    PCOMPNT = [PCOMPNT; PMOTOR];
end