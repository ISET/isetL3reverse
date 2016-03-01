%% s_fitDepth
%    fit the depth of underwater image as a function of mean intensity
%    levels
%
%  HJ, VISTA TEAM, 2016

%% Init
ieInit;
base = 'http://scarlet.stanford.edu/validation/SCIEN/CARIBBEAN/03/';
labelsDir = [base 'Labels/Water/'];
rawDir = [base 'Data/Water/'];

s = lsScarlet(labelsDir, '.xml');

%% Get depth and mean luminance
depth = zeros(length(s), 1);
mean_lum = zeros(length(s), 1);

fprintf('Processing Image: ');
for ii = 1 : length(s)
    % print info
    str = sprintf('%d / %d', ii, length(s));
    fprintf(str);
    
    % get depth info from xml file
    xml = xml2struct(xmlread([labelsDir s(ii).name]));
    depth(ii) = str2double(xml.parameters.depth.Text);
    
    % compute mean luminance
    raw = im2double(imread([rawDir s(ii).name(1:end-4) '.pgm']));
    mean_lum(ii) = mean(raw(:));
    
    % print info
    fprintf(repmat('\b', [1 length(str)]));
end
fprintf('Done...\n');

% visualize and save
vcNewGraphWin; plot(depth, mean_lum);
save depth.mat depth mean_lum

%% Fit curve
%  fit a smoothing spline here
f = fit(depth, mean_lum, 'smoothingspline', 'SmoothingParam', 0.6);
vcNewGraphWin; plot(f, depth, mean_lum);

