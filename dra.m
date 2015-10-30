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
[ImSeq, NumImages, VIDEO_HEIGHT, VIDEO_WIDTH] = loadSequence('highway/input', 'jpg');

n = 10; %Number of images taken into account for the BG
T = 25; %Threshold
se1 = strel('disk',3);   %Disk for dilation
se2 = strel('disk',5);   %Disk for erosion
results = zeros(size(ImSeq));   %To save all the obtained objects

for i=470+1:NumImages
    I = ImSeq(:,:,i-n:i-1);
    B = median(I, 3);   %Background Image
    currentImage = ImSeq(:,:,i);
    D = abs(currentImage - B);
    object = D > T;
    
    %Morphological operators
    object = imdilate(object,se1);
    object = imerode(object,se2);
    object = imfill(object,'holes');
    results(:,:,i) = object;
    
    %Measuring the region properties
    objectLabeled = bwlabel(object, 8);
    s = regionprops(uint8(objectLabeled),'centroid', 'Area', 'BoundingBox');
    centroids = cat(1, s.Centroid);
    [maxValue,index] = max([s.Area]);
    
    %Showing
    subplot(1,4,1); imshow(currentImage,[]); title('Current Image');
    if size(centroids,1) ~= 0
        hold on; plot(centroids(index,1),centroids(index,2), 'b*'); rectangle('Position', s(index).BoundingBox); hold off;
    end
    
    subplot(1,4,2); imshow(B,[]); title('Background');
    subplot(1,4,3); imshow(D,[]); title('Difference');
    subplot(1,4,4); imshow(object,[]); title('Threshold');
    pause(0.1)
end

%Saving the resulting objects for each frame
save('frameDifferencing.mat','results');
