function [ eff ] = motorEfficiency( p,v )
%motorEfficiency - returns efficiency of motor (0,1)
%   input power,v 
    eff = (1- exp(-p/10) + 2./(p+2))*0.85; % TODO: refine this
%     eff = 0.85;

end

