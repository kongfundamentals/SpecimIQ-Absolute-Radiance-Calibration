%% function analyzeFlatFieldBehavior
%
% Description:
%   Section 3.3 (Spatial responsivity uniformity). The calibration source
%   was captured at five positions of the field of view (t = 1 ms). For two
%   bands (k = 55 and 100), the digital counts of an 11 x 11 pixel area at
%   the centre of the source aperture are extracted at every position, and
%   normalised to the mean of the central position.
%
%   Because all captures use the same integration time (t = 1 ms), the
%   ratio of the dark corrected counts I'(i, j, k) = I(i, j, k) - 239
%   equals the ratio of the gains beta1(i, j) (Eq. 3). These ratios are
%   shown in Figure 7. The ratios of the raw counts (without dark
%   correction) are stored as well for comparison.
%
%   A zoomed image of the source at the centre position is stored for
%   Figure 6b.
%
% Inputs:
%   - Raw captures 222, 224-227 in '../data/rawData/hyperspectralImages/flatFieldBehavior'
%
% Outputs:
%   - '../data/processedData/flatFieldBehavior.mat'
%       .ratios                (121 x 5 x 2) beta1(i, j) / mean beta1 at the centre position
%       .ratiosRawCounts       (121 x 5 x 2) the same without dark correction
%       .centerPixels, .positionNames, .bands, .halfWidth
%       .zoomImage             zoomed band image around the centre position (Figure 6b)
%       .zoomRows, .zoomColumns pixel indices of the zoomed image
%   - '../data/processedData/flatFieldBehaviorStatistics.csv'
%
% Authors:
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%
% Last updated:
%   October-29-2026
%

function analyzeFlatFieldBehavior

    % 0. SETUP
    % ===================================================================
    paths       = getProjectPaths();
    allSettings = getAnalysisSettings();
    camera      = loadCameraSpecificData();
    settings    = allSettings.flatFieldBehavior;
    darkOffset  = camera.darkOffset;
    measurementFolder = fullfile(paths.hyperspectralImages, settings.folderName);

    centerPixels  = settings.centerPixels;
    positionNames = settings.positionNames;
    bands         = settings.bands;
    halfWidth     = settings.halfWidth;
    numberOfPositions = numel(settings.hsiNumbers);
    numberOfPixelsInArea = (2 * halfWidth + 1) ^ 2;

    % 1. EXTRACT THE 11 x 11 AREAS
    % ===================================================================
    areaCounts = zeros(numberOfPixelsInArea, numberOfPositions, numel(bands));
    for positionIndex = 1 : numberOfPositions
        hsiNumber = settings.hsiNumbers(positionIndex);
        fprintf('Reading capture %d (%s)\n', hsiNumber, positionNames{positionIndex});
        cube = readHyperspectralDataCube(measurementFolder, hsiNumber);

        areaRows    = centerPixels(positionIndex, 1) + (-halfWidth : halfWidth);
        areaColumns = centerPixels(positionIndex, 2) + (-halfWidth : halfWidth);
        for bandIndex = 1 : numel(bands)
            areaImage = cube(areaRows, areaColumns, bands(bandIndex));
            areaCounts(:, positionIndex, bandIndex) = areaImage(:);
        end

        % Zoomed image of the source at the centre position (Figure 6b)
        if positionIndex == 1
            zoomRows    = centerPixels(1, 1) + (-settings.zoomHalfWidth : settings.zoomHalfWidth);
            zoomColumns = centerPixels(1, 2) + (-settings.zoomHalfWidth : settings.zoomHalfWidth);
            zoomImage   = cube(zoomRows, zoomColumns, settings.bandForImage);
        end
    end

    % 2. NORMALISE TO THE MEAN OF THE CENTRE POSITION
    % ===================================================================
    ratios          = zeros(size(areaCounts));
    ratiosRawCounts = zeros(size(areaCounts));
    for bandIndex = 1 : numel(bands)
        centerMean = mean(areaCounts(:, 1, bandIndex));
        ratios(:, :, bandIndex)          = (areaCounts(:, :, bandIndex) - darkOffset) / (centerMean - darkOffset);
        ratiosRawCounts(:, :, bandIndex) = areaCounts(:, :, bandIndex) / centerMean;
    end

    meanRatios          = reshape(mean(ratios, 1), numberOfPositions, numel(bands));
    meanRatiosRawCounts = reshape(mean(ratiosRawCounts, 1), numberOfPositions, numel(bands));
    fprintf('Mean beta1 ratios (dark corrected): %s\n', mat2str(round(meanRatios(:)' * 1000) / 1000));
    fprintf('Mean ratios of the raw counts:      %s\n', mat2str(round(meanRatiosRawCounts(:)' * 1000) / 1000));

    % 3. SAVE
    % ===================================================================
    save(fullfile(paths.processedData, 'flatFieldBehavior.mat'), 'ratios', 'ratiosRawCounts', ...
         'centerPixels', 'positionNames', 'bands', 'halfWidth', 'zoomImage', 'zoomRows', 'zoomColumns', '-v7');

    [bandGrid, positionGrid] = meshgrid(1 : numel(bands), 1 : numberOfPositions);
    writeNumericCsv(fullfile(paths.processedData, 'flatFieldBehaviorStatistics.csv'), ...
        {'position', 'bandNumber', 'meanRatio', 'minimumRatio', 'maximumRatio', 'meanRatioRawCounts'}, ...
        [bands(bandGrid(:))', meanRatios(:), ...
         reshape(min(ratios, [], 1), [], 1), reshape(max(ratios, [], 1), [], 1), meanRatiosRawCounts(:)], ...
        positionNames(positionGrid(:))');

    fprintf('Spatial uniformity data saved to %s\n', paths.processedData);
end
