%% function analyzeDarkCurrent
%
% Description:
%   Section 3.2 (Dark current). Nine dark frames were captured with the
%   lens cap on (t = 1, 5, 10, 50, 100, 200, 300, 400 and 500 ms).
%   This script stores the dark frame of band k = 100 for Figure 5 and
%   summarises all 9 x 512 x 512 x 204 dark values.
%
% Inputs:
%   - Raw captures 374-382 in '../data/rawData/hyperspectralImages/darkCurrent'
%
% Outputs:
%   - '../data/processedData/darkCurrent.mat'
%       .darkFrames         (512 x 512 x 9 uint16) dark frames of band k = 100
%       .integrationTimeMs  (1 x 9) integration times
%       .band               band number of the stored frames
%   - '../data/processedData/darkCurrentStatistics.csv'
%       per integration time: mean, standard deviation and the share of
%       values equal to 239 and 240; the last row contains all data.
%
% Authors:
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%
% Last updated:
%   October-29-2026
%

function analyzeDarkCurrent

    % 0. SETUP
    % ===================================================================
    paths    = getProjectPaths();
    settings = getAnalysisSettings().darkCurrent;
    measurementFolder = fullfile(paths.hyperspectralImages, settings.folderName);
    numberOfCaptures  = numel(settings.hsiNumbers);

    % 1. READ ALL DARK FRAMES
    % ===================================================================
    integrationTimeMs = zeros(1, numberOfCaptures);
    darkFrames  = zeros(512, 512, numberOfCaptures, 'uint16');
    statistics  = zeros(numberOfCaptures + 1, 5);   % [t, mean, std, share239, share240]
    sumOfValues = 0;  sumOfSquares = 0;  numberOfValues = 0;
    countOf239  = 0;  countOf240   = 0;

    for captureIndex = 1 : numberOfCaptures
        fprintf('Reading dark frame %d\n', settings.hsiNumbers(captureIndex));
        [cube, ~, integrationTimeMs(captureIndex)] = readHyperspectralDataCube(measurementFolder, settings.hsiNumbers(captureIndex));
        darkFrames(:, :, captureIndex) = uint16(cube(:, :, settings.bandToPlot));

        allValues = cube(:);
        statistics(captureIndex, :) = [integrationTimeMs(captureIndex), mean(allValues), std(allValues), ...
                                       mean(allValues == 239) * 100, mean(allValues == 240) * 100];

        % Running sums for the statistics over all nine frames
        sumOfValues    = sumOfValues  + sum(allValues);
        sumOfSquares   = sumOfSquares + sum(allValues .^ 2);
        numberOfValues = numberOfValues + numel(allValues);
        countOf239     = countOf239 + sum(allValues == 239);
        countOf240     = countOf240 + sum(allValues == 240);
    end

    % 2. STATISTICS OVER ALL DARK VALUES
    % ===================================================================
    overallMean = sumOfValues / numberOfValues;
    overallStd  = sqrt((sumOfSquares - numberOfValues * overallMean ^ 2) / (numberOfValues - 1));
    statistics(end, :) = [NaN, overallMean, overallStd, countOf239 / numberOfValues * 100, countOf240 / numberOfValues * 100];

    fprintf('All dark values: mean = %.2f, CV = %.2f %%\n', overallMean, overallStd / overallMean * 100);

    % 3. SAVE
    % ===================================================================
    band = settings.bandToPlot; %#ok<NASGU>
    save(fullfile(paths.processedData, 'darkCurrent.mat'), 'darkFrames', 'integrationTimeMs', 'band', '-v7');

    rowLabels = [arrayfun(@(t) sprintf('%d ms', t), integrationTimeMs, 'UniformOutput', false), {'all'}]';
    writeNumericCsv(fullfile(paths.processedData, 'darkCurrentStatistics.csv'), ...
        {'capture', 'integrationTimeMs', 'meanCounts', 'standardDeviation', 'percentEqualTo239', 'percentEqualTo240'}, ...
        statistics, rowLabels);

    fprintf('Dark current data saved to %s\n', paths.processedData);
end
