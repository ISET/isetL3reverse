function rootpath = l3rRootPath()
% l3rRootPath Returns the path to the root L3r root directory
%
% This function must reside in the main directory containing the L3
% reverse engineering package.
%
% This helps with loading and saving files for the L3 reverse engineering
% algorithm. 
%
% BW Vista Team 2015

rootpath=which('l3rRootPath');

[rootpath, fName, ext] = fileparts(rootpath);

return