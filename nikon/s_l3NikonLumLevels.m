%% Illustrate the effect of the number of luminance levels
%  In this scirpt, we train on one image captured by Nikon D200 camera and
%  tested on another image under the same camera settings (lens, exposure).
%
%  The pixels are classified only by the luminance and the pixel type. We
%  vary the number of luminance levels used and generate a video to
%  demonstrate its effect on image quality.
%
%  HJ/BW, VISTA TEAM, 2016

%% Init ISET SESSION
ieInit;

%% Init parameters
% Init camera and training parameter
cfa = [2 1; 3 4]; % Bayer pattern, 2 and 4 are both for green
patch_sz = [5 5];

% Init remote data toolbox
rd = RdtClient('scien');
rd.crp('/L3/Farrell/D200/garden');

%% Load training and testing image
% list all image artifacts
s = rd.listArtifacts;

% load training image
trainFile = 'dsc_0784';   % Flower image
train_rgb = im2double(rd.readArtifact(trainFile, 'type', 'jpg'));
train_raw = im2double(rd.readArtifact(trainFile, 'type', 'pgm'));
% vcNewGraphWin; imshow(jpgImage);
% vcNewGraphWin; imagesc(pgmImage); colormap(gray)

% load test image
% testFile = 'dsc_0792';  % Forrest scene with red bush
% testFile = 'dsc_0784';  % Red flower depth of field, needs a lot
% testFile = 'dsc_0799';  % Nice red flowers house corner
% testFile = 'dsc_0806';  % Buddha in stone
% testFile = 'dsc_0813';  % Trisha and Rosemary, need dcraw
testFile = 'dsc_0799';
test_rgb = im2double(rd.readArtifact(testFile, 'type', 'jpg'));
test_raw = im2double(rd.readArtifact(testFile, 'type', 'pgm'));

%% Make a video of l3 rendered images with different luminance levels
% Set up movie parameters
v = VideoWriter(sprintf('l3LumLevels-%s-%s.avi', trainFile, testFile));
v.FrameRate = 2;
open(v);

% These are the levels, in this case nLevels spaced logarithmically
% Typically from 4 to 80 levels
nLevels = 12;
levels = round(logspace(log10(4),log10(80),nLevels));

% Build l3 data and render class
l3d = l3DataCamera({train_raw}, {train_rgb}, cfa);
l3r = l3Render();

% Train using different luminance levels and render the test image
for ii = 1 : nLevels
    l3t = l3TrainOLS();
    l3t.l3c.patchSize = patch_sz;
    l3t.l3c.cutPoints = {logspace(-3.8, -1.5, levels(ii)), []};
    
    % learn linear filters
    l3t.train(l3d);

    % Render the image
    l3_RGB = ieClip(l3r.render(test_raw, cfa, l3t), 0, 1);
    str = sprintf('N Levels %d',levels(ii));
    rgb = insertText(l3_RGB, [100 100], str, ...
            'TextColor', 'white', 'FontSize', 48);
    writeVideo(v, rgb);
end
close(v)
