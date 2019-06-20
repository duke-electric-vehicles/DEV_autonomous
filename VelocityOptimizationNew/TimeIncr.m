% Yukai Qian, Gerry Chen
% Duke Electric Vehicles
%
% TimeIncr  Time increments for track sections.
%
%   DT = TimeIncr(V)
%
%   V       (m/s)   1-by-N vector of horizontal velocities.
%   DT      (s)     1-by-N vector of time increments.

function DT = TimeIncr(V)

global track

DT = track.ds ./ mean([V; circshift(V, -1)]);