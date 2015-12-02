%% Look up and plot some of the Nikon filters
%

ieInit


%% These are the Nikon image training parameters
cfa      = [2 1; 3 4]; % Bayer pattern, 2 and 4 are both for green
patch_sz = [5 5];
pad_sz   = (patch_sz - 1) / 2;
offset   = [1 2];

% If you are just loading the TrainOLS structure
fname = fullfile(l3rRootPath, 'local','trainQuarter','l3tNikon.mat');
exist(fname,'file')
load(fname)

%% Choose the labels by a query

pType = 3;   % 1, green; 2 blue; 3 red

labels = l3t.l3c.query('pixel type', pType);
k = l3t.kernels;

% Remove labels that point to empty kernels
lst = zeros(size(k));
nLabels = length(labels);
for ii=1:nLabels
    if isempty(k{labels(ii)}), lst(ii) = false; 
    else               lst(ii) = true;
    end
end
labels = labels(logical(lst));

% Update 
nLabels = length(labels);

%% Make the cfa image
sensor = sensorCreate;
[cfaImage,mp] = sensorImageColorArray(sensorDetermineCFA(sensor));
sz = 128;

% 2 is blue
% 1 is green
% 3 is red
if pType == 1
    cfaImage = cfaImage(1:5,1:5);
elseif pType ==2
    cfaImage = cfaImage((1:5) + 1,1:5);
elseif pType == 3;
    cfaImage = cfaImage(1:5,(1:5) + 1);
end
cfaImage = ind2rgb(cfaImage,mp);
% % Make the image bigger.
% s = 192/round(size(cfaImage,1));
% cfaImage = imageIncreaseImageRGBSize(cfaImage,s);

% % Draw the CFA in a new figure window (true size)
% hdl = vcNewGraphWin;
% set(hdl,'Name', sensorGet(sensor,'name'),'menubar','None');
% image(cfaImage), axis image off; truesize(hdl)

%%  Show the non-empty filters in gray scale

% range = l3t.l3c.getLabelRange(labels);
nLevels = 3;
lst = round(logspace(0,log10(nLabels*.5),nLevels));

vcNewGraphWin;
jj = 1;
for ii=labels(lst)
    
    img = reshape(k{ii}(2:end,1),5,5); 
    img = ieScale(img,0,1);
    img = repmat(img,1,1,3);
    img = img % .* cfaImage;
    img = imageIncreaseImageRGBSize(img,192);
    subplot(nLevels,3,jj); imagesc(img); axis off; axis image; title('Red');
    jj = jj + 1;
    
    img = reshape(k{ii}(2:end,2),5,5); 
    img = ieScale(img,0,1);
    img = repmat(img,1,1,3);
    img = img % .* cfaImage;
    img = imageIncreaseImageRGBSize(img,192);
    subplot(nLevels,3,jj); imagesc(img); axis off; axis image; title('Green');
    jj = jj + 1;
    
    img = reshape(k{ii}(2:end,3),5,5); 
    img = ieScale(img,0,1);
    img = repmat(img,1,1,3);
    img = img % .* cfaImage;
    img = imageIncreaseImageRGBSize(img,192);
    subplot(nLevels,3,jj); imagesc(img); axis off; axis image; title('Blue');
    jj = jj + 1;
    
    l3t.l3c.getLabelRange(ii)
    
end

%%  Show the non-empty filters with color

% range = l3t.l3c.getLabelRange(labels);
nLevels = 3;
lst = round(logspace(0,log10(nLabels*.5),nLevels));

vcNewGraphWin;
jj = 1;
for ii=labels(lst)
    
    img = reshape(k{ii}(2:end,1),5,5); 
    img = ieScale(img,0,1);
    img = repmat(img,1,1,3);
    img = img .* cfaImage;
    img = imageIncreaseImageRGBSize(img,192);
    subplot(nLevels,3,jj); imagesc(img); axis off; axis image; title('Red');
    jj = jj + 1;
    
    img = reshape(k{ii}(2:end,2),5,5); 
    img = ieScale(img,0,1);
    img = repmat(img,1,1,3);
    img = img .* cfaImage;
    img = imageIncreaseImageRGBSize(img,192);
    subplot(nLevels,3,jj); imagesc(img); axis off; axis image; title('Green');
    jj = jj + 1;
    
    img = reshape(k{ii}(2:end,3),5,5); 
    img = ieScale(img,0,1);
    img = repmat(img,1,1,3);
    img = img .* cfaImage;
    img = imageIncreaseImageRGBSize(img,192);
    subplot(nLevels,3,jj); imagesc(img); axis off; axis image; title('Blue');
    jj = jj + 1;
    
    l3t.l3c.getLabelRange(ii)
    
end

%% Query instructions from HJ
    
% This is how to get labels within parameter range
labels = l3t.l3c.query('pixel type', 1, 'luminance', [0 0.001], 'contrast', [0 1/32]);

% The parameter names should be the same as l3c.statNames field (cases and
% space ignored). You can also give it a function handle to do some
% complicated tasks.  

% Another option is to do some selection directly on the output of
% getLabelRange. For example, to get all labels of pixel type 1, we can do
% 
range = l3c.getLabelRange(1:l3c.nLabels);
indx = [range.pixeltype]==1;
labels = [range.label]; labels = labels(indx);

%%