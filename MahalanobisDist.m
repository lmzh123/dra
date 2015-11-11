function [ Mahalanobis ] = MahalanobisDist( X, Mu, Sigma2, K )
%MAHALANOBISD Summary of this function goes here
%   Detailed explanation goes here
d = 3;
Mahalanobis = zeros(size(Mu));

for i=1:K
    Mahalanobis(:, :, (i*d)-(d-1):(i*d)) = abs((X-Mu(:,:,(i*d)-(d-1):(i*d)))./repmat(Sigma2(:, :, i), 1, 1, 3));
end

end

