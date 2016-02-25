%% L3 processing for underwater image processing
%
%  HJ, VISTA TEAM, 2016

%% Init
ieInit

%% Initialize parameters
cfa = [2 1; 3 4];
patch_sz = [5 5];

%% Training
%  load training images
raw = im2double(imread('~/Downloads/Img_7465.pgm'));
raw = raw(2:end, :); % make sure raw size is a multiple of cfa size
rgb = im2double(imread('~/Downloads/Img_7465_corr.png'));
rgb = rgb(2:end, :, :);

l3t = l3TrainRidge();
l3t.l3c.patchSize = patch_sz;
l3t.l3c.cutPoints = {logspace(-2.2, -1.1, 40), []};
l3t.train(l3DataCamera({raw}, {rgb}, cfa));

%% Rendering
%  first, we render on the image we trained on
l3r = l3Render();
l3_RGB = ieClip(l3r.render(raw, cfa, l3t), 0 ,1);
vcNewGraphWin; imshow(l3_RGB);

%  load test image
raw_test = im2double(imread('~/Downloads/Img_4425.pgm'));
raw_test = raw_test(2:end, :);
rgb_test = im2double(imread('~/Downloads/Img_4425_corr.png'));
rgb_test = rgb_test(2:end, :, :);

l3_RGB = ieClip(l3r.render(raw_test, cfa, l3t), 0, 1);
vcNewGraphWin; imshow(rgb_test); title('Target');
vcNewGraphWin; imshow(l3_RGB); title('L3');