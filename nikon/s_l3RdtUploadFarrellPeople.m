%% Upload Farrell images to Archiva scien/L3
%
% Not complete.  Get reminder from HJ about the conversion to pgm.  We need
% to make those for this case.
%
%

%% Now the people
rd = RdtClient('scien');
rd.crp('/L3/Farrell/D200/people');
rd.credentialsDialog;

%%
baseDir = '/wandellfs/data/validation/SCIEN/L3/nikond200';
cd(fullfile(baseDir,'NEF','people'))
rd.publishArtifacts(pwd,'type','nef');

% This is missing.  We need to write a script to make these!
% There is a conversion script somewhere, or at least HJ probably
% remembers how to do it with all the dcraw flags.
cd(fullfile(baseDir,'PGM','people'))
rd.publishArtifacts(pwd,'type','pgm');

%%
cd(fullfile(baseDir,'JPG','people'))
rd.publishArtifacts(pwd,'type','jpg');

%% Testing a delete of the artifacts
people = rd.listArtifacts;
for ii = 1:numel(people);
    fprintf('  %s\n', people(ii).artifactId);
end

% Now delete
deleted = rdtDeleteArtifacts(rd.configuration,people);

fprintf('The following artifacts were deleted:\n');
for ii = 1:numel(deleted);
    fprintf('  %s\n', deleted(ii).artifactId);
end

rd.openBrowser;
%%  Testing a delete of the path name
remotePath = '/L3/Farrell/D200/people';
deleted = rdtDeleteRemotePaths(rd.configuration, remotePath);
rd.openBrowser;

%%
