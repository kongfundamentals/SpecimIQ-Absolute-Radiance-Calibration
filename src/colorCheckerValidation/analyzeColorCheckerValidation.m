%% function analyzeColorCheckerValidation
%
% Description:
%   Section 4.2 (Validation with a Macbeth ColorChecker).
%   1) Because the ColorChecker was measured at 1.0 m instead of 1.5 m,
%      the calibration was repeated at 1.0 m. The calibration factor
%      C'(lambda) is derived (Eq. 7) from the mean dark corrected counts of
%      a 13 x 13 pixel area of the calibration source (t = 3 ms) and the
%      spectral radiance measured with the JETI.
%   2) For each of the 24 patches, the counts of a central 13 x 13 pixel
%      area of the ColorChecker capture (t = 150 ms) are averaged, dark
%      corrected and converted to spectral radiance with Eq. 8.
%
%   The ground truth is the mean of five JETI measurements at the centre of
%   every patch (file colorCheckerValidation_patches_jetiAverage.csv).
%
% Inputs:
%   - Raw captures 809 and 819 in '../data/rawData/hyperspectralImages/colorCheckerValidation'
%   - '../data/rawData/spectroradiometer/colorCheckerValidation_calibrationSource_jeti.csv'
%   - '../data/rawData/regionsOfInterest/regionsOfInterest.csv'
%
% Outputs:
%   - '../data/processedData/calibrationFactorColorChecker.csv'  C'(lambda)
%   - '../data/processedData/colorCheckerRadianceSpecim.csv'     Le,test of the 24 patches
%
% Authors:
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%
% Last updated:
%   October-29-2026
%

function analyzeColorCheckerValidation

    % 0. SETUP
    % ===================================================================
    paths       = getProjectPaths();
    allSettings = getAnalysisSettings();
    camera      = loadCameraSpecificData();
    settings    = allSettings.colorCheckerValidation;
    measurementFolder = fullfile(paths.hyperspectralImages, settings.folderName);

    regions = readRegionsOfInterest(settings.folderName);
    calibrationArea = regions(strcmp({regions.name}, 'jetiArea'));
    patchRegions    = regions(strncmp({regions.name}, 'patch', 5));
    numberOfPatches = numel(patchRegions);

    % 1. CALIBRATION FACTOR C'(lambda) AT 1.0 m (Eq. 7)
    % ===================================================================
    fprintf('Reading calibration capture %d\n', settings.calibrationHsiNumber);
    [cube, wavelengthFactory, calibrationIntegrationTime] = readHyperspectralDataCube(measurementFolder, settings.calibrationHsiNumber);
    wavelengthCorrected = wavelengthFactory - camera.wavelengthError;

    calibrationCounts = computeRegionMeanSpectrum(cube, calibrationArea) - camera.darkOffset;
    [jetiWavelength, jetiRadiance] = readJetiSpectra(fullfile(paths.spectroradiometer, settings.calibrationJetiFile));
    radianceAtBands = interpolateSpectrum(jetiWavelength, jetiRadiance, wavelengthCorrected);
    calibrationFactor = radianceAtBands * calibrationIntegrationTime ./ calibrationCounts;

    % 2. SPECTRAL RADIANCE OF THE 24 PATCHES (Eq. 8)
    % ===================================================================
    fprintf('Reading ColorChecker capture %d\n', settings.sceneHsiNumber);
    [cube, ~, sceneIntegrationTime] = readHyperspectralDataCube(measurementFolder, settings.sceneHsiNumber);
    radianceSpecim = zeros(numel(wavelengthFactory), numberOfPatches);
    for patchIndex = 1 : numberOfPatches
        patchCounts = computeRegionMeanSpectrum(cube, patchRegions(patchIndex)) - camera.darkOffset;
        radianceSpecim(:, patchIndex) = calibrationFactor .* patchCounts / sceneIntegrationTime;
    end

    % 3. SAVE
    % ===================================================================
    bandNumber = (1 : numel(wavelengthFactory))';
    writeNumericCsv(fullfile(paths.processedData, 'calibrationFactorColorChecker.csv'), ...
        {'bandNumber', 'wavelengthFactoryNm', 'wavelengthCorrectedNm', 'calibrationFactor'}, ...
        [bandNumber, wavelengthFactory, wavelengthCorrected, calibrationFactor]);

    writeNumericCsv(fullfile(paths.processedData, 'colorCheckerRadianceSpecim.csv'), ...
        [{'bandNumber', 'wavelengthFactoryNm', 'wavelengthCorrectedNm'}, {patchRegions.name}], ...
        [bandNumber, wavelengthFactory, wavelengthCorrected, radianceSpecim]);

    fprintf('ColorChecker validation spectra saved to %s\n', paths.processedData);
end
