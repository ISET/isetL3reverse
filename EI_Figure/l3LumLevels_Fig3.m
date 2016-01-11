%% s_L3Object_Nikon
%
% Reverse engineer Nikon D200 Camera
% Results used as
%
% (HJ) VISTA TEAM, 2016

%% Init
% Init ISET session
ieInit;

% Init luminance levels
nLumLevels = 10;
levels = round(logspace(log10(4), log10(80), nLumLevels));

% Init training parameters
cfa = [2 1; 3 4]; % Bayer pattern, 2 and 4 are both for green
patch_sz = [5 5];
pad_sz   = (patch_sz - 1) / 2;
offset = [1 2];

% Init S-CIELab parameters
d = displayCreate('LCD-Apple');
d = displaySet(d, 'gamma', 'linear');  % use a linear gamma table
d = displaySet(d, 'viewing distance', 1);
rgb2xyz = displayGet(d, 'rgb2xyz');
wp = displayGet(d, 'white xyz'); % white point
params = scParams;
params.sampPerDeg = displayGet(d, 'dots per deg');

% Init remote data toolbox parameters
rd = RdtClient('scien');
rd.crp('/L3/Farrell/D200/garden');

%% Training on odd images and test on even ones
s = rd.searchArtifacts('dsc_');
de = zeros(nLumLevels, floor(length(s)/2), 2);
l3r = l3Render();

% Training
for ii = 1 : nLumLevels
    % Set training parameters
    l3t = l3TrainOLS();
    l3t.l3c.patchSize = patch_sz;
    l3t.l3c.cutPoints = {logspace(-4, -1.2, levels(ii)), []};
    for jj = 1 : length(s)
        % load jpg image
        remoteURL = s(1).url(1:end-3);
        localFile = [tempname '.jpg'];
        rdtSave(localFile, [remoteURL 'jpg']);
        jpg = im2double(imread(localFile));
        sz = [size(jpg, 1) size(jpg, 2)];
        delete(localFile);
        
        % load raw
        localFile = [tempname '.pgm'];
        rdtSave(localFile, [remoteURL 'pgm']);
        raw = im2double(imread(localFile));
        raw = rawAdjustSize(raw, sz, pad_sz, offset);
        delete(localFile);
        
        % build l3 data structure
        l3d = l3DataCamera({raw}, {jpg}, cfa);
        
        % adding classify data
        l3t.l3c.classify(l3d);
    end
    
    % learn linear filters
    l3t.train();
    
    % render and compute deltaE
    for jj = 2 : 2 : length(s)
        % load jpg image
        remoteURL = s(jj).url(1:end-3);
        localFile = [tempname '.jpg'];
        rdtSave(localFile, [remoteURL 'jpg']);
        jpg = im2double(imread(localFile));
        sz = [size(jpg, 1) size(jpg, 2)];
        delete(localFile);
        
        % load raw
        localFile = [tempname '.pgm'];
        rdtSave(localFile, [remoteURL 'pgm']);
        raw = im2double(imread(localFile));
        raw = rawAdjustSize(raw, sz, pad_sz, offset);
        delete(localFile);
        
        l3_RGB = ieClip(l3r.render(raw, cfa, l3t), 0, 1);
        
        % compute S-CIELab DeltaE values
        xyz1 = imageLinearTransform(l3_RGB, rgb2xyz);
        xyz2 = imageLinearTransform(jpg, rgb2xyz);
        deImg = scielab(xyz1, xyz2, wp, params);
        de(ii, jj/2, :) = quantile(deImg(:), [0.5 0.9]);
    end
end

% END