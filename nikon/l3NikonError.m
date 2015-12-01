%%
rd = rdata('base','http://scarlet.stanford.edu/validation/SCIEN/L3/nikond200/JPG');


rd.fileGet('DSC_0784.JPG',fullfile(pwd,'DSC_0784.JPG'));
rd.fileGet('DSC_0770.JPG',fullfile(pwd,'DSC_0770.JPG'));
rd.fileGet('DSC_0802.JPG',fullfile(pwd,'DSC_0802.JPG'));
rd.fileGet('DSC_0805.JPG',fullfile(pwd,'DSC_0805.JPG'));  % The worst one

rgb1 = imread('original/DSC_0805.JPG');
rgb2 = imread('rendered/DSC_0805.JPG');

vcNewGraphWin; imshow(rgb1)
vcNewGraphWin; imshow(rgb2)

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


