%% Look up and plot some of the Nikon filters
%

% These are the Nikon image training parameters
cfa      = [2 1; 3 4]; % Bayer pattern, 2 and 4 are both for green
patch_sz = [5 5];
pad_sz   = (patch_sz - 1) / 2;
offset   = [1 2];

% If you are just loading the TrainOLS structure
fname = fullfile(l3rRootPath, 'local','trainQuarter','l3tNikon.mat');
exist(fname,'file')
load(fname)

% 2 is blue
% 1 is green
% 3 is red


%% Easy way to make an RGB cfaImage

sensor = sensorCreate;
[cfaImage,mp] = sensorImageColorArray(sensorDetermineCFA(sensor));
sz = 128;
cfaImage = cfaImage(1:5,1:5);
[X,Y] = meshgrid(1:5,1:5);
[U,V] = meshgrid(linspace(1,5,sz),linspace(1,5,sz));
cfaImage = interp2(X,Y,cfaImage,U,V,'nearest');
    
% Make the image pretty big.  If it is a human sensor, the block is
% already quite big, so we don't make it too much bigger.
% s = 192/round(size(cfaImage,1));
% 
% filterRGB = imageIncreaseImageRGBSize(cfaImage,s);
% To match the Nikon camera
% cfaImage = rot90(cfaImage);
cfaImage = ind2rgb(cfaImage,mp);
% Draw the CFA in a new figure window (true size)
hdl = vcNewGraphWin;
set(hdl,'Name', sensorGet(sensor,'name'),'menubar','None');
image(cfaImage), axis image off; truesize(hdl)

%% This is a same as
labels = l3t.l3c.query('pixel type', 1);
nLabels = length(labels);

k = cell(nLabels,1);
for ii=1:nLabels
    k{ii} = l3t.kernels{labels(ii)};
end

for ii=15 %length(labels)
    vcNewGraphWin; 
    [X,Y] = meshgrid(1:5,1:5);
    [U,V] = meshgrid(linspace(1,5,sz),linspace(1,5,sz));
    
    img = reshape(k{ii}(2:end,1),5,5); img = img/max(img(:));
    img = interp2(X,Y,img,U,V,'nearest');
    img = repmat(img,1,1,3);
    img = 0.8*img + 0.2*cfaImage;
    img = ieScale(img,0,1);img = img.^1.5;
    subplot(1,3,1); imagesc(img); axis off; axis image; title('Red out');
    
    img = reshape(k{ii}(2:end,2),5,5); img = img/max(img(:));
    img = interp2(X,Y,img,U,V,'nearest');
    img = repmat(img,1,1,3);
    img = 0.8*img + 0.2*cfaImage;
    img = ieScale(img,0,1);    img = img.^1.5;
    subplot(1,3,2); imagesc(img); axis off; axis image; title('Green out');
    
    img = reshape(k{ii}(2:end,3),5,5); img = img/max(img(:));
    img = interp2(X,Y,img,U,V,'nearest');
    img = repmat(img,1,1,3);
    img = 0.8*img + 0.2*cfaImage;
    img = ieScale(img,0,1); img = img.^1.5;
    subplot(1,3,3); imagesc(img); axis off; axis image; title('Blue out');

end

%%
    
% I added one query function, which could be called as
labels = l3t.l3c.query('pixel type', 1, 'luminance', [0 0.001], 'contrast', [0 1/32]);
% The parameter names should be the same as l3c.statNames field (cases and space ignored). You can also give it a function handle to do some complicated tasks.

% Another option is to do some selection directly on the output of getLabelRange. For example, to get all labels of pixel type 1, we can do

range = l3c.getLabelRange(1:l3c.nLabels);
indx = [range.pixeltype]==1;
labels = [range.label]; labels = labels(indx);

