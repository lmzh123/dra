%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% VISUAL TRACKING
% ----------------------
% Background Subtraction
% ----------------
% Date: september 2015
% Authors: Desire Sidibe
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ImSeq, NumImages, VIDEO_HEIGHT, VIDEO_WIDTH, VIDEO_DEPTH] = loadSequenceRGB(sequence, ext)
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

VIDEO_WIDTH = size(I,2);
VIDEO_HEIGHT = size(I,1);
VIDEO_DEPTH = size(I,3);

ImSeq = zeros(VIDEO_HEIGHT, VIDEO_WIDTH, VIDEO_DEPTH);
for i=1:NumImages
    imgname = [imPath filesep filearray(i).name]; % get image name
    ImSeq(:,:,(i*VIDEO_DEPTH)-(VIDEO_DEPTH-1):(i*VIDEO_DEPTH)) = imread(imgname); %Load Image
end
disp(' ... OK!');

end
