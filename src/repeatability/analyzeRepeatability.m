%% function analyzeRepeatability
%
% Description:
%   Section 3.1 (Repeatability). Extracts the digital counts I(i, j, k) of
%   the central pixel of the calibration source aperture from 61 captures
%   taken over 60 minutes (one capture per minute, t = 1 ms), and computes
%   the mean, standard deviation and coefficient of variation (CV, Eq. 1)
%   for every spectral band.
%
%   Additionally, the CVs of eight non-central pixels of the source
%   aperture (the pixels of the original analysis) and of all pixels in an
%   11 x 11 area around the central pixel are computed, to check the
%   statement that non-central pixels behave similarly. A Lilliefors
%   normality test is performed for every band (requires the Statistics
%   and Machine Learning Toolbox).
%
% Inputs:
%   - Raw captures 313-373 in '../data/rawData/hyperspectralImages/repeatability'
%
% Outputs:
%   - '../data/processedData/repeatability.mat'
%       .digitalCounts      (61 x 204) I(251, 262, k) of every capture
%       .timeMinutes        (61 x 1)   time since the first capture [min]
%       .wavelengthFactory  (204 x 1)  factory-set centre wavelengths [nm]
%       .pixel              (1 x 2)    pixel (i, j)
%   - '../data/processedData/repeatabilityStatistics.csv'
%       band number, wavelength, mean, standard deviation and CV per band
%   - '../data/processedData/repeatabilityNonCentralPixels.csv'
%       pixel (i, j), maximum CV and the band of the maximum, per non-central pixel
%
% Authors:
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%
% Last updated:
%   October-29-2026
%

function analyzeRepeatability

    % 0. SETUP
    % ===================================================================
    paths    = getProjectPaths();
    settings = getAnalysisSettings().repeatability;
    measurementFolder = fullfile(paths.hyperspectralImages, settings.folderName);

    numberOfCaptures = numel(settings.hsiNumbers);
    nonCentralPixels = settings.nonCentralPixels;
    numberOfNonCentralPixels = size(nonCentralPixels, 1);
    areaHalfWidth    = 5;                                   % 11 x 11 pixel area
    areaRows    = settings.pixel(1) + (-areaHalfWidth : areaHalfWidth);
    areaColumns = settings.pixel(2) + (-areaHalfWidth : areaHalfWidth);

    % 1. READ ALL CAPTURES
    % ===================================================================
    for captureIndex = 1 : numberOfCaptures
        fprintf('Reading capture %d (%d of %d)\n', settings.hsiNumbers(captureIndex), captureIndex, numberOfCaptures);
        [cube, wavelengthFactory] = readHyperspectralDataCube(measurementFolder, settings.hsiNumbers(captureIndex));

        if captureIndex == 1
            numberOfBands = size(cube, 3);
            digitalCounts = zeros(numberOfCaptures, numberOfBands);
            areaCounts    = zeros(numel(areaRows), numel(areaColumns), numberOfBands, numberOfCaptures);
            nonCentralCounts = zeros(numberOfCaptures, numberOfBands, numberOfNonCentralPixels);
        end
        digitalCounts(captureIndex, :) = reshape(cube(settings.pixel(1), settings.pixel(2), :), 1, []);
        for pixelIndex = 1 : numberOfNonCentralPixels
            nonCentralCounts(captureIndex, :, pixelIndex) = ...
                reshape(cube(nonCentralPixels(pixelIndex, 1), nonCentralPixels(pixelIndex, 2), :), 1, []);
        end
        areaCounts(:, :, :, captureIndex) = cube(areaRows, areaColumns, :);
    end
    timeMinutes = (0 : numberOfCaptures - 1)';   % one capture per minute

    % 2. STATISTICS OF THE CENTRAL PIXEL (Figure 3, Eq. 1)
    % ===================================================================
    meanCounts     = mean(digitalCounts, 1)';
    standardDeviation = std(digitalCounts, 0, 1)';
    coefficientOfVariation = standardDeviation ./ meanCounts * 100;   % [%]

    fprintf('Central pixel: maximum CV = %.2f %%\n', max(coefficientOfVariation));

    % 3. CV OF THE NON-CENTRAL PIXELS AND OF THE SURROUNDING 11 x 11 AREA
    % ===================================================================
    nonCentralCv = reshape(std(nonCentralCounts, 0, 1) ./ mean(nonCentralCounts, 1) * 100, ...
                           numberOfBands, numberOfNonCentralPixels);   % (bands x pixels) [%]
    [maximumNonCentralCv, bandOfMaximumCv] = max(nonCentralCv, [], 1);
    fprintf('Non-central pixels: maximum CV = %.2f %% at pixel (%d, %d)\n', max(maximumNonCentralCv), ...
            nonCentralPixels(maximumNonCentralCv == max(maximumNonCentralCv), :));

    areaCv = std(areaCounts, 0, 4) ./ mean(areaCounts, 4) * 100;
    fprintf('11 x 11 area around the central pixel: maximum CV = %.2f %%\n', max(areaCv(:)));

    % 4. NORMALITY TEST (Lilliefors), requires the Statistics Toolbox
    % ===================================================================
    isNotNormal = nan(numberOfBands, 1);
    if exist('lillietest', 'file') == 2
        for bandIndex = 1 : numberOfBands
            isNotNormal(bandIndex) = lillietest(digitalCounts(:, bandIndex), 'Alpha', settings.significance);
        end
        fprintf('Lilliefors test: %d of %d bands are not normally distributed (alpha = %.2f)\n', ...
                sum(isNotNormal), numberOfBands, settings.significance);
    else
        fprintf('lillietest not available: the normality test is skipped.\n');
    end

    % 5. SAVE
    % ===================================================================
    pixel = settings.pixel; %#ok<NASGU>
    save(fullfile(paths.processedData, 'repeatability.mat'), ...
         'digitalCounts', 'timeMinutes', 'wavelengthFactory', 'pixel', '-v7');

    bandNumber = (1 : numberOfBands)';
    writeNumericCsv(fullfile(paths.processedData, 'repeatabilityStatistics.csv'), ...
        {'bandNumber', 'wavelengthFactoryNm', 'meanCounts', 'standardDeviation', 'coefficientOfVariationPercent', 'lillieforsRejectsNormality'}, ...
        [bandNumber, wavelengthFactory, meanCounts, standardDeviation, coefficientOfVariation, isNotNormal]);

    writeNumericCsv(fullfile(paths.processedData, 'repeatabilityNonCentralPixels.csv'), ...
        {'pixelI', 'pixelJ', 'maximumCvPercent', 'bandOfMaximumCv'}, ...
        [nonCentralPixels, maximumNonCentralCv(:), bandOfMaximumCv(:)]);

    fprintf('Repeatability data saved to %s\n', paths.processedData);
end
