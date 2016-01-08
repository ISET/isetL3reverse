function outFile = rdtSave(localName,url)
% Interface to manage for websave/urlwrite issues until we are just doing
% readArtifact calls.
%
%   rdtSave(localFile,artifactURL)
%
%

%% Try parsing properly
p = inputParser;
p.addRequired('localName',@ischar);
p.addRequired('url',@ischar);
p.parse(localName,url);

localName = p.Results.localName;
url       = p.Results.url;

%% According to the version, use one or the other
if ~isempty(which('websave'))
    outFile = websave(localName,url);   
else
    outFile = urlwrite(url,localName);
end

end
