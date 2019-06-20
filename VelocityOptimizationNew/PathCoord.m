% Yukai Qian, Gerry Chen
% Duke Electric Vehicles
%
% PathCoord  Calculates distance from start, absolute yaw, slope, and 
%            distance and yaw increments. Rearranges data points to set
%            start where yaw is closest to 0. Save all in original file.
%
%   PathCoord(TRACK)
%
%   TRACK   Name of .mat file containing x, y and z values along a track.
%
%   Notice:
%   Assuming going counterclockwise along the track. For robustness,
%   set the Cartesian coordinates so that no straight line is parallel to
%   the x-axis.

function PathCoord(TRACK)

track = load(TRACK);

%% Yaw

% Angle between x-axis and line section from one point to the next
track.yaw = mod(atan2(Incr(track.y), Incr(track.x)), 2*pi);

% Rearrange data
[~, index] = min(track.yaw); %#ok<ASGLU>

for var = ["x" "y" "z" "yaw"]
    eval(sprintf('track.%1$s = circshift(track.%1$s, -index+1);', var));
end

% Find yaw increments
track.dyaw = Incr(track.yaw);
track.dyaw(end) = mod(track.dyaw(end), 2*pi);

%% Distance

track.ds = hypot(Incr(track.x), Incr(track.y));
track.s = [0 cumsum(track.ds)]; % One more element than other arrays

%% Slope

track.slope = Incr(track.z) ./ track.ds;

%% Save to original file

save(TRACK, '-struct', 'track')