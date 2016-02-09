%% Publish the processed nikon D200 images to archiva/scien
%
% HJ/BW

%%  Open the connection and login for writing
rd = RdtClient('scien');
rd.credentialsDialog;

%% These data were processed by HJ/BW by hand
baseDir = '/wandellfs/data/validation/SCIEN/L3/nikond200/processed';
rd.crp('/L3/Farrell/D200/garden');

cd(baseDir)

rd.publishArtifacts(pwd,'type','pgm','verbose',true);

rd.publishArtifacts(pwd,'type','jpg','verbose',true);

%%