%% Analysis of the raw data for the paper "Measuring Absolute Radiance by Calibrating a Hyperspectral Camera Economically"
% Journal
%   Color Research & Application
% DOI
%   10.1002/col.70043
%
% Description:
%   Runs the analysis script of every topic (src/<topic>/analyze<Topic>.m).
%   They read the raw hyperspectral images (to be downloaded from Zenodo,
%   ~9.4 GB, see README.md) and write the small processed data files to
%   /data/processedData. The processed files are already included in this
%   repository, so running this script is only necessary to reproduce the
%   analysis from the raw data. Afterwards, run runAllFigures and
%   verifyReproduction.
%
%   Run time: about 10-15 minutes, dominated by reading 92 data cubes.
%
% Authors
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%

clear; close all; clc;

fprintf('Setting up paths...\n');
addpath(genpath(fullfile(fileparts(mfilename('fullpath')), 'src')));

% Check that the raw hyperspectral images are present
paths = getProjectPaths();
if ~exist(fullfile(paths.hyperspectralImages, 'repeatability', '313', 'capture', '313.raw'), 'file')
    error(['Raw hyperspectral images not found in %s.\n' ...
           'Download them from Zenodo (https://doi.org/10.5281/zenodo.13136174) and unzip them there (see README.md).'], ...
          paths.hyperspectralImages);
end

fprintf('\n--- Section 3.1: repeatability ---\n');
analyzeRepeatability;

fprintf('\n--- Section 3.2: linearity with integration time ---\n');
analyzeLinearity;

fprintf('\n--- Section 3.2: dark current ---\n');
analyzeDarkCurrent;

fprintf('\n--- Section 3.3: flat field behavior and spatial uniformity ---\n');
analyzeFlatFieldBehavior;

fprintf('\n--- Section 3.4: wavelength calibration ---\n');
analyzeWavelengthCalibration;

fprintf('\n--- Section 3.5: spectral radiance calibration ---\n');
analyzeRadianceCalibration;

fprintf('\n--- Section 4.1: validation with an OLED panel ---\n');
analyzeOledValidation;            % uses the calibration factor of analyzeRadianceCalibration

fprintf('\n--- Section 4.2: validation with a Macbeth ColorChecker ---\n');
analyzeColorCheckerValidation;

fprintf('\nAll processed data have been saved in the /data/processedData folder.\n');
