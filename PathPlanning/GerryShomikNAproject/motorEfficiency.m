function [ eff ] = motorEfficiency( p,v )
%motorEfficiency - returns efficiency of motor (0,1)
%   input power,v 
    eff = (1- exp(-p/100) + 20./(p+20))*0.85; % TODO: refine this
%     eff = 0.85;

end

