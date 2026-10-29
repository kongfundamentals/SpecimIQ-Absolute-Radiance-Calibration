%% function createTable2
%
% Description:
%   Generates Table 2 of the publication: radiometric, photometric and
%   colorimetric differences of the reconstructed OLED spectral radiance
%   (Specim IQ) and of the calibrated LMK colour camera compared with the
%   ground truth (JETI) at five spots of the OLED panel.
%
% Inputs:
%   - Reads data from: '../data/processedData/oledRadianceSpecim.csv'
%                      '../data/processedData/oledRadianceJeti.csv'
%                      '../data/rawData/colorCamera/oledValidation_lmkRegionMeans.csv'
%
% Outputs:
%   - Saves the table to: '../output/table2_oledValidation.csv'
%
% Authors:
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%
% Last updated:
%   October-29-2026
%

function createTable2

    % 0. SETUP
    % ===================================================================
    paths    = getProjectPaths();
    settings = getAnalysisSettings().oledValidation;
    spotLabels = {'Top-left', 'Top-right', 'Center', 'Bottom-left', 'Bottom-right'};

    % 1. LOAD THE SPECTRA
    % ===================================================================
    [specimTable, specimColumns] = readNumericCsv(fullfile(paths.processedData, 'oledRadianceSpecim.csv'));
    [jetiTable, jetiColumns]     = readNumericCsv(fullfile(paths.processedData, 'oledRadianceJeti.csv'));

    wavelengthCorrected = specimTable(:, strcmp(specimColumns, 'wavelengthCorrectedNm'));
    radianceSpecim      = specimTable(:, ismember(specimColumns, strcat(settings.spotNames, '_wavelengthCorrected')));
    wavelengthJeti      = jetiTable(:, 1);
    radianceJeti        = jetiTable(:, ismember(jetiColumns, settings.spotNames));

    % 2. COMPARE WITH THE GROUND TRUTH
    % ===================================================================
    specim = compareWithGroundTruth(wavelengthCorrected, radianceSpecim, wavelengthJeti, radianceJeti);
    lmk    = compareLmkWithGroundTruth(fullfile(paths.colorCamera, settings.lmkFile), ...
                                       settings.lmkRegions, specim.xyzTruth);

    % RMSE in mW/(m^2 sr nm), as in the paper
    tableValues = [specim.rmse * 1e3, specim.rmseRatio, specim.deltaLuminance, specim.deltaLuminanceRatio, ...
                   specim.deltaUvPrime, lmk.deltaLuminance, lmk.deltaLuminanceRatio, lmk.deltaUvPrime];
    tableValues = [tableValues; mean(tableValues, 1)];
    rowLabels   = [spotLabels, {'Average'}]';

    % 3. SAVE AND PRINT
    % ===================================================================
    writeNumericCsv(fullfile(paths.output, 'table2_oledValidation.csv'), ...
        {'position', 'specim_rmse400to780_mWPerM2SrNm', 'specim_rmseRatioPercent', 'specim_deltaLv_cdPerM2', ...
         'specim_deltaLvRatioPercent', 'specim_deltaUvPrime', 'lmk_deltaLv_cdPerM2', 'lmk_deltaLvRatioPercent', 'lmk_deltaUvPrime'}, ...
        tableValues, rowLabels);

    fprintf('\nTable 2. OLED validation (Specim IQ | calibrated LMK colour camera)\n');
    fprintf('%-13s %8s %8s %8s %8s %9s | %8s %8s %9s\n', 'Position', 'RMSE', 'RMSE%', 'dLv', 'dLv%', 'du''v''', 'dLv', 'dLv%', 'du''v''');
    for rowIndex = 1 : size(tableValues, 1)
        fprintf('%-13s %8.3f %8.2f %8.1f %8.2f %9.5f | %8.1f %8.2f %9.5f\n', rowLabels{rowIndex}, tableValues(rowIndex, :));
    end
    fprintf('Table saved to: %s\n', fullfile(paths.output, 'table2_oledValidation.csv'));
end
