%% Test images
%
% We make some simple test images and render them using the l3tNikon table.
%


%% This is how we could load, but we don't need to for this script

% cfa      = [2 1; 3 4]; % Bayer pattern, 2 and 4 are both for green
% G R
% B G
%
% patch_sz = [5 5];
% pad_sz   = (patch_sz - 1) / 2;
% offset   = [1 2];
% 
% base = 'http://scarlet.stanford.edu/validation/SCIEN/L3/nikond200/';
% 
% % Save the training data
% outDir = fullfile(l3rRootPath,'local','trainQuarter');
% s = lsScarlet([base 'JPG'], '.JPG');
% jj = 1;
% img_name = s(jj).name(1:end-4);
% [I_raw, jpg] = loadScarletNikon(img_name, true, pad_sz, offset);
% size(I_raw)
% max(I_raw(:))


%% Load the Nikon table

% Loading the TrainOLS structure for the D200
fname = fullfile(l3rRootPath, 'local','trainQuarter','l3tNikon.mat');
if exist(fname,'file'), load(fname); 
else error('File not found');
end

%% Initialize a dummy image
rSize = [2596 , 3876];
mx = 0.0625;
tImage = zeros(64,64);

[r,c] = size(tImage);

%% Make an image  
space = 8;
% tImage = ones(size(tImage))*0.05*mx;
% tImage(1:space:r,1:space:c) = 0.8*mx;  % Green
% tImage(2:space:r,1:space:c) = 0.3*mx;  % Blue
% tImage(1:space:r,2:space:c) = 0.3*mx;  % Red
% tImage(2:space:r,2:space:c) = 0.8*mx;  % Green

tImage = ones(64,64)*0.5*mx;
tImage(1:space:r,1:space:c) = 0.1*mx;  % Green
tImage(2:space:r,1:space:c) = 0.1*mx;  % Blue
tImage(1:space:r,2:space:c) = 0.1*mx;  % Red
tImage(2:space:r,2:space:c) = 0.1*mx;  % Green

%%  Here is one observation

% When we put in a lot of single points, and one is brighter than the
% other, then the system always makes the point larger white, and the
% surrounding points get a little bit of the color of the selected pixel.
% 
l3r = l3Render();
useMex = true;       % Only used for the case of linear kernel regression
l3_RGB = l3r.render(tImage, cfa, l3t, useMex);

vcNewGraphWin; imagesc(tImage); colormap(gray);
imtool(l3_RGB);

%%
