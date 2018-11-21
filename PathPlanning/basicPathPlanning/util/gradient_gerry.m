function [dA] = gradient_gerry(A)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
    dA = zeros(size(A));
    if (size(A,2)>1)
        dA(:,1:size(A,2)-1) = diff(A,1,2);
        dA(:,size(A,2)) = dA(:,size(A,2)-1);
    else
        dA(1:size(A,1)-1) = diff(A);
        dA(size(A,1)) = dA(size(A,1)-1);
    end
end

