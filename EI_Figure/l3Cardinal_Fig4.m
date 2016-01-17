%% Train and Render on Cardinal's Image Dataset
%    The figure is used as figure 4 in EI 2016 L3 paper
%
%  HJ, VISTA TEAM, 2016

%% Initialization
% Init ISET session
ieInit;

% Init remote data toolbox parameters
rd = RdtClient('scien');
rd.crp('/L3/Cardinal/D600');

% Init camera parameters
cfa = [2 1; 3 4];  % Bayer pattern, 2 and 4 are both for green
patch_sz = [5 5];
pad_sz   = (patch_sz - 1) / 2;

%% Load a pair of raw and rendered file
% search for remote path of rendered file
% fileName = 'Pl_KaladanRiver_Rakhine_0818'; vertical image
% fileName = 'edl_lakeinle_0850';  % training file name
fileName = 'ma_griz_39558';
rdTif = rd.searchArtifacts([fileName '_dxo_nodist'], 'type', 'tif');

% load image
localFile = [tempname '.tif'];
rdtSave(localFile, rdTif(1).url);

tif = im2double(imread(localFile));
if isodd(size(tif, 1)), tif = tif(1:end-1, :, :); end
if isodd(size(tif, 2)), tif = tif(:, 1:end-1, :); end

sz = [size(tif, 1) size(tif, 2)];

% Offset for Cardinal, D600
if sz(1) > sz(2) % vertical
    offset = [24 1];
else % horizontal
    offset = [1 -23];
end

% clean up
delete(localFile);

% search for remote path of raw file
rdRaw = rd.searchArtifacts(fileName, 'type', 'pgm');

% load raw data
localFile = [tempname '.pgm'];
rdtSave(localFile, rdRaw(1).url);

I_raw = im2double(imread(localFile));
I_raw = rawAdjustSize(I_raw, sz, pad_sz, offset);

% clean up
delete(localFile);

%% Build l3Data class
l3d = l3DataCamera({I_raw}, {tif}, cfa);

%% Learn l3 kernels
l3t = l3TrainOLS();
l3t.l3c.patchSize = patch_sz;
l3t.l3c.cutPoints = {logspace(-3.8, -1.5, 60), []};

% learn linear filters
l3t.train(l3d);

%% Render the training image
% Render
l3r = l3Render();
l3_RGB = ieClip(l3r.render(I_raw, cfa, l3t), 0, 1);
vcNewGraphWin([], 'wide');
subplot(1, 2, 1); imshow(tif); title('Nikon D600');
subplot(1, 2, 2); imshow(l3_RGB); title('L3 Rendered');

%% Comptue S-CIELAB difference
% Init parameters
d = displayCreate('LCD-Apple');
d = displaySet(d, 'gamma', 'linear');  % use a linear gamma table
d = displaySet(d, 'viewing distance', 1);
rgb2xyz = displayGet(d, 'rgb2xyz');
wp = displayGet(d, 'white xyz'); % white point
params = scParams;
params.sampPerDeg = displayGet(d, 'dots per deg');

% Compute difference
xyz1 = imageLinearTransform(l3_RGB, rgb2xyz);
xyz2 = imageLinearTransform(tif, rgb2xyz);
de = scielab(xyz1, xyz2, wp, params);
vcNewGraphWin; imagesc(de, [0 7]); axis image; axis off; colorbar;
vcNewGraphWin; hist(de(:), 100);
fprintf('Mean S-CIELab DeltaE is: %.3f\n', mean(de(:)));
fprintf('Std of S-CIELab DeltaE is: %.3f\n', std(de(:)));

%% Testing on another image
%  Load testing file
fileName = 'ma_mountaingorillas_0510';  % test file name
rdTif = rd.searchArtifacts([fileName '_dxo_nodist'], 'type', 'tif');

% load image
localFile = [tempname '.tif'];
rdtSave(localFile, rdTif(1).url);

tif = im2double(imread(localFile));
if isodd(size(tif, 1)), tif = tif(1:end-1, :, :); end
if isodd(size(tif, 2)), tif = tif(:, 1:end-1, :); end
sz = [size(tif, 1) size(tif, 2)];

