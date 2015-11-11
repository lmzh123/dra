function [ P ] = computePosterior( Mu, Sigma2, W, x, K )
%NORMAL Summary of this function goes here
%   Detailed explanation goes here
d = 3;
%S = Sigma2*eye(d);
P = zeros(size(Mu, 1), size(Mu, 2));


for i=1:K
    for i1 = 1:size(x, 1);
        for i2 = 1:size(x, 2);
            xMu = (x(i1, i2)-Mu(i1,i2,(i*d)-(d-1):(i*d)));
            xMu = reshape(xMu, 1, d)';
            nu = 1./((2*pi)^(d/2)*(Sigma2(i1, i2, i).^1.5))*exp( -0.5*xMu'*(1./Sigma2(i1, i2, i))*xMu   );
            nu = nu.*W(i1, i2, i);
            
            P(i1, i2) = P(i1, i2)+nu;
        end
    end
end
end

