%% Upload Cardinal L3 training data to Archiva site
%
% The Farrell garden data set has its own script
% The Farrell people data set has its own script
%

%% 
ieInit

%% This is how we open to the SCIEN repository
rd = RdtClient('scien');
rd.credentialsDialog;
fileVersion = '1';

%% Upload Cardinal images to Archiva scien/L3

% There is only one original D2X file and associated PGM file
% But there can be multiple versions of the tif file.  In this case, there
% are 2 versions, dxo and dxo_nodist
baseDir = '/wandellfs/data/validation/SCIEN/L3/DCardinal';
rd.crp('/L3/Cardinal/D2X');

cd(baseDir);
cd('NEF/D2X')
rd.publishArtifacts(pwd,'type','nef');

cd(baseDir);
cd('PGM/D2X')
rd.publishArtifacts(pwd,'type','pgm');

cd(baseDir);
cd('TIFF/D2X')
rd.publishArtifacts(pwd,'type','tif');

%% The D3 files.  In this case, two originals and a few 'tif' versions

rd.crp('/L3/Cardinal/D3');

cd(baseDir)
cd('NEF/D3')
rd.publishArtifacts(pwd,'type','nef');

cd(baseDir)
cd('PGM/D3')
rd.publishArtifacts(pwd,'type','pgm');

cd(baseDir)
cd('TIFF/D3')
rd.publishArtifacts(pwd,'type','tif');

%% D300 files

cd(baseDir)
rd.crp('/L3/Cardinal/D300');

cd(fullfile(baseDir,'NEF','D300'))
rd.publishArtifacts(pwd,'type','nef');

cd(fullfile(baseDir,'PGM','D300'))
rd.publishArtifacts(pwd,'type','pgm');

cd(fullfile(baseDir,'TIFF','D300'))
rd.publishArtifacts(pwd,'type','tif');

%% D600
cd(baseDir)
rd.crp('/L3/Cardinal/D600');

cd(fullfile(baseDir,'NEF','D600'))
rd.publishArtifacts(pwd,'type','nef');

cd(fullfile(baseDir,'PGM','D600'))
rd.publishArtifacts(pwd,'type','pgm');

cd(fullfile(baseDir,'TIFF','D600'))
rd.publishArtifacts(pwd,'type','tif');

%% D700
cd(baseDir)
rd.crp('/L3/Cardinal/D700');

cd(fullfile(baseDir,'NEF','D700'))
rd.publishArtifacts(pwd,'type','nef');

cd(fullfile(baseDir,'PGM','D700'))
rd.publishArtifacts(pwd,'type','pgm');

cd(fullfile(baseDir,'TIFF','D700'))
rd.publishArtifacts(pwd,'type','tif');

%% Try fetching some artifacts 

% From the D600 set
rd.crp('/L3/Cardinal/D600');
a = rd.listArtifacts;
data = rd.readArtifact(a(1).artifactId,'type','tif');
imtool(data);

% Another tif file, this time for the D3
rd.crp('/L3/Cardinal/D3');
a = rd.listArtifacts;
tic
data = rd.readArtifact(a(2).artifactId,'type','tif');
toc
imtool(data);

% Note that this is faster
tic
tmp = tempname;
tmp = websave(tmp,a(2).url);
im = imread(tmp);
toc
imtool(im);
%%
 