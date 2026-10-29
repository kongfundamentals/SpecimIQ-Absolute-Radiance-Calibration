%% function analyzeWavelengthCalibration
%
% Description:
%   Section 3.4 (Wavelength calibration and spectral bandwidth). A helium
%   discharge lamp was captured at the centre of the field of view
%   (t = 10 ms). For the central pixel, the dark corrected digital counts
%   I'(i, j, lambdaFactory) are extracted. For the eight helium peaks,
%   the discrepancy between the measured peak (factory-set wavelength of
%   the band with the highest count) and the theoretical emission line is
%   calculated (Table 1), as well as the full width at half maximum (FWHM)
%   of every peak.
%
%   The FWHM is determined by linear interpolation between the sampled
%   bands at half the peak value on both sides of the peak.
%
% Inputs:
%   - Raw capture 255 in '../data/rawData/hyperspectralImages/wavelengthCalibration'
%
% Outputs:
%   - '../data/processedData/heliumSpectrum.csv'  band, factory wavelength, I'
%   - '../data/processedData/heliumPeaks.csv'     peak table (Table 1) with FWHM
%
% Authors:
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%
% Last updated:
%   October-29-2026
%

function analyzeWavelengthCalibration

    % 0. SETUP
    % ===================================================================
    paths       = getProjectPaths();
    allSettings = getAnalysisSettings();
    camera      = loadCameraSpecificData();
    settings    = allSettings.wavelengthCalibration;
    measurementFolder = fullfile(paths.hyperspectralImages, settings.folderName);

    % 1. DARK CORRECTED SPECTRUM OF THE CENTRAL PIXEL
    % ===================================================================
    [cube, wavelengthFactory, integrationTimeMs] = readHyperspectralDataCube(measurementFolder, settings.hsiNumber);
    darkCorrectedCounts = reshape(cube(settings.pixel(1), settings.pixel(2), :), [], 1) - camera.darkOffset;
    fprintf('Helium lamp capture %d, t = %d ms\n', settings.hsiNumber, integrationTimeMs);

    % 2. PEAK TABLE (Table 1) AND FWHM
    % ===================================================================
    peakBands       = settings.peakBands(:);
    measuredPeaks   = wavelengthFactory(peakBands);
    discrepancy     = measuredPeaks - settings.theoreticalPeaks(:);
    peakValues      = darkCorrectedCounts(peakBands);
    fullWidthHalfMaximum = zeros(numel(peakBands), 1);
    for peakIndex = 1 : numel(peakBands)
        fullWidthHalfMaximum(peakIndex) = computeFullWidthHalfMaximum( ...
            wavelengthFactory, darkCorrectedCounts, peakBands(peakIndex));
    end

    fprintf('Average wavelength discrepancy: %.2f nm (min %.2f, max %.2f)\n', ...
            mean(discrepancy), min(discrepancy), max(discrepancy));
    fprintf('FWHM: average %.2f nm, minimum %.2f nm, maximum %.2f nm\n', ...
            mean(fullWidthHalfMaximum), min(fullWidthHalfMaximum), max(fullWidthHalfMaximum));

    % 3. SAVE
    % ===================================================================
    bandNumber = (1 : numel(wavelengthFactory))';
    writeNumericCsv(fullfile(paths.processedData, 'heliumSpectrum.csv'), ...
        {'bandNumber', 'wavelengthFactoryNm', 'darkCorrectedCounts'}, ...
        [bandNumber, wavelengthFactory, darkCorrectedCounts]);

    writeNumericCsv(fullfile(paths.processedData, 'heliumPeaks.csv'), ...
        {'bandNumber', 'measuredPeakNm', 'theoreticalPeakNm', 'discrepancyNm', 'peakCounts', 'fwhmNm'}, ...
        [peakBands, measuredPeaks, settings.theoreticalPeaks(:), discrepancy, peakValues, fullWidthHalfMaximum]);

    fprintf('Wavelength calibration data saved to %s\n', paths.processedData);
end


%% LOCAL FUNCTION: computeFullWidthHalfMaximum
% Width of a peak at half of its maximum, using linear interpolation
% between the neighbouring bands on the rising and on the falling edge.
function width = computeFullWidthHalfMaximum(wavelength, counts, peakBand)

    halfMaximum = counts(peakBand) / 2;

    % Rising edge: last band below half maximum before the peak
    leftBand = peakBand;
    while leftBand > 1 && counts(leftBand) > halfMaximum
        leftBand = leftBand - 1;
    end
    leftWavelength = interpolateCrossing(wavelength(leftBand), wavelength(leftBand + 1), ...
                                         counts(leftBand), counts(leftBand + 1), halfMaximum);

    % Falling edge: first band below half maximum after the peak
    rightBand = peakBand;
    while rightBand < numel(counts) && counts(rightBand) > halfMaximum
        rightBand = rightBand + 1;
    end
    rightWavelength = interpolateCrossing(wavelength(rightBand - 1), wavelength(rightBand), ...
                                          counts(rightBand - 1), counts(rightBand), halfMaximum);

    width = rightWavelength - leftWavelength;
end


function crossingWavelength = interpolateCrossing(wavelength1, wavelength2, counts1, counts2, level)
    crossingWavelength = wavelength1 + (level - counts1) * (wavelength2 - wavelength1) / (counts2 - counts1);
end
