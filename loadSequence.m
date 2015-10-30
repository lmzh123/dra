%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% VISUAL TRACKING
% ----------------------
% Background Subtraction
% ----------------
% Date: september 2015
% Authors: Desire Sidibe
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ImSeq, NumImages, VIDEO_HEIGHT, VIDEO_WIDTH] = loadSequence(sequence, ext)
%%%%% LOAD THE IMAGES
%=======================

% Give image directory and extension
imPath = sequence; imExt = ext;

% check if directory and files exist
if isdir(imPath) == 0
    error('USER ERROR : The image directory does not exist');
end

filearray = dir([imPath filesep '*.' imExt]); % get all files in the directory
NumImages = size(filearray,1); % get the number of images
if NumImages < 0
    error('No image in the directory');
end

disp('Loading image files from the video sequence, please be patient...');
% Get image parameters
imgname = [imPath filesep filearray(1).name]; % get image name
I = imread(imgname); % read the 1st image and pick its size
flag = 0;
if size(I,3)>1
    I = rgb2gray(I);
    flag = 1;
end
VIDEO_WIDTH = size(I,2);
VIDEO_HEIGHT = size(I,1);

ImSeq = zeros(VIDEO_HEIGHT, VIDEO_WIDTH, NumImages);
for i=1:NumImages
    imgname = [imPath filesep filearray(i).name]; % get image name
    if flag == 1
        ImSeq(:,:,i) = rgb2gray(imread(imgname)); % load image
    else
        ImSeq(:,:,i) = imread(imgname); % load image
    end  
end
disp(' ... OK!');

end
