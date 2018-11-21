%%  Gerry Chen
%   animation.m - animates data from solutions

clear;
% filename = input('filename: ','s');
filename = 'testing';

load(['saveData/',filename]);

while(true)
    for i = 1:size(tAll,2)
        t = tAll(:,i);
        path_t = pathAll(:,i);
        plotSols(t, path_t, track);
    end
    pause(1);
end