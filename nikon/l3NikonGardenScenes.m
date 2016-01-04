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

%% Test repeatability of artifact listing
for ii=1:20
    s = rd.listArtifacts;
    s2 = rd.listArtifacts;
    if ~isequal(s,s2), disp('Returned artifacts differ'); end
end

%% See which artifacts download properly
close all
badJPGList = [];
for ii=1:length(s)
    try
        imgTrain = double(rd.readArtifact(s(ii).artifactId,'type','jpg'));
        vcNewGraphWin; imagescRGB(imgTrain);
        title(sprintf('artifact %d',ii));
    catch
        badJPGList(end+1) = ii;
        fprintf('Failed to read artifact %d\n',ii);
    end
    pause(1); close
end
badJPGList

%% But, we can download the bad JPG files using the direct URL
% So, they are there
tmp = [tempname,'.jpg'];
for ii=1:length(badJPGList)
    [p,n,e] = fileparts(s(badJPGList(ii)).url)
    url = fullfile(p,[n,'.jpg'])
    urlwrite(url,tmp);
    img = double(imread(tmp));
    imagescRGB(img); pause(1);
end

%% All the PGMs are there.

close all
badPGMList = [];
for ii=1:length(s)
    try
        imgTrain = double(rd.readArtifact(s(ii).artifactId,'type','pgm'));
        vcNewGraphWin; imagesc(imgTrain); colormap(gray); axis image
        title(sprintf('artifact %d',ii));
    catch
        badPGMList(end+1) = ii;
        fprintf('Failed to read artifact %d\n',ii);
    end
    pause(1); close
end
badPGMList

%% Validating the Cardinal D600 data set

rd.crp('/L3/Cardinal/D600');
s = rd.listArtifacts;
close all
fprintf('Found %d artifacts \n',length(s));

for ii=1:length(s)
    thisA = s(ii).artifactId;
    if strfind(thisA,'dxo')
        try
            imgTrain = double(rd.readArtifact(s(ii).artifactId,'type','tif'));
            vcNewGraphWin; imagescRGB(imgTrain);
            title(sprintf('Tif artifact %d',ii));
            
        catch
            % badTIFList(end+1) = ii;
            fprintf('Failed to read artifact %d\n',ii);
        end
        pause(1); close
    else
        imgTrain = double(rd.readArtifact(s(ii).artifactId,'type','pgm'));
        vcNewGraphWin; imagesc(imgTrain);
        title(sprintf('PGM artifact %d',ii));
    end
end

