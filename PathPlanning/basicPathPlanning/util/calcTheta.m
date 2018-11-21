function [theta,dtheta] = calcTheta(dpath)
%calcTheta for use in calculating cornering losses
%   a bit icky due to theta wraparound

    % theta calculation
    theta = atan2(dpath(:,2),dpath(:,1));
    dtheta = diff(theta);
    cors = find(abs(dtheta)>pi);
    for cor = cors'
        theta(cor+1:end) = theta(cor+1:end) - 2*pi*sign(dtheta(cor));
    end
    dtheta = gradient(theta);
    if ~(all(abs(dtheta) < pi/2))
        figure(5); clf;
        plot(theta);hold on;plot(dtheta);
        drawnow();
    end
    assert(all(abs(dtheta) < pi/2)); % if this fails, it means there was a theta discontinuity
    
end

