%% Verification of the reproduced results for the paper "Measuring Absolute Radiance by Calibrating a Hyperspectral Camera Economically"
% Journal
%   Color Research & Application
% DOI
%   10.1002/col.70043
%
% Description:
%   Checks that the results of this repository are reproduced on your
%   computer. Run it after runAllFigures (and, optionally, after
%   runAllAnalyses). It performs three checks:
%
%   1. Every numeric value in the processed data (/data/processedData/*.csv)
%      and in the generated tables (/output/table*.csv) is compared with
%      the reference results in /tests/referenceResults. A value passes if
%      its relative difference is below 1e-6 (or its absolute difference
%      below 1e-9). Reference values that are empty (NaN) are not checked;
%      this concerns the Lilliefors test, which needs the Statistics and
%      Machine Learning Toolbox.
%   2. All figures (fig2 ... fig15, TIFF and PNG) exist in /output.
%   3. If the raw hyperspectral images are present, the cube reader is
%      checked: in MATLAB, multibandread and a direct fread of the same
%      file must give identical digital counts.
%
%   A summary is printed and saved to /output/verificationLog.txt.
%
% Authors
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%

clear; close all; clc;
addpath(genpath(fullfile(fileparts(mfilename('fullpath')), 'src')));
paths = getProjectPaths();
referenceFolder = fullfile(paths.root, 'tests', 'referenceResults');
relativeTolerance = 1e-6;
absoluteTolerance = 1e-9;

logLines = {};
numberOfFailures = 0;
logLines{end+1} = sprintf('Verification run: %s', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
logLines{end+1} = sprintf('Software: %s', version);

% 1. COMPARE THE CSV FILES WITH THE REFERENCE RESULTS
% =======================================================================
logLines{end+1} = '';
logLines{end+1} = '1. Processed data and tables compared with /tests/referenceResults';
referenceFiles = [dir(fullfile(referenceFolder, 'processedData', '*.csv')); ...
                  dir(fullfile(referenceFolder, 'output', '*.csv'))];
for fileIndex = 1 : numel(referenceFiles)
    referencePath = fullfile(referenceFiles(fileIndex).folder, referenceFiles(fileIndex).name);
    [~, subfolderName] = fileparts(referenceFiles(fileIndex).folder);
    if strcmp(subfolderName, 'output')
        resultPath = fullfile(paths.output, referenceFiles(fileIndex).name);
    else
        resultPath = fullfile(paths.processedData, referenceFiles(fileIndex).name);
    end
    shownName = [subfolderName, '/', referenceFiles(fileIndex).name];

    if ~exist(resultPath, 'file')
        status = 'FAIL  (file not found; run runAllFigures first)';
    else
        referenceValues = readNumericCsv(referencePath);
        resultValues    = readNumericCsv(resultPath);
        if ~isequal(size(referenceValues), size(resultValues))
            status = sprintf('FAIL  (size %s, expected %s)', mat2str(size(resultValues)), mat2str(size(referenceValues)));
        else
            isChecked  = ~isnan(referenceValues);
            difference = abs(resultValues(isChecked) - referenceValues(isChecked));
            allowed    = max(absoluteTolerance, relativeTolerance * abs(referenceValues(isChecked)));
            isFailed   = ~(difference <= allowed);   % also fails on NaN results
            if any(isFailed)
                relativeDifference = difference ./ max(abs(referenceValues(isChecked)), eps);
                status = sprintf('FAIL  (%d of %d values differ; largest relative difference %.2g)', ...
                                 sum(isFailed), numel(isFailed), max(relativeDifference(isFailed)));
            else
                status = sprintf('ok    (%d values)', numel(difference));
            end
        end
    end
    numberOfFailures = numberOfFailures + strncmp(status, 'FAIL', 4);
    logLines{end+1} = sprintf('   %-50s %s', shownName, status); %#ok<SAGROW>
end

% 2. CHECK THAT ALL FIGURES EXIST
% =======================================================================
logLines{end+1} = '';
logLines{end+1} = '2. Figures in /output';
for figureNumber = [2 : 11, 14, 15]
    for extension = {'.tif', '.png'}
        figurePath = fullfile(paths.output, sprintf('fig%d%s', figureNumber, extension{1}));
        if exist(figurePath, 'file')
            status = 'ok';
        else
            status = 'FAIL  (not found; run runAllFigures first)';
            numberOfFailures = numberOfFailures + 1;
        end
        logLines{end+1} = sprintf('   %-50s %s', sprintf('fig%d%s', figureNumber, extension{1}), status); %#ok<SAGROW>
    end
end

% 3. CHECK THE CUBE READER (only if the raw data are present)
% =======================================================================
logLines{end+1} = '';
logLines{end+1} = '3. Reader of the raw hyperspectral images';
settings = getAnalysisSettings().repeatability;
measurementFolder = fullfile(paths.hyperspectralImages, settings.folderName);
hsiNumber = settings.hsiNumbers(1);
rawPath = fullfile(measurementFolder, num2str(hsiNumber), 'capture', [num2str(hsiNumber), '.raw']);
isOctave = exist('OCTAVE_VERSION', 'builtin') > 0;
if ~exist(rawPath, 'file')
    logLines{end+1} = '   skipped (raw hyperspectral images not downloaded)';
else
    camera = loadCameraSpecificData();
    dataCube = readHyperspectralDataCube(measurementFolder, hsiNumber);

    % Independent read of the same file with fread
    fileId = fopen(rawPath, 'r', 'ieee-le');
    rawStream = fread(fileId, inf, 'uint16=>double');
    fclose(fileId);
    freadCube = permute(reshape(rawStream, [camera.numberOfSamples, camera.numberOfBands, camera.numberOfLines]), [3, 1, 2]);

    if isOctave
        readerName = 'fread (Octave)';
    else
        readerName = 'multibandread';
    end
    if isequal(dataCube, freadCube)
        status = sprintf('ok    (%s and fread give identical counts for capture %d)', readerName, hsiNumber);
    else
        status = sprintf('FAIL  (%s and fread differ for capture %d)', readerName, hsiNumber);
        numberOfFailures = numberOfFailures + 1;
    end
    logLines{end+1} = ['   ', status];
    logLines{end+1} = sprintf('   I(%d, %d, 100) of capture %d = %d (expected 1964)', ...
                              settings.pixel(1), settings.pixel(2), hsiNumber, dataCube(settings.pixel(1), settings.pixel(2), 100));
end

% 4. SUMMARY
% =======================================================================
logLines{end+1} = '';
if numberOfFailures == 0
    logLines{end+1} = 'RESULT: all checks passed.';
else
    logLines{end+1} = sprintf('RESULT: %d check(s) failed. Please send /output/verificationLog.txt to x.kong@tue.nl.', numberOfFailures);
end

fprintf('%s\n', logLines{:});
fileId = fopen(fullfile(paths.output, 'verificationLog.txt'), 'w');
fprintf(fileId, '%s\n', logLines{:});
fclose(fileId);
