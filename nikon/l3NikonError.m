%%
rd = rdata('base','http://scarlet.stanford.edu/validation/SCIEN/L3/nikond200/JPG');

% We think that the illuminant for these is pretty similar.  Still, could
% we make the match a little better by a 3x3?
rd.fileGet('DSC_0784.JPG',fullfile(pwd,'DSC_0784.JPG'));
rd.fileGet('DSC_0770.JPG',fullfile(pwd,'DSC_0770.JPG'));
rd.fileGet('DSC_0802.JPG',fullfile(pwd,'DSC_0802.JPG'));

% The worst one because the illuminant is far off
rd.fileGet('DSC_0805.JPG',fullfile(pwd,'DSC_0805.JPG'));  

%% For this image, we think the illumination differs from the trained illuminant

rgb1 = imread('original/DSC_0805.JPG');
rgb2 = imread('rendered/DSC_0805.JPG');

vcNewGraphWin; imshow(rgb1)
vcNewGraphWin; imshow(rgb2)
%%
xyz1 = srgb2xyz(double(rgb1)/255);
xyz2 = srgb2xyz(double(rgb2)/255);

%%
d = displayCreate;
d = displaySet(d,'viewing distance',1);
p = scParams(displayGet(d,'dpi'),displayGet(d,'viewing distance'));
wPoint = displayGet(d,'white point');
wPoint = 2*wPoint/wPoint(2);  % Luminance of 1 for white point, as per srgb2xyz
dE = scielab(xyz1,xyz2,wPoint,p);

%%
mean(dE(:))
hist(dE(:),100)
vcNewGraphWin; imagesc(dE); colorbar; colormap(gray);

%% The RGB values aren't all that close, it seems to me.
X = rgb1(1:100:end);
Y = rgb2(1:100:end);
vcNewGraphWin;
plot(X(:),Y(:),'.');
grid on;
identityLine;

%% Find the 3x3 that matches the two RGB values best
[rgb1,r,c] = RGB2XWFormat(rgb1);
[rgb2] = RGB2XWFormat(rgb2);

% rgb1 = rgb2 * T
T = double(rgb2) \ double(rgb1);

rgb3 = double(rgb2) * T;
rgb3 = uint8(ieClip(rgb3,0,255));

rgb3 = XW2RGBFormat(rgb3,r,c);
rgb2 = XW2RGBFormat(rgb2,r,c);
rgb1 = XW2RGBFormat(rgb1,r,c);

vcNewGraphWin; imshow(rgb1);  % Original
vcNewGraphWin; imshow(rgb3)   % Rendered and Corrected by T

imwrite(rgb3,'DSC_0805CC.JPG','jpg');

%% Now check a pretty good one, say one with a red flower

rgb1 = imread('original/DSC_0784.JPG');
rgb2 = imread('rendered/DSC_0784.JPG');

[rgb1,r,c] = RGB2XWFormat(rgb1);
[rgb2] = RGB2XWFormat(rgb2);

% rgb1 = rgb2 * T
T = double(rgb2) \ double(rgb1);

rgb3 = double(rgb2) * T;
rgb3 = uint8(ieClip(rgb3,0,255));

rgb3 = XW2RGBFormat(rgb3,r,c);
rgb2 = XW2RGBFormat(rgb2,r,c);
rgb1 = XW2RGBFormat(rgb1,r,c);

%%
vcNewGraphWin; imshow(rgb1); title('Original'); % Original
vcNewGraphWin; imshow(rgb3); title('Corrected');   % Rendered and Corrected by T

%% Now compare the SCIELAB error after transform

xyz1 = srgb2xyz(double(rgb1)/255);
xyz3 = srgb2xyz(double(rgb3)/255);

%%
d = displayCreate;
d = displaySet(d,'viewing distance',1);
p = scParams(displayGet(d,'dpi'),displayGet(d,'viewing distance'));
wPoint = displayGet(d,'white point');
wPoint = 2*wPoint/wPoint(2);  % Luminance of 1 for white point, as per srgb2xyz
dE = scielab(xyz1,xyz3,wPoint,p);

%%
mean(dE(:))
hist(dE(:),100)
vcNewGraphWin; imagesc(dE); colorbar; colormap(gray); axis image; axis off


