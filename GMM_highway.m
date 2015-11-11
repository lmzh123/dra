%% GMM highway

clc;
clear all;
close all;

%%
%%%%% LOAD THE IMAGES
%=======================

[ImSeq, NumImages, VIDEO_HEIGHT, VIDEO_WIDTH, VIDEO_DEPTH] = loadSequenceRGB('shop', 'jpg');


% % 2.3 Mixture of Gaussians
% % http://www.ai.mit.edu/projects/vsam/Publications/stauffer_cvpr98_track.pdf
% % http://areshmatlab.blogspot.fr/2010/05/high-complexity-background-subtraction.html
% % http://www.sagoforest.com/sagoaleph/papers/GaussianMixtureModels.pdf
% % http://en.wikipedia.org/wiki/Mixture_model#Gaussian_mixture_model
% % http://www.moivre.usherbrooke.ca/sites/default/files/108.pdf
% % http://profs.sci.univr.it/~cristanm/teaching/sar_files/lezione4/Piccardi.pdf
% % http://www.cs.utexas.edu/~grauman/courses/fall2009/slides/lecture9_background.pdf
% % http://www.cse.iitk.ac.in/users/vision/tarunb/node6.html
% % https://www.ll.mit.edu/mission/communications/ist/publications/0802_Reynolds_Biometrics-GMM.pdf
fr = ImSeq(:, :, 1);
fr_size = size(fr);
width = fr_size(2);
height = fr_size(1);

K = 3; % Numer of Gaussian distributions - generally 3 to 5

M = 1; % 1 because gray - number of background components

D = 2.5; % positive deviation threshold

alpha = 0.01; % Learning rate between 0 and 1

thresh = 0.1;

sd_init = 6; % initial standart deviation

w = zeros(height, width, K); % initialize Weights array
mean = zeros(height, width, K); % pixel means
sd = zeros(height, width, K); % pixel standart deviations
u_diff = zeros(height, width, K); % diference of each pixel from mean
p = alpha / (1 / K); % initial p variable (used to update mean and sd)
rank = zeros(1, K); % rank of components (w / sd)

foreground = zeros(height, width);
background = zeros(height, width);



% Inits
mean = 255 * rand(height, width, K);
w = (1 / K) * ones(height, width, K);
sd = sd_init * ones(height, width, K);

figure('name', 'Mixture of Gaussians', 'units', 'normalized', 'outerposition', [0 0 1 1]);

% Process
for kk = 1 : 653 % NumImages
    
    im = ImSeq(:,:,(kk*VIDEO_DEPTH)-(VIDEO_DEPTH-1):(kk*VIDEO_DEPTH));
    
    u_diff(:, :, :) = abs(im - double(mean(:, :, :)));
    
    % update gaussian components for each pixel
    for ii = 1 : height
        
        for jj = 1 : width
            
            match = 0;
            
            for nn = 1 : K
                
                if abs(u_diff(ii, jj, nn)) <= D * sd(ii, jj, nn) % pixel matches gaussian component
                    
                    match = 1; % n.th distribution matched
                    
                    % update weights, mean, sd, p
                    w(ii, jj, nn) = (1 - alpha) * w(ii, jj, nn) + alpha;
                    
                    p = alpha / w(ii, jj, nn);
                    
                    mean(ii, jj, nn) = (1 - p) * mean(ii, jj, nn) + p * double(im(ii, jj));
                    
                    sd(ii, jj, nn) = sqrt((1 - p) * (sd(ii, jj, nn) ^ 2) + p * ((double(im(ii, jj)) - mean(ii, jj, nn))) ^ 2);
                    
                else
                    
                    w(ii, jj, nn) = (1 - alpha) * w(ii, jj, nn); % weight slighly decreases
                    
                end
                
            end
            
            w(ii, jj, :) = w(ii, jj, :) ./ sum(w(ii, jj, :));
            
            background(ii, jj) = 0;
            
%             for nn = 1 : K
%                
%                 background(ii, jj) = background(ii, jj) + mean(ii, jj, nn) * w(ii, jj, nn);
%                 
%             end
            background(ii, jj) = background(ii, jj) + sum(mean(ii, jj, :) .* w(ii, jj, :));
            
            % if no components match, create new component
            if (match == 0)
                [min_w, min_w_index] = min(w(ii, jj, :));
                mean(ii, jj, min_w_index) = double(im(ii, jj));
                sd(ii, jj, min_w_index) = sd_init;
            end
            
            rank = w(ii, jj, :) ./ sd(ii, jj, :); % calculate component rank
            rank_ind = 1:1:K;
            
            % sort rank values
            for k = 2 : K
                
                for m = 1 : (k - 1)
                    
                    if (rank(:, :, k) > rank(:, :, m))
                        % swap max values
                        rank_temp = rank(:, :, m);
                        rank(:, :, m) = rank(:, :, k);
                        rank(:, :, k) = rank_temp;
                        
                        % swap max index values
                        rank_ind_temp = rank_ind(m);
                        rank_ind(m) = rank_ind(k);
                        rank_ind(k) = rank_ind_temp;
                        
                    end
                    
                end
                
            end

% % sortrows looks more slower then the for loop above :/
%             [rank, rank_ind] = sortrows(squeeze(rank), -1);
%             rank_ind = rank_ind';
            
            
            % calculate foreground
            match = 0;
            
            k = 1;
            
            foreground(ii, jj) = 0;
            
            while (match == 0) && (k <= K)
                
                if w(ii, jj, rank_ind(k)) >= thresh
                    
                    if abs(u_diff(ii, jj, rank_ind(k))) <= D * sd(ii, jj, rank_ind(k))
                        
                        foreground(ii, jj) = 0;
                        
                        match = 1;
                        
                    else
                        
                        foreground(ii, jj) = im(ii, jj); 
                        
                    end
                    
                end
                
                k = k + 1;
                
            end
            
        end
        
    end
    
    
    %subplot(1, 3, 1); imshow(im, []);
    %subplot(1, 3, 2); imshow(uint8(background), []);
    %subplot(1, 3, 3); imshow(uint8(foreground), []);
    
    %drawnow;
    
    foregroundFiltered = bwareaopen(foreground, 50, 8);
    se = strel('disk', 13);
    foregroundFiltered = imdilate(foregroundFiltered, se);
    foregroundFiltered = bwmorph(foregroundFiltered, 'bridge', 'Inf');
    
    %foregroundFiltered = medfilt2(foregroundFiltered, [5 5]);
    
    %foregroundFiltered = imfill(foregroundFiltered, 'holes');
    
    %foregroundFiltered = bwmorph(foregroundFiltered, 'erode', 5);
    
    
    
    
    %foregroundFiltered = bwmorph(foregroundFiltered, 'remove');
    %foreground = bwmorph(foreground,'skel', Inf);
    
    
    boundingBox  = regionprops(foregroundFiltered, 'BoundingBox');
    
    
    subplot(2, 2, 1); imshow(uint8(im), []); title('Raw Image');
    
    if ~isempty(boundingBox)
        for bb = 1 : numel(boundingBox)
            rectangle('Position', boundingBox(bb).BoundingBox, 'EdgeColor','r', 'LineWidth', 2);
        end
    end
    
    subplot(2, 2, 2); imshow(foreground); title('Foreground');
    subplot(2, 2, 3); imshow(foregroundFiltered); title('Foreground Filtered');
    subplot(2, 2, 4); imshow(background, []); title('Background');
    
    drawnow;
   
    display(kk);
end

