%% function analyzeOledValidation
%
% Description:
%   Section 4.1 (Validation with an OLED panel). The OLED panel was captured
%   twice with t = 70 ms. For five spots (four corners and the centre),
%   the digital counts of an 11 x 11 pixel area are averaged over the
%   area and over both captures, dark corrected, and converted to spectral
%   radiance with Eq. 8:
%       Le,test(lambda) = C(lambda) * I'test(lambda) / ttest
%   using the calibration factor C(lambda) of Section 3.5. The same is done
%   with the calibration factor obtained without wavelength correction
%   (dotted lines in Figure 14).
%
%   The ground truth Le,gt is the mean of five JETI measurements at every
%   spot (JETI targets 25-29 in the 2022-02-18 file).
%
% Inputs:
%   - Raw captures 397 and 398 in '../data/rawData/hyperspectralImages/oledValidation'
%   - '../data/processedData/calibrationFactor.csv' (run analyzeRadianceCalibration first)
%   - '../data/rawData/spectroradiometer/oledValidation_jeti.csv'
%   - '../data/rawData/regionsOfInterest/regionsOfInterest.csv'
%
% Outputs:
%   - '../data/processedData/oledRadianceSpecim.csv'   Le,test for the five spots
%       (columns per spot, with and without wavelength correction)
%   - '../data/processedData/oledRadianceJeti.csv'     Le,gt for the five spots (1 nm steps)
%
% Authors:
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%
% Last updated:
%   October-29-2026
%

function analyzeOledValidation

    % 0. SETUP
    % ===================================================================
    paths       = getProjectPaths();
    allSettings = getAnalysisSettings();
    camera      = loadCameraSpecificData();
    settings    = allSettings.oledValidation;
    measurementFolder = fullfile(paths.hyperspectralImages, settings.folderName);

    spots = readRegionsOfInterest(settings.folderName);
    [~, spotOrder] = ismember(settings.spotNames, {spots.name});
    spots = spots(spotOrder);
    numberOfSpots = numel(spots);

    % 1. MEAN DIGITAL COUNTS OF EVERY SPOT, AVERAGED OVER BOTH CAPTURES
    % ===================================================================
    numberOfCaptures = numel(settings.hsiNumbers);
    for captureIndex = 1 : numberOfCaptures
        fprintf('Reading capture %d\n', settings.hsiNumbers(captureIndex));
        [cube, wavelengthFactory, integrationTimeMs] = readHyperspectralDataCube(measurementFolder, settings.hsiNumbers(captureIndex));
        if captureIndex == 1
            spotCounts = zeros(numel(wavelengthFactory), numberOfSpots);
            testIntegrationTime = integrationTimeMs;
        end
        for spotIndex = 1 : numberOfSpots
            spotCounts(:, spotIndex) = spotCounts(:, spotIndex) + ...
                computeRegionMeanSpectrum(cube, spots(spotIndex)) / numberOfCaptures;
        end
    end
    darkCorrectedCounts = spotCounts - camera.darkOffset;

    % 2. CONVERT TO SPECTRAL RADIANCE (Eq. 8)
    % ===================================================================
    [calibrationTable, calibrationColumns] = readNumericCsv(fullfile(paths.processedData, 'calibrationFactor.csv'));
    calibrationFactor            = calibrationTable(:, strcmp(calibrationColumns, 'calibrationFactor'));
    calibrationFactorUncorrected = calibrationTable(:, strcmp(calibrationColumns, 'calibrationFactorWithoutWavelengthCorrection'));
    wavelengthCorrected          = wavelengthFactory - camera.wavelengthError;

    radianceSpecim            = darkCorrectedCounts .* repmat(calibrationFactor, 1, numberOfSpots) / testIntegrationTime;
    radianceSpecimUncorrected = darkCorrectedCounts .* repmat(calibrationFactorUncorrected, 1, numberOfSpots) / testIntegrationTime;

    % 3. GROUND TRUTH: MEAN OF FIVE JETI MEASUREMENTS PER SPOT
    % ===================================================================
    [jetiWavelength, jetiSpectra] = readJetiSpectra(fullfile(paths.spectroradiometer, settings.jetiFile));
    radianceJeti = zeros(numel(jetiWavelength), numberOfSpots);
    for spotIndex = 1 : numberOfSpots
        targetNumber = settings.jetiTargets(spotIndex);
        measurementColumns = (targetNumber - 1) * settings.repeatsPerTarget + (1 : settings.repeatsPerTarget);
        radianceJeti(:, spotIndex) = mean(jetiSpectra(:, measurementColumns), 2);
    end

    % 4. SAVE
    % ===================================================================
    spotNames = settings.spotNames;
    writeNumericCsv(fullfile(paths.processedData, 'oledRadianceSpecim.csv'), ...
        [{'bandNumber', 'wavelengthFactoryNm', 'wavelengthCorrectedNm'}, ...
         strcat(spotNames, '_wavelengthCorrected'), strcat(spotNames, '_withoutWavelengthCorrection')], ...
        [(1 : numel(wavelengthFactory))', wavelengthFactory, wavelengthCorrected, radianceSpecim, radianceSpecimUncorrected]);

    writeNumericCsv(fullfile(paths.processedData, 'oledRadianceJeti.csv'), ...
        [{'wavelengthNm'}, spotNames], [jetiWavelength, radianceJeti]);

    fprintf('OLED validation spectra saved to %s\n', paths.processedData);
end
