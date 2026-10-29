%% function analyzeLinearity
%
% Description:
%   Section 3.2 (Linearity with integration time). An OLED panel was
%   captured with seven integration times (1, 5, 25, 100, 200, 215 and
%   235 ms). For ten pixels and six bands (k = 25 to 50 in steps of 5),
%   a straight line I = beta0 + beta1 * t (Eq. 2) is fitted.
%
%   The 60 intercepts beta0 are summarised (mean and CV) and decomposed
%   with a two-way ANOVA without replication into the contributions of
%   pixel position, band and their interaction (residual).
%
% Inputs:
%   - Raw captures 460-476 in '../data/rawData/hyperspectralImages/linearity'
%
% Outputs:
%   - '../data/processedData/linearity.mat'
%       .digitalCounts      (10 x 6 x 7) I(i, j, k) for pixels x bands x integration times
%       .integrationTimeMs  (1 x 7)  integration times read from the headers
%       .pixels             (10 x 2) pixel coordinates (i, j)
%       .bands              (1 x 6)  band numbers
%       .slopes, .intercepts (10 x 6) fitted beta1 and beta0
%   - '../data/processedData/linearityFitResults.csv'
%   - '../data/processedData/linearityInterceptStatistics.csv'
%
% Authors:
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%
% Last updated:
%   October-29-2026
%

function analyzeLinearity

    % 0. SETUP
    % ===================================================================
    paths    = getProjectPaths();
    settings = getAnalysisSettings().linearity;
    measurementFolder = fullfile(paths.hyperspectralImages, settings.folderName);

    pixels = settings.pixels;
    bands  = settings.bands;
    numberOfPixels   = size(pixels, 1);
    numberOfBands    = numel(bands);
    numberOfCaptures = numel(settings.hsiNumbers);

    % 1. EXTRACT THE DIGITAL COUNTS
    % ===================================================================
    digitalCounts     = zeros(numberOfPixels, numberOfBands, numberOfCaptures);
    integrationTimeMs = zeros(1, numberOfCaptures);
    for captureIndex = 1 : numberOfCaptures
        fprintf('Reading capture %d\n', settings.hsiNumbers(captureIndex));
        [cube, ~, integrationTimeMs(captureIndex)] = readHyperspectralDataCube(measurementFolder, settings.hsiNumbers(captureIndex));
        for pixelIndex = 1 : numberOfPixels
            digitalCounts(pixelIndex, :, captureIndex) = cube(pixels(pixelIndex, 1), pixels(pixelIndex, 2), bands);
        end
    end

    % 2. LINEAR FIT FOR EVERY PIXEL AND BAND (Eq. 2)
    % ===================================================================
    slopes     = zeros(numberOfPixels, numberOfBands);
    intercepts = zeros(numberOfPixels, numberOfBands);
    for pixelIndex = 1 : numberOfPixels
        for bandIndex = 1 : numberOfBands
            countsOverTime = reshape(digitalCounts(pixelIndex, bandIndex, :), 1, []);
            fitCoefficients = polyfit(integrationTimeMs, countsOverTime, 1);
            slopes(pixelIndex, bandIndex)     = fitCoefficients(1);
            intercepts(pixelIndex, bandIndex) = fitCoefficients(2);
        end
    end

    % 3. INTERCEPT STATISTICS AND TWO-WAY ANOVA (no replication)
    % ===================================================================
    meanIntercept = mean(intercepts(:));
    cvIntercept   = std(intercepts(:)) / meanIntercept * 100;

    pixelMeans = mean(intercepts, 2);
    bandMeans  = mean(intercepts, 1);
    sumOfSquaresTotal = sum((intercepts(:) - meanIntercept) .^ 2);
    sumOfSquaresPixel = numberOfBands  * sum((pixelMeans - meanIntercept) .^ 2);
    sumOfSquaresBand  = numberOfPixels * sum((bandMeans  - meanIntercept) .^ 2);
    sumOfSquaresInteraction = sumOfSquaresTotal - sumOfSquaresPixel - sumOfSquaresBand;

    fprintf('Mean intercept of the %d fitted lines: %.2f (CV = %.2f %%)\n', numel(intercepts), meanIntercept, cvIntercept);
    fprintf('ANOVA sums of squares: total %.0f = pixel %.0f + band %.0f + interaction %.0f\n', ...
            sumOfSquaresTotal, sumOfSquaresPixel, sumOfSquaresBand, sumOfSquaresInteraction);

    % 4. SAVE
    % ===================================================================
    save(fullfile(paths.processedData, 'linearity.mat'), ...
         'digitalCounts', 'integrationTimeMs', 'pixels', 'bands', 'slopes', 'intercepts', '-v7');

    [bandGrid, pixelGrid] = meshgrid(1 : numberOfBands, 1 : numberOfPixels);
    writeNumericCsv(fullfile(paths.processedData, 'linearityFitResults.csv'), ...
        {'pixelI', 'pixelJ', 'bandNumber', 'slopeCountsPerMs', 'interceptCounts'}, ...
        [pixels(pixelGrid(:), :), bands(bandGrid(:))', slopes(:), intercepts(:)]);

    writeNumericCsv(fullfile(paths.processedData, 'linearityInterceptStatistics.csv'), ...
        {'meanIntercept', 'cvInterceptPercent', 'sumOfSquaresTotal', 'sumOfSquaresPixel', 'sumOfSquaresBand', 'sumOfSquaresInteraction'}, ...
        [meanIntercept, cvIntercept, sumOfSquaresTotal, sumOfSquaresPixel, sumOfSquaresBand, sumOfSquaresInteraction]);

    fprintf('Linearity data saved to %s\n', paths.processedData);
end
