%%  compute track path coordinates

clear
load('Galot')

x = fliplr(x);
y = fliplr(y);
z = fliplr(z);
x(end+1) = x(1);
y(end+1) = y(1);
z(end+1) = z(1);

dx = diff(x);
dy = diff(y);
DS = hypot(dx, dy);
S = [0, cumsum(DS)];

totalS = S(end);
x(end) = [];
y(end) = [];
z(end) = [];
S(end) = [];

newS = linspace(0, S(end), 500);
x = spline(S, x, newS);
y = spline(S, y, newS);
z = spline(S, z, newS);

dx = diff(x);
dy = diff(y);
DS = hypot(dx, dy);
S = [0, cumsum(DS)];

globalAngles = atan2(dy, dx);
bodyAngles = diff(globalAngles);
bodyAngles(end+1) = globalAngles(1) - globalAngles(end);
bodyAngles = mod(bodyAngles + pi, 2*pi) - pi;

s = S;
dyaw = bodyAngles;
dyaw = smooth(dyaw,25, 'sgolay')';
DXreconstructed = diff(S) .* cos(cumsum(dyaw));
DYreconstructed = diff(S) .* sin(cumsum(dyaw));
Xrecon = [0, cumsum(DXreconstructed)];
Yrecon = [0, cumsum(DYreconstructed)];

figure(1);clf;
plot(s)
yyaxis right
plot(dyaw)
figure(2);clf;
scatter(x,y,3,s); hold on 
scatter(Xrecon, Yrecon, 3, s);
colorbar; axis equal

save('Galot2', 'x','y','z','s','dyaw','totalS');