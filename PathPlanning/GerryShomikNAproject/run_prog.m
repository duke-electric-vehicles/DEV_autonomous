% Shomik Verma
% NA final project
% run_prog.m

clear;
%% import data

global m
m = 25+50;

%% Toy problem
N = 300;
tf = 210;

t = linspace(0,tf,N)';
phi = t/tf*2*pi;
h = 2*sin(phi)*0;

roundness = 10;
r = 300*(1./(cos(phi).^roundness + sin(phi).^roundness)).^(1/roundness);
pathcenter = [r.*cos(phi),r.*sin(phi)];
theta = atan2(gradient(r.*sin(phi)),gradient(r.*cos(phi)));
[v,i] = max(abs(diff(theta)));
theta(i+1:end) = theta(i+1:end)+2*pi;
path = pathcenter;
totalD = sum(sqrt(gradient(path(:,1)).^2+gradient(path(:,2)).^2));
v = totalD/tf.*ones(N,1);
lmin = -30;
lmax = 30;

% %% Real race track data
% data = importposdata('position_data.csv');
% % data = flipud(data); % if it's going the wrong direction (CCW)
% cut = 950;
% convlat = 111e3;
% convlong = 111e3;
% long = data.latitudedegrees;
% long = smooth(long,50);
% long = long(cut:(end-cut),1)*convlong;
% lat = data.longitudedegrees; % so that drives counterclockwise
% lat = smooth(lat,50);
% lat = lat(cut:(end-cut),1)*convlat;
% alt = data.altitudemeters;
% alt = smooth(alt,100);
% alt = alt(cut:(end-cut),1);
% h = alt;
% toCut = find(abs(gradient(long))<.01 & abs(gradient(lat))<0.01);
% long(toCut) = [];
% lat(toCut) = [];
% h(toCut) = [];
% num = size(h,1);
% tf = 210;
% t = linspace(0,tf,num)';
% 
% long = long-mean(long);
% lat = lat-mean(lat);
% 
% dlat = gradient(lat);
% dlong = gradient(long);
% totalD = sum(sqrt(dlat.^2+dlong.^2));
% d = cumsum(sqrt(dlat.^2+dlong.^2));
% theta = atan2(dlong,dlat);
% [v,i] = max(abs(diff(theta)));
% theta(i+1:end) = theta(i+1:end)-2*pi;
% 
% 
% %% define vars
% 
% N = 200;
% tvals = linspace(0,210,N)';
% dVals = totalD/N*(0:(N-1));
% x = spline(d,lat,dVals)';
% y = spline(d,long,dVals)';
% theta = spline(d,theta,dVals)';
% smooth(theta,100);
% h = spline(d,h,dVals)';
% t = tvals;
% d = dVals;
% vhiniteffect = (sqrt((max(h)-h)./(max(h)-min(h))))*sqrt(9.81)*2;
% v = totalD/tf.*ones(N,1) + vhiniteffect-mean(vhiniteffect);
% pathcenter = [x,y];
% path = pathcenter;
% 
% lmin = -8;
% lmax = 8;

%% plot initial configuration
plotSols(v,path,h,pathcenter,lmin,lmax,theta);
drawnow();

% figsPrepend = input('save file name: ','s');
% figsPrepend = 'pathTest';
% figure(1);
% print(['plots/',figsPrepend,'_initialvelocityPath'],'-dpng');
% figure(2);
% print(['plots/',figsPrepend,'_initialvelocityProf'],'-dpng');
% figure(3);
% print(['plots/',figsPrepend,'_initialoptimalPath'],'-dpng');
% figure(4);
% print(['plots/',figsPrepend,'_initialossBreakdown'],'-dpng');
% save(['saveData/',figsPrepend])

%% run optimization
vAll = [v];
pathAll = [path];
errv = 1e10;
errr = 1e10;
truetheta=theta;
tic;
for i = 1:15
    if ((max(errv)/max(errr(:)))>1e-1 || 1) % no need to update v if it's much closer than r
        vnew = velopt_new(v,path,h,truetheta,tf);
%         plotSols(vnew,path,h,pathcenter,lmin,lmax,theta);
        errv = abs(vnew-v); % change illicited by update step
    end
    if ((max(errr(:))/max(errv))>1e-1 || 1)
        [pathnew,truetheta] = pathopt_new(vnew,path,h,pathcenter,lmin,lmax,theta);
%         plotSols(vnew,pathnew,h,pathcenter,lmin,lmax,theta);
        errr = abs(pathnew-path);
    end
    fprintf('errv: %.2e\terrr: %.2e\n',max(errv),max(errr(:)));
    if (all(errv<0.01) && all(errr(:)<0.01))
        break;
    end
    v = vnew;
    path = pathnew;
    vAll = [vAll,v];
    pathAll = [pathAll,path];
end
toc;
beep
plotSols(vnew,path,h,pathcenter,lmin,lmax,theta);
%% figure export
figsPrepend = input('save file name: ','s');
figure(1);
print(['plots/',figsPrepend,'_velocityPath'],'-dpng');
figure(2);
print(['plots/',figsPrepend,'_velocityProf'],'-dpng');
figure(3);
print(['plots/',figsPrepend,'_optimalPath'],'-dpng');
figure(4);
print(['plots/',figsPrepend,'_lossBreakdown'],'-dpng');
save(['saveData/',figsPrepend])