%% Video of number of luminance level classes

% Init ISET SESSION
ieInit;

%%
rd = RdtClient('scien');
% rd.credentialsDialog;
rd.crp('/L3/Farrell/D200/garden');

%% This is not working well.  

% There are artifacts in garden that are not returned.  BH is going to help
% figure this out for us, I hope.
% Consider dsc_0767, dsc_0768, dsc_0769
% 
% Also, of the ones that are returned a number fail to return jpg files
badJPGList = [ 6    11    19    23    25    29];

%% Test repeatability of artifact listing
s = rd.listArtifacts;
fprintf('Found %d artifacts\n',length(s))

%%
% In the mean time, here is a way to find some of the artifacts.  Look at
% the list (s) and choose some that are in there.
s(29).artifactId
imgTrainId = 'dsc_0781';
imgTestId  = 'dsc_0802';

% idxTrain = [];
% for ii=1:length(s)
%     if ~isempty(strfind(imgTrainId,s(ii).artifactId))
%         idxTrain = ii;
%         break;
%     end
% end
% idxTrain
% 
% idxTest = [];
% for ii=1:length(s)
%     if ~isempty(strfind(imgTestId,s(ii).artifactId))
%         idxTest = ii;
%         break;
%     end
% end
% idxTest

for ii=1:length(s)
    imgTrain = double(rd.readArtifact(s(ii).artifactId,'type','jpg'));
    vcNewGraphWin; imagescRGB(imgTrain);
    title(sprintf('artifact %d',ii));
end

imgTest = double(rd.readArtifact(imgTestId,'type','jpg'));
vcNewGraphWin; imagescRGB(imgTest);
vcNewGraphWin; imagescRGB(imgTrain);





%% Init parameters
imN = 9;

% These are the crops for image 9 (flower)
crop1 = round([2422.5 1717.5 1290 875]);  % Lower right two flowers
crop2 = round([1093.5 676.5 1467 963]);   % Central flower region

cfa = [2 1; 3 4]; % Bayer pattern, 2 and 4 are both for green
patch_sz = [5 5];
pad_sz   = (patch_sz - 1) / 2;
offset = [1 2];  % offset between raw and jpg images for Nikon cameras
   
% Init training data parameters
base = 'http://scarlet.stanford.edu/validation/SCIEN/L3/nikond200/';

% Training & Rendering for each class
s = lsScarlet([base 'JPG'], '.JPG');

%% Train on one file
trainFile = 3;  % dsc_0769; dsc_0783

% load raw and jpg image
img_name = s(trainFile).name(1:end-4);
[I_raw, jpg] = loadScarletNikon(img_name, true, pad_sz, offset);
% vcNewGraphWin; imshow(jpg)

% build l3Data class
% raw and jpg are cell arrays of 4 images by default

% [raw, jpg] = cutImages(I_raw, jpg, [size(jpg, 1) size(jpg, 2)]/2);
raw = {I_raw}; jpg = {jpg};
l3d = l3DataCamera(raw(1), jpg(1), cfa);

testFile = 8;   % dsc_0780; % 9 is 0783, the one with flowers
l3r = l3Render();
img_name = s(testFile).name(1:end-4);
[I_rawTest, jpgTest] = loadScarletNikon(img_name, true, pad_sz, offset);

%% Choose crop region
vcNewGraphWin;
imshow(imrotate(jpgTest,90));
[d, crop1] = imcrop;
crop1 = round(crop1);
[d, crop2] = imcrop;
crop2 = round(crop2);

%% Init training class

%  Choose one
crop = crop1;
v = VideoWriter('l3LumLevelsC1.avi');
%v = VideoWriter('l3LumLevelsC2.avi');

v.FrameRate = 2;
open(v);
vcNewGraphWin;

% Set different luminance levels
nLevels = 10;
levels = round(logspace(log10(4),log10(40),nLevels));
for ii=1:nLevels
    l3t = l3TrainOLS();
    l3t.l3c.patchSize = patch_sz;
    l3t.l3c.cutPoints = {logspace(-3.8, -1.5, levels(ii)), []};
    
    % learn linear filters
    l3t.train(l3d);

    % Render the image, crop a region
    l3_RGB = l3r.render(I_rawTest, cfa, l3t);
    l3_RGB = imrotate(l3_RGB,90);
    im = imcrop(l3_RGB,crop);
    imshow(im); drawnow;
    str = sprintf('N Levels %d',levels(ii));
    t = text(30,30,str,'Color',[1 1 1],'FontSize',28);
    writeVideo(v,getframe);
end
close(v)

imwrite(imcrop(imrotate(jpgTest,90),crop),'NikonCrop1.jpg');
vcNewGraphWin; imshow(imcrop(imrotate(jpgTest,90),crop));

%% Allow for illuminant correction 3x3 difference

[l3_XW,r,c] = RGB2XWFormat(im);
[jpgTest_XW,r,c] = RGB2XWFormat(imcrop(jpgTest,crop));

% jpgTest = l3_XW*T
% T = pinv(l3_XW)*jpgTest;
illT = l3_XW\jpgTest_XW;

% tmp = l3_XW*illT; tmp = tmp(:); bar = jpgTest_XW(:);
% vcNewGraphWin; plot(tmp(1:100:end),bar(1:100:end),'o');  grid on; identityLine; 
% tmp = l3_XW; tmp = tmp(:);
% plot(tmp(1:100:end),bar(1:100:end),'o');  grid on; identityLine; 
% axis equal
% ieHistImage([tmp(1:100:end),bar(1:100:end)]);  % Maybe a bug in this one

% imCC = XW2RGBFormat(l3_XW*illT,r,c);
% vcNewGraphWin; imshow(imCC);

%% Interpolate empty kernels
l3t.fillEmptyKernels;
l3_RGB = l3r.render(I_rawTest, cfa, l3t);
im = imcrop(l3_RGB,crop);
imshow(im); title('Interpolated')

%%
l3t.symmetricKernels;
l3_RGB = l3r.render(I_rawTest, cfa, l3t);
im = imcrop(l3_RGB,crop);
imshow(im); title('Symmetric');

%%

