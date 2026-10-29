%% function analyzeRadianceCalibration
%
% Description:
%   Section 3.5 (Spectral radiance calibration).
%   1) Figure 9:  dark corrected signal I'(ic, jc, lambda) of the central
%                 pixel of the calibration source in three repeated captures.
%   2) Figure 10: mean spectral radiance of the calibration source measured
%                 with the JETI Specbos 1211L (measurements #21-#30).
%   3) Figure 11: calibration factor (Eq. 7)
%                     C(i, j, lambda) = Le,cal(lambda) * tcal / I'cal(i, j, lambda)
%                 for every pixel of the 7 x 7 pixel area measured by the
%                 JETI, its mean C(lambda) and the spatial CV.
%
%   The wavelength-corrected bands (Eq. 4) are used, and the JETI spectrum
%   is resampled to these bands with interpolateSpectrum. The calibration
%   factor without wavelength correction is stored as well (Figure 14).
%
% Inputs:
%   - Raw captures 240-242 in '../data/rawData/hyperspectralImages/radianceCalibration'
%   - '../data/rawData/spectroradiometer/radianceCalibration_jeti.csv'
%   - '../data/rawData/regionsOfInterest/regionsOfInterest.csv'
%
% Outputs:
%   - '../data/processedData/calibrationSourceCounts.csv'  (Figure 9)
%   - '../data/processedData/calibrationSourceJeti.csv'    (Figure 10)
%   - '../data/processedData/calibrationFactor.csv'        (Figure 11; used in Section 4.1)
%
% Authors:
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%
% Last updated:
%   October-29-2026
%

function analyzeRadianceCalibration

    % 0. SETUP
    % ===================================================================
    paths       = getProjectPaths();
    allSettings = getAnalysisSettings();
    camera      = loadCameraSpecificData();
    settings    = allSettings.radianceCalibration;
    measurementFolder = fullfile(paths.hyperspectralImages, settings.folderName);

    % 1. JETI SPECTRUM OF THE CALIBRATION SOURCE (Figure 10)
    % ===================================================================
    [jetiWavelength, jetiSpectra] = readJetiSpectra(fullfile(paths.spectroradiometer, settings.jetiFile));
    calibrationRadiance = mean(jetiSpectra(:, settings.jetiMeasurements), 2);

    % 2. CENTRAL PIXEL OF THE THREE CAPTURES (Figure 9)
    % ===================================================================
    numberOfCaptures = numel(settings.hsiNumbers);
    for captureIndex = 1 : numberOfCaptures
        hsiNumber = settings.hsiNumbers(captureIndex);
        fprintf('Reading capture %d\n', hsiNumber);
        [cube, wavelengthFactory, integrationTimeMs] = readHyperspectralDataCube(measurementFolder, hsiNumber);
        if captureIndex == 1
            centralCounts = zeros(numel(wavelengthFactory), numberOfCaptures);
        end
        pixel = settings.centerPixels(captureIndex, :);
        centralCounts(:, captureIndex) = reshape(cube(pixel(1), pixel(2), :), [], 1) - camera.darkOffset;

        if hsiNumber == settings.hsiNumberForFactor
            cubeForFactor = cube;
            integrationTimeForFactor = integrationTimeMs;
        end
    end
    wavelengthCorrected = wavelengthFactory - camera.wavelengthError;   % Eq. 4

    % 3. CALIBRATION FACTOR FOR EVERY PIXEL OF THE 7 x 7 AREA (Eq. 7)
    % ===================================================================
    calibrationArea = readRegionsOfInterest(settings.folderName);
    calibrationArea = calibrationArea(strcmp({calibrationArea.name}, 'jetiArea'));
    areaCounts = cubeForFactor(calibrationArea.iRange, calibrationArea.jRange, :) - camera.darkOffset;
    areaCounts = reshape(areaCounts, [], numel(wavelengthFactory))';          % (bands x 49)

    radianceAtBands          = interpolateSpectrum(jetiWavelength, calibrationRadiance, wavelengthCorrected);
    radianceAtFactoryBands   = interpolateSpectrum(jetiWavelength, calibrationRadiance, wavelengthFactory);
    numberOfPixels = size(areaCounts, 2);

    calibrationFactorPerPixel = repmat(radianceAtBands, 1, numberOfPixels) * integrationTimeForFactor ./ areaCounts;
    calibrationFactor         = mean(calibrationFactorPerPixel, 2);
    % Spatial standard deviation over the 49 pixels (population definition, as in the original analysis)
    spatialStandardDeviation  = std(calibrationFactorPerPixel, 1, 2);
    spatialCv                 = spatialStandardDeviation ./ calibrationFactor * 100;

    calibrationFactorUncorrected = mean(repmat(radianceAtFactoryBands, 1, numberOfPixels) ...
                                        * integrationTimeForFactor ./ areaCounts, 2);

    fprintf('Spatial CV of the calibration factor: mean %.2f %%, maximum %.2f %%\n', mean(spatialCv), max(spatialCv));

    % 4. SAVE
    % ===================================================================
    bandNumber = (1 : numel(wavelengthFactory))';
    writeNumericCsv(fullfile(paths.processedData, 'calibrationSourceCounts.csv'), ...
        {'bandNumber', 'wavelengthFactoryNm', 'wavelengthCorrectedNm', ...
         sprintf('darkCorrectedCountsHsi%d', settings.hsiNumbers(1)), ...
         sprintf('darkCorrectedCountsHsi%d', settings.hsiNumbers(2)), ...
         sprintf('darkCorrectedCountsHsi%d', settings.hsiNumbers(3)), 'darkCorrectedCountsMean'}, ...
        [bandNumber, wavelengthFactory, wavelengthCorrected, centralCounts, mean(centralCounts, 2)]);

    writeNumericCsv(fullfile(paths.processedData, 'calibrationSourceJeti.csv'), ...
        {'wavelengthNm', 'spectralRadianceWPerM2SrNm'}, [jetiWavelength, calibrationRadiance]);

    writeNumericCsv(fullfile(paths.processedData, 'calibrationFactor.csv'), ...
        {'bandNumber', 'wavelengthFactoryNm', 'wavelengthCorrectedNm', 'calibrationFactor', ...
         'spatialStandardDeviation', 'spatialCvPercent', 'calibrationFactorWithoutWavelengthCorrection'}, ...
        [bandNumber, wavelengthFactory, wavelengthCorrected, calibrationFactor, ...
         spatialStandardDeviation, spatialCv, calibrationFactorUncorrected]);

    fprintf('Radiance calibration data saved to %s\n', paths.processedData);
end
