%% function createTable3
%
% Description:
%   Generates Table 3 of the publication: radiometric, photometric and
%   colorimetric differences of the reconstructed spectral radiance of the
%   24 Macbeth ColorChecker patches (Specim IQ) and of the calibrated LMK
%   colour camera compared with the ground truth (JETI).
%
%   In addition to Table 2, the CIELAB colour difference dE*ab is given,
%   using the white patch (No. 19) measured with the JETI as the reference
%   white for both the test and the ground truth (Raza et al., 2022).
%
% Inputs:
%   - Reads data from: '../data/processedData/colorCheckerRadianceSpecim.csv'
%                      '../data/rawData/spectroradiometer/colorCheckerValidation_patches_jetiAverage.csv'
%                      '../data/rawData/colorCamera/colorCheckerValidation_lmkRegionMeans.csv'
%
% Outputs:
%   - Saves the table to: '../output/table3_colorCheckerValidation.csv'
%
% Authors:
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%
% Last updated:
%   October-29-2026
%

function createTable3

    % 0. SETUP
    % ===================================================================
    paths    = getProjectPaths();
    settings = getAnalysisSettings().colorCheckerValidation;
    numberOfPatches = numel(settings.patchNames);

    % 1. LOAD THE SPECTRA
    % ===================================================================
    [specimTable, specimColumns] = readNumericCsv(fullfile(paths.processedData, 'colorCheckerRadianceSpecim.csv'));
    wavelengthCorrected = specimTable(:, strcmp(specimColumns, 'wavelengthCorrectedNm'));
    radianceSpecim      = specimTable(:, strncmp(specimColumns, 'patch', 5));
    [wavelengthJeti, radianceJeti] = readJetiSpectra(fullfile(paths.spectroradiometer, settings.patchJetiFile));

    % 2. COMPARE WITH THE GROUND TRUTH
    % ===================================================================
    specim = compareWithGroundTruth(wavelengthCorrected, radianceSpecim, wavelengthJeti, radianceJeti);
    lmk    = compareLmkWithGroundTruth(fullfile(paths.colorCamera, settings.lmkFile), ...
                                       settings.lmkRegions, specim.xyzTruth);

    % CIELAB difference with the JETI white patch as reference white
    referenceWhite = specim.xyzTruth(settings.whitePatch, :);
    deltaEab = sqrt(sum((convertXyzToCielab(specim.xyzTest, referenceWhite) ...
                       - convertXyzToCielab(specim.xyzTruth, referenceWhite)) .^ 2, 2));

    % RMSE in uW/(m^2 sr nm), as in the paper
    tableValues = [(1 : numberOfPatches)', specim.rmse * 1e6, specim.rmseRatio, specim.deltaLuminance, ...
                   specim.deltaLuminanceRatio, specim.deltaUvPrime, deltaEab, ...
                   lmk.deltaLuminance, lmk.deltaLuminanceRatio, lmk.deltaUvPrime];
    tableValues = [tableValues; NaN, mean(tableValues(:, 2 : end), 1)];
    rowLabels   = [settings.patchNames, {'Average'}]';

    isNotBlack = (1 : numberOfPatches) ~= numberOfPatches;
    fprintf('\nAverage RMSEratio without the black patch: %.2f %%\n', mean(specim.rmseRatio(isNotBlack)));

    % 3. SAVE AND PRINT
    % ===================================================================
    writeNumericCsv(fullfile(paths.output, 'table3_colorCheckerValidation.csv'), ...
        {'color', 'sampleNumber', 'specim_rmse400to780_uWPerM2SrNm', 'specim_rmseRatioPercent', 'specim_deltaLv_cdPerM2', ...
         'specim_deltaLvRatioPercent', 'specim_deltaUvPrime', 'specim_deltaEab', ...
         'lmk_deltaLv_cdPerM2', 'lmk_deltaLvRatioPercent', 'lmk_deltaUvPrime'}, ...
        tableValues, rowLabels);

    fprintf('\nTable 3. ColorChecker validation (Specim IQ | calibrated LMK colour camera)\n');
    fprintf('%-4s %-15s %6s %7s %7s %7s %7s %6s | %7s %7s %7s\n', 'No.', 'Color', 'RMSE', 'RMSE%', 'dLv', 'dLv%', 'du''v''', 'dE*ab', 'dLv', 'dLv%', 'du''v''');
    for rowIndex = 1 : size(tableValues, 1)
        fprintf('%-4s %-15s %6.1f %7.1f %7.2f %7.1f %7.4f %6.1f | %7.2f %7.1f %7.4f\n', ...
                num2str(tableValues(rowIndex, 1)), rowLabels{rowIndex}, tableValues(rowIndex, 2 : end));
    end
    fprintf('Table saved to: %s\n', fullfile(paths.output, 'table3_colorCheckerValidation.csv'));
end
