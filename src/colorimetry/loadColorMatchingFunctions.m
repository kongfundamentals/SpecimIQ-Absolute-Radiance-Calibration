%% function loadColorMatchingFunctions
%
% Description:
%   Loads the CIE 1931 2-degree standard observer colour-matching
%   functions (360-830 nm, 1 nm step) from /data/externalData.
%
% Outputs:
%   - cmfTable: (471 x 4 double) [wavelength (nm), xBar, yBar, zBar].
%
% Authors:
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%
% Last updated:
%   October-29-2026
%

function cmfTable = loadColorMatchingFunctions()

    paths    = getProjectPaths();
    cmfTable = readNumericCsv(fullfile(paths.externalData, 'cie1931_2deg_colorMatchingFunctions.csv'));
end
