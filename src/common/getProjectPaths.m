%% function getProjectPaths
%
% Description:
%   Returns the absolute paths of the main folders of this repository, so
%   that every script works regardless of the current MATLAB folder.
%
% Outputs:
%   - paths: struct with the fields
%       .root                 repository root folder
%       .hyperspectralImages  raw Specim IQ captures (downloaded from Zenodo)
%       .spectroradiometer    raw JETI Specbos 1211L exports
%       .colorCamera          raw LMK 6-5 colour camera exports
%       .regionsOfInterest    pixel regions used in the analysis
%       .externalData         third-party data (CIE colour-matching functions)
%       .processedData        results of the analysis scripts (src/<topic>/analyze<Topic>.m)
%       .output               generated figures and tables
%
% Authors:
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%
% Last updated:
%   October-29-2026
%

function paths = getProjectPaths()

    % This file lives in <root>/src/common
    utilsFolder = fileparts(mfilename('fullpath'));
    paths.root  = fileparts(fileparts(utilsFolder));

    rawDataFolder             = fullfile(paths.root, 'data', 'rawData');
    paths.hyperspectralImages = fullfile(rawDataFolder, 'hyperspectralImages');
    paths.spectroradiometer   = fullfile(rawDataFolder, 'spectroradiometer');
    paths.colorCamera         = fullfile(rawDataFolder, 'colorCamera');
    paths.regionsOfInterest   = fullfile(rawDataFolder, 'regionsOfInterest');
    paths.externalData        = fullfile(paths.root, 'data', 'externalData');
    paths.processedData       = fullfile(paths.root, 'data', 'processedData');
    paths.output              = fullfile(paths.root, 'output');

    % Create the output folders on first use
    if ~exist(paths.processedData, 'dir'), mkdir(paths.processedData); end
    if ~exist(paths.output, 'dir'),        mkdir(paths.output);        end
end
