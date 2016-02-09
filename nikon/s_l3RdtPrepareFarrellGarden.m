%% s_l3RdtUploadFarrellGarden
%
% Convert the PGM and JPG files into standard format.  Place them in the
% 'processed' directory. Then Upload them to the archiva repository in the
% L3/Farrell/D200/garden directory.
%
% This file contains the list of pictures that JEF took with with the
% camera on rotated by 90 deg. 
% rFiles = [769, 771, 772, 773, 774, 775, 776, 777, 780, 781, 782, 787, 788, 795, 796, 797, 803]; 
% We rotated the original pgm files and the jpeg files so they look right
% on the screen.  But when we load the matched pairs we have
% to rethink the mosaic pattern (because that is fixed on the PGM file, and
% thus differs).
%
% I think our cropping and knowledge of the files can be handled by simply
% rotating clockwise the PGM and JPG files in the rFiles list before we
% start training.  The files in that list are the ones that have more rows
% than columns

%%
ieInit

%% Make the garden subdirectory from the main set of files

% This code forces lower case and puts the files into the garden subdir.
baseDir = '/wandellfs/data/validation/SCIEN/L3/nikond200/JPG';
cd(baseDir);
f = dir('*.JPG');
for ii=1:length(f)
    copyfile(f(ii).name,fullfile('garden',lower(f(ii).name)));
end

%%  Rotated JPG images - All can be rotated counter clockwise to align them
baseDir = '/wandellfs/data/validation/SCIEN/L3/nikond200/JPG/garden';
cd(baseDir)
% Do not run this code twice.  It will rotate again!

% If you do this again, change imageRotate to imrotate(X,90), I think.
close all
vcNewGraphWin;
rFiles = [769, 771, 772, 773, 774, 775, 776, 777, 780, 781, 782, 787, 788, 795, 796, 797, 803]; 
for ii=1:length(rFiles)
    thisFile = sprintf('dsc_0%d.jpg',rFiles(ii));
    fprintf('Rotating %s\n',thisFile);
    jpg = imread(fullfile(baseDir,thisFile));
    jpgR = imageRotate(jpg,'ccw');
    imwrite(uint8(jpgR),fullfile(baseDir,thisFile));
    jpgR = imread(fullfile(baseDir,thisFile));
    imagescRGB(double(jpgR));
    drawnow; 
    pause(1)
end

%% Now compare the number of garden jpg and pgm files

% They should be the same number.  39?
baseDir = '/wandellfs/data/validation/SCIEN/L3/nikond200/JPG/garden';
cd(baseDir)
fjpg = dir('*.jpg');

baseDir = '/wandellfs/data/validation/SCIEN/L3/nikond200/PGM/garden';
cd(baseDir)
fpgm = dir('*.pgm');

if length(fpgm) ~= length(fjpg),  error('mismatch in file names');
else           fprintf('%d files found\n',length(fpgm));
end
 

%%  Visualize to see that they are aligned and which are not

close all
baseDir = '/wandellfs/data/validation/SCIEN/L3/nikond200';
for ii=1:length(fpgm)
    jpg = imread(fullfile(baseDir,'JPG','garden',fjpg(ii).name),'jpg');
    pgm = imread(fullfile(baseDir,'PGM','garden',fpgm(ii).name),'pgm');
    if size(jpg,1) > size(jpg,2)
        r = 'yes';  % rotated flag
        fprintf('%s  ',fjpg(ii).name(6:8));
    end
    vcNewGraphWin;
    subplot(1,2,1); imagescRGB(double(jpg)); axis image
    title(sprintf('%s (%d) (rotated = %s)',fjpg(ii).name,ii,r));
    subplot(1,2,2); imagesc(double(pgm).^0.3); colormap(gray); axis image
    title(sprintf('%s (%d) (rotated = %s)',fjpg(ii).name,ii,r));
    drawnow; pause(1); 
    close
end

%% Rotate the rotated ones (again) back to standard mosaic aspect ratio 

% We do this for both the PGM and JPG.  So, some of the files will be
% stored in a way that is visually awkward, but for calculation purposes
% the alignments between all the PGM and JPGs in the garden directory will
% be the same.

% Otherwise, the rotated ones have an offset that differs from the
% non-rotated ones, and the mosaic pattern is rotated, too. Tell Joyce to
% keep her camera horizontal. 
baseDir = '/wandellfs/data/validation/SCIEN/L3/nikond200';
cd(baseDir);
close all
vcNewGraphWin;
for ii=1:length(rFiles)
    thisFile = sprintf('dsc_0%d.jpg',rFiles(ii));
    jFile =  fullfile(baseDir,'JPG','garden',thisFile);
    fprintf('Rotating %s\n',thisFile);
    jpg = imread(jFile);
    jpg = imrotate(jpg,-90);
    imwrite(uint8(jpg),jFile);
    
    thisFile = sprintf('dsc_0%d.pgm',rFiles(ii));
    pFile = fullfile(baseDir,'PGM','garden',thisFile);
    fprintf('Rotating %s\n',thisFile);
    pgm = imread(pFile);
    pgm = imrotate(pgm,-90);
    imwrite(uint16(pgm),pFile);

    % jpg = imread('tmp.jpg'); pgm = imread('tmp.pgm');
    % subplot(1,2,1); imagescRGB(double(jpg)); axis image
    % subplot(1,2,2); imagesc(double(pgm).^0.3); colormap(gray); axis image
end

%%  Visualize again
%
% In this case, they should all be in standard format with more columns
% than rows.  The images will not all look proper (some will be rotated).
% But the data format will be the same, which is what we want for training.
close all
baseDir = '/wandellfs/data/validation/SCIEN/L3/nikond200';
for ii=1:length(fpgm)
    jpg = imread(fullfile(baseDir,'JPG','garden',fjpg(ii).name),'jpg');
    pgm = imread(fullfile(baseDir,'PGM','garden',fpgm(ii).name),'pgm');
    if size(jpg,1) > size(jpg,2)
        r = 'yes';  % rotated flag
        fprintf('%s  ',fjpg(ii).name(6:8));
    end
    vcNewGraphWin;
    subplot(1,2,1); imagescRGB(double(jpg)); axis image
    title(sprintf('%s (%d) (rotated = %s)',fjpg(ii).name,ii,r));
    subplot(1,2,2); imagesc(double(pgm).^0.3); colormap(gray); axis image
    title(sprintf('%s (%d) (rotated = %s)',fjpg(ii).name,ii,r));
    drawnow; pause(1); 
    close
end

%%  Finally, publish the files in the archive
%  See the script s_l3RdtUpload

%%  Have a look
rd.openBrowser;

%%