% Offset for Cardinal, D600
if sz(1) > sz(2) % vertical
    offset = [24 1];
else % horizontal
    offset = [1 -23];
end

% clean up
delete(localFile);

% search for remote path of raw file
rdRaw = rd.searchArtifacts(fileName, 'type', 'pgm');

% load raw data
localFile = [tempname '.pgm'];
rdtSave(localFile, rdRaw(1).url);

I_raw = im2double(imread(localFile));
I_raw = rawAdjustSize(I_raw, sz, pad_sz, offset);

% clean up
delete(localFile);

% Render on file
l3r = l3Render();
l3_RGB = l3r.render(I_raw(2:end-1, 2:end-1), cfa, l3t);

% illuminant correction
tif = tif(2:end-1, 2:end-1, :);
[l3_XW, r, c] = RGB2XWFormat(l3_RGB);
m = pinv(l3_XW) * RGB2XWFormat(tif);
l3_RGB_corrected = ieClip(XW2RGBFormat(l3_XW * m, r, c), 0 , 1);

vcNewGraphWin([], 'wide');
subplot(1, 2, 1); imshow(tif); title('Nikon D600');
subplot(1, 2, 2); imshow(l3_RGB_corrected); title('L3 Rendered');

%% Comptue S-CIELAB difference
% Init parameters
d = displayCreate('LCD-Apple');
d = displaySet(d, 'gamma', 'linear');  % use a linear gamma table
d = displaySet(d, 'viewing distance', 1);
rgb2xyz = displayGet(d, 'rgb2xyz');
wp = displayGet(d, 'white xyz'); % white point
params = scParams;
params.sampPerDeg = displayGet(d, 'dots per deg');

% Compute difference
xyz1 = imageLinearTransform(l3_RGB_corrected, rgb2xyz);
xyz2 = imageLinearTransform(tif, rgb2xyz);
de = scielab(xyz1, xyz2, wp, params);
vcNewGraphWin; imagesc(de, [0 7]); axis image; axis off; colorbar;
vcNewGraphWin; hist(de(:), 100);
fprintf('Mean S-CIELab DeltaE is: %.3f\n', mean(de(:)));
fprintf('Std of S-CIELab DeltaE is: %.3f\n', std(de(:)));

%% Test on more images
s = rd.searchArtifacts('_dxo_nodist');
de = zeros(length(s), 1);
offset = [1 -23]; l3r = l3Render();

for ii = 1 : length(s)
    
    % load image
    localFile = [tempname '.tif'];
    rdtSave(localFile, s(ii).url);
    
    tif = im2double(imread(localFile));
    if size(tif, 1) > size(tif, 2), continue; end
    if isodd(size(tif, 1)), tif = tif(1:end-1, :, :); end
    if isodd(size(tif, 2)), tif = tif(:, 1:end-1, :); end
    delete(localFile);
    
    % search for remote path of raw file
    fileName = s(ii).artifactId(1:end-11);
    rdRaw = rd.searchArtifacts(fileName, 'type', 'pgm');
    
    % load raw data
    localFile = [tempname '.pgm'];
    rdtSave(localFile, rdRaw(1).url);
    
    I_raw = im2double(imread(localFile));
    sz = [size(tif, 1) size(tif, 2)];
    I_raw = rawAdjustSize(I_raw, sz, pad_sz, offset);
    delete(localFile);
    
    % Render on file
    l3_RGB = l3r.render(I_raw, cfa, l3t);
    [l3_XW, r, c] = RGB2XWFormat(l3_RGB);
    m = pinv(l3_XW) * RGB2XWFormat(tif);
    l3_RGB_corrected = ieClip(XW2RGBFormat(l3_XW * m, r, c), 0 , 1);
    
    xyz1 = imageLinearTransform(l3_RGB_corrected, rgb2xyz);
    xyz2 = imageLinearTransform(tif, rgb2xyz);
    deImg = scielab(xyz1, xyz2, wp, params);
    de(ii) = mean(deImg(:));
end