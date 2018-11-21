function [dA] = gradient_gerry(A)
%gradient_gerry reimplementation of the gradient built-in function
%   I wanted to try this to see if it would help mitigate the oscillations
%   but it didn't work.  The reason I thought it might help is because the
%   matlab gradient function does a center-point style dervative which
%   means 3 points contribute to the derivative instead of just one which I
%   thought could potentially cause numerical issues.  Alas, it was not so.
    dA = zeros(size(A));
    if (size(A,2)>1)
        dA(:,1:size(A,2)-1) = diff(A,1,2);
        dA(:,size(A,2)) = dA(:,size(A,2)-1);
    else
        dA(1:size(A,1)-1) = diff(A);
        dA(size(A,1)) = dA(size(A,1)-1);
    end
end

