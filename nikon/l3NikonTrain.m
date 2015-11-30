%% l3NikonTrain
%
% Train on the Nikon images
%
% (HJ/BW) VISTA TEAM, 2015

ieInit;

%% Init parameters

% These are the Nikon image training parameters
cfa      = [2 1; 3 4]; % Bayer pattern, 2 and 4 are both for green
patch_sz = [5 5];
pad_sz   = (patch_sz - 1) / 2;
offset   = [1 2];

% These are the raw images, I think.
base = 'http://scarlet.stanford.edu/validation/SCIEN/L3/nikond200/';

% Save the training data
outDir = fullfile(l3rRootPath,'local','trainQuarter');
s = lsScarlet([base 'JPG'], '.JPG');

%% Train the images 

% Initialize object for training with ordinary least squares, and set
% training parameters 
l3t = l3TrainOLS();
l3t.l3c = l3ClassifyFast;       % This should become the default classifier
l3t.l3c.patchSize = patch_sz;
l3t.l3c.cutPoints = {logspace(-4, -1.2, 60), 1/16};

% Train on the data from a subset of the images
% We can try this in various ways (half/half) or leave 10% out or whatever
% In this case, it is 1/4 of 30 images
for jj = 1 : 4 : length(s)
    % print info
    fprintf('Collecting data from Image: %s\n', s(jj).name);
    
    % load raw and jpg image with this name
    img_name = s(jj).name(1:end-4);
    [I_raw, jpg] = loadScarletNikon(img_name, true, pad_sz, offset);
    
    % build l3Data class with these data
    fprintf('Cutting the image and assigning to data structure\n');
    [raw, jpg] = cutImages(I_raw, jpg, [size(jpg, 1) size(jpg, 2)]/2);
    l3d = l3DataCamera(raw, jpg, cfa);
    
    % add the classified data
    fprintf('Adding the data to the classify structure\n');
    l3t.l3c.classify(l3d);
    
    if jj == 1
        fprintf('Rendering the first raw data with the trained kernels.\n');
        
        % learn linear filters
        fprintf('Training for first image only.\n');
        l3t.train();

        % Create the render object
        l3r = l3Render();
        l3_RGB = l3r.render(I_raw, cfa, l3t);
        
        imshow(l3_RGB); drawnow;
    end
    
end

% learn linear filters
fprintf('Training\n');
l3t.train();

% save trained kernels
fprintf('Saving the trained kernels');
fname = fullfile(outDir,'l3tNikon.mat');
l3t.save(fname);

%% Show that the first one still renders after the multiple image training

% If you are just loading the TrainOLS structure
fname = fullfile(l3rRootPath, 'local','trainQuarter','l3tNikon.mat');
exist(fname,'file')
load(fname)

jj = 27;             % jj = 27 is a good one
img_name = s(jj).name(1:end-4);
I_raw = loadScarletNikon(img_name, true, pad_sz, offset);

% Create the render object
l3r = l3Render();
useMex = true;       % Only used for the case of linear kernel regression
l3_RGB = l3r.render(I_raw, cfa, l3t, useMex);
vcNewGraphWin; imshow(l3_RGB);
% vcNewGraphWin; imshow((I_raw/max(I_raw(:))));

imwrite((I_raw/max(I_raw(:))),'raw.jpg','jpg');
imwrite(l3_RGB,'tmp.jpg','jpg');

%% Render images that were not trained
l3r = l3Render();

for jj = 2 : 2 : length(s)
    % print info
    cprintf('*Keywords', 'Rendering on Image: %s\n', s(jj).name);
    
    % load raw and jpg image
    img_name = s(jj).name(1:end-4);
    [I_raw, ~] = loadScarletNikon(img_name, true, pad_sz);
    
    l3_RGB = l3r.render(I_raw, cfa, l3t);
    
    % save l3 rendered RGB image
    imwrite(l3_RGB, [outDir img_name '.JPG']);
end

%% Render individual images by hand

% Create the render object
l3r = l3Render();

% Pick an image number
jj = 1;

% load raw and jpg image
img_name = s(jj).name(1:end-4);

% Load and use the trained table to render
fprintf('Reading remote data %s\n',img_name);
[I_raw, jpg] = loadScarletNikon(img_name, true, pad_sz, offset);

fprintf('Rendering the raw data with the trained kernels.\n');
l3_RGB = l3r.render(I_raw, cfa, l3t);

imshow(l3_RGB);

% Save the data as a JPG file
% imwrite(l3_RGB, [outDir img_name '.JPG']);

%% Visualize the Nikon kernels
classID = 1; channel = 1;
l3t.plot('kernel movie',classID,channel)


%% Training & Rendering all the images, but one image at a time.

% Location of the files to read and place to store
outDir = fullfile(l3rRootPath,'local');

% This only demonstrates that we can find a linear transformation for the
% classes we defined for this image.

% list files in folder, should change to rdata once we fix problem
% there


%% 
