%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% VISUAL TRACKING
% ----------------------
% Background Subtraction with Average Gaussian
% ----------------
% Date: 5 October 2015
% Authors: Luis Miguel ZAPATA HENAO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc; close all; clear all;

%Loads the desired sequence
[ImSeq, NumImages, VIDEO_HEIGHT, VIDEO_WIDTH, VIDEO_DEPTH] = loadSequenceRGB('shop', 'jpg');

n = 10; %Number of images taken into account for the BG
T = 25; %Threshold
K = 3; % Number of Gaussians

ImSeq = ImSeq./255;

Mu = rand(VIDEO_HEIGHT, VIDEO_WIDTH, VIDEO_DEPTH*K);
Sigma2 = (0.01)*ones(VIDEO_HEIGHT, VIDEO_WIDTH, K);
W = ones(VIDEO_HEIGHT, VIDEO_WIDTH, K)/K;

figure;
for i=1:1
    I = ImSeq(:,:,(i*VIDEO_DEPTH)-(VIDEO_DEPTH-1):(i*VIDEO_DEPTH));
    %P = computePosterior( Mu, Sigma2, W, I, K );
    Mahalanobis = MahalanobisDist(I, Mu, Sigma2, K);
    Mahalanobis
    SSS = sum(sum(sum(Mahalanobis>2.5)))
    numel(Mahalanobis)
    pause(0.5);
end

% se1 = strel('disk',3);   %Disk for dilation
% se2 = strel('disk',5);   %Disk for erosion
% results = zeros(size(ImSeq));   %To save all the obtained objects
% 
% for i=n+1:NumImages
%     I = ImSeq(:,:,i-n:i-1);
%     B = mean(I, 3);   %Background Image
%     currentImage = ImSeq(:,:,i);
%     D = abs(currentImage - B);
%     object = D > T;
%     
%     %Morphological operators
%     object = imdilate(object,se1);
%     object = imerode(object,se2);
%     object = imfill(object,'holes');
%     results(:,:,i) = object;
%     
%     %Measuring the region properties
%     objectLabeled = bwlabel(object, 8);
%     s = regionprops(uint8(objectLabeled),'centroid', 'Area', 'BoundingBox');
%     centroids = cat(1, s.Centroid);
%     [maxValue,index] = max([s.Area]);
%     
%     %Showing
%     subplot(1,4,1); imshow(currentImage,[]); title('Current Image');
%     if size(centroids,1) ~= 0
%         hold on; plot(centroids(index,1),centroids(index,2), 'b*'); rectangle('Position', s(index).BoundingBox); hold off;
%     end
%     
%     subplot(1,4,2); imshow(B,[]); title('Background');
%     subplot(1,4,3); imshow(D,[]); title('Difference');
%     subplot(1,4,4); imshow(object,[]); title('Threshold');
%     pause(0.1)
% end

%Saving the resulting objects for each frame
%save('frameDifferencing.mat','results');
