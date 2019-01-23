function [path] = pathToCart(track,t)
%pathToCart converts path coordinates to cartesian coordinates
%   track   the track in left/right boundary format (according to
%   importTrack.m)
%   t       the parameter defining the path (0 is all the way left, 1 is
%   all the way right)
%   path    the path in cartesian coordinates
    path = track(:,:,1).*(1-t) + track(:,:,2).*t;
end