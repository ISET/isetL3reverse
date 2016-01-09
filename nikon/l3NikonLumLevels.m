%% Video of number of luminance level classes
%
% 

%% Init ISET SESSION
ieInit;

%%  Point to a data set on the archiva server
rd = RdtClient('scien');
rd.crp('/L3/Farrell/D200/garden');

%% Test repeatability of artifact listing

% There are 39 files up there
s = rd.listArtifacts;
fprintf('Found %d artifacts\n',length(s))

%%
% imN = 9;

% These are the crops for image 9 (flower)
crop1 = round([2422.5 1717.5 1290 875]);  % Lower right two flowers
crop2 = round([1093.5 676.5 1467 963]);   % Central flower region

cfa = [2 1; 3 4]; % Bayer pattern, 2 and 4 are both for green
patch_sz = [5 5];
pad_sz   = (patch_sz - 1) / 2;
offset = [1 2];  % offset between raw and jpg images for Nikon cameras

%% Get a corresponding JPG and PGM file

% The files in Archiva should be adjusted so we don't need to run
% rawAdjustSize
% This should simplify even more after working with BH.  We will be able to
% use rd.readData(artifact) instead of the rdtSave and so forth.
train = rd.searchArtifacts('dsc_0780');
[p, n, ~] = fileparts(train.url);
rdtSave('train.jpg',fullfile(p,[n,'.jpg']));
jpg   = im2double(imread('train.jpg'));
sz = [size(jpg, 1) size(jpg, 2)];

rdtSave('train.pgm',fullfile(p,[n,'.pgm']));
I_raw = im2double(imread('train.pgm'));
I_raw = rawAdjustSize(I_raw, sz, pad_sz, offset);
% hist(double(I_raw(:)),100)

vcNewGraphWin; imagesc(jpg);
vcNewGraphWin; imagesc(I_raw .^ 0.3); colormap(gray)
% size(I_raw); size(jpg)

%% Init parameters
% build l3Data class
% raw and jpg are cell arrays of 4 images by default

%[I_raw, jpg] = cutImages(I_raw, jpg, sz/2);
raw = {I_raw}; jpg = {jpg};
l3d = l3DataCamera(raw(1), jpg(1), cfa);

%% Get the test image
% testFile = 'dsc_0792';  % Forrest scene with red bush
% testFile = 'dsc_0784';  % Red flower depth of field, needs a lot
% testFile = 'dsc_0799';  % Nice red flowers house corner
testFile = 'dsc_0806';  % Buddha in stone
% testFile = 'dsc_0813';  % Trisha and Rosemary, need dcraw

test = rd.searchArtifacts(testFile);
[p,n,e] = fileparts(test.url);
rdtSave('test.jpg',fullfile(p,[n '.jpg']));
rdtSave('test.pgm',fullfile(p,[n '.pgm']));

I_rawTest = im2double(imread('test.pgm'));
jpgTest   = im2double(imread('test.jpg'));
I_rawTest = rawAdjustSize(I_rawTest, sz, pad_sz, offset);

% vcNewGraphWin; imagesc(jpgTest);
% vcNewGraphWin; imagesc(I_rawTest .^0.3);colormap(gray)

%%
l3r = l3Render();


%% Choose crop region
% vcNewGraphWin;
% imshow(imrotate(uint8(jpgTest),90));
% [d, crop1] = imcrop;
% crop1 = round(crop1);
% [d, crop2] = imcrop;
% crop2 = round(crop2);

%% Init training class
% Make a video that shows how the filters change with the luminance level.

%  Choose one crop region
crop = crop1;

% Set up the movie to write
v = VideoWriter(sprintf('l3LumLevels-%s.avi',testFile));

% For another version
%v = VideoWriter('l3LumLevelsC2.avi');

% Movie parameters
v.FrameRate = 2;
open(v);

% Open the window
vcNewGraphWin;

% Set the number of luminance levels
nLevels = 2;

% These are the levels, in this case nLevels spaced logarithmically
levels = round(logspace(log10(4),log10(40),nLevels));
for ii=1:nLevels
    l3t = l3TrainOLS();
    l3t.l3c.patchSize = patch_sz;
    l3t.l3c.cutPoints = {logspace(-3.8, -1.5, levels(ii)), []};
    
    % learn linear filters
    l3t.train(l3d);

    % Render the image, crop a region
    l3_RGB = l3r.render(I_rawTest, cfa, l3t);
    imshow(l3_RGB); drawnow;

    %     l3_RGB = imrotate(l3_RGB,90);
    %     im = imcrop(l3_RGB,crop);
    %     imshow(im); drawnow;
    
    str = sprintf('N Levels %d',levels(ii));
    t = text(30,30,str,'Color',[1 1 1],'FontSize',28);
    writeVideo(v,getframe);
end
close(v)

% imwrite(imcrop(imrotate(jpgTest,90),crop),'NikonCrop1.jpg');
% vcNewGraphWin; imshow(imcrop(imrotate(jpgTest,90),crop));

%% Allow for illuminant correction 3x3 difference

[l3_XW,r,c] = RGB2XWFormat(l3_RGB);
jpgTest_XW = RGB2XWFormat(jpgTest);

% Compute the linear transform between the jpg and the l3 rendering
% jpgTest = l3_XW*T
% T = pinv(l3_XW)*jpgTest;
illT = l3_XW\jpgTest_XW;
imCC = XW2RGBFormat(l3_XW*illT,r,c);
imCC = ieClip(imCC,0,1);

% No illuminant correction
vcNewGraphWin; 
plot(l3_RGB(1:100:end),jpgTest(1:100:end),'o');  grid on; identityLine;
ieHistImage(cat(1,l3_RGB(1:100:end),jpgTest(1:100:end))');   % There is a bug here!
axis equal; grid on; identityLine; 
title('No illuminant correction');
xlabel('L3'); ylabel('jpg');

% Illuminant correction
vcNewGraphWin; 
plot(imCC(1:100:end),jpgTest(1:100:end),'o');  grid on; identityLine;
ieHistImage(cat(1,imCC(1:100:end),jpgTest(1:100:end))'); % Function is broken.
axis equal; grid on; identityLine; 
title('Illuminant correction');
xlabel('imCC'); ylabel('jpgTest')

%%
vcNewGraphWin; imshow(imCC);
vcNewGraphWin; imshow(jpgTest);

%% Interpolate empty kernels
l3t.fillEmptyKernels;
l3_RGB = l3r.render(I_rawTest, cfa, l3t);

imshow(l3_RGB); title('Interpolated');
% im = imcrop(l3_RGB,crop);
% imshow(im); title('Interpolated')

%% For symmetry where possible on the kernels
l3t.symmetricKernels;
l3_RGB = l3r.render(I_rawTest, cfa, l3t);
imshow(l3_RGB); title('Interpolated and Symmetric');

% im = imcrop(l3_RGB,crop);
% imshow(im); title('Symmetric');

%% Analyze kernel dimensionality

%%

