%%  Gerry Chen
%   animation.m - animates data from solutions

clear;
% filename = input('filename: ','s');
filename = 'alternating_test3';

load(['saveData/',filename]);

if (exist('rAll'))
    while(true)
        v = vAll(:,1);
        r = rAll(:,1);
        plotSols_old(v,r,h,rmin,rmax,phi);
        for i = 2:size(vAll,2)
%             pause();
            v = vAll(:,i);
            plotSols_old(vnew,r,h,rmin,rmax,phi);
%             pause();
            r = rAll(:,i);
            plotSols_old(vnew,r,h,rmin,rmax,phi);
        end
        pause();
    end
else
    while(true)
        v = vAll(:,1);
        path = pathAll(:,1:2);
        plotSols(vnew,path,h,pathcenter,lmin,lmax,theta);
        for i = 2:size(vAll,2)
    %         pause(.5);
            v = vAll(:,i);
            plotSols(vnew,path,h,pathcenter,lmin,lmax,theta);
    %         pause(.5);
            path = pathAll(:,2*i-1:2*i);
            plotSols(vnew,path,h,pathcenter,lmin,lmax,theta);
        end
        pause(.5);
    end
end