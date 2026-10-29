%% function compareWithGroundTruth
%
% Description:
%   Radiometric, photometric and colorimetric comparison of reconstructed
%   spectra with the ground truth (Tables 2 and 3, Section 4.1):
%     - RMSE(400-780):  root mean square error of the spectral radiance at
%                       the Specim IQ bands between 400 and 780 nm; the
%                       ground truth is resampled to these bands,
%     - RMSEratio:      RMSE / mean ground-truth spectral radiance (400-780 nm) x 100 %,
%     - dLv, dLvRatio:  Lv,test - Lv,gt and dLv / Lv,gt x 100 %,
%     - du'v':          Euclidean distance in the CIE 1976 u'v' diagram.
%
% Inputs:
%   - wavelengthTest:  (N x 1) wavelengths of the reconstructed spectra [nm].
%   - radianceTest:    (N x M) reconstructed spectral radiance, one column per target.
%   - wavelengthTruth: (L x 1) wavelengths of the ground truth [nm].
%   - radianceTruth:   (L x M) ground-truth spectral radiance.
%
% Outputs:
%   - comparison: struct with (M x 1) fields .rmse, .rmseRatio, .deltaLuminance,
%                 .deltaLuminanceRatio, .deltaUvPrime and (M x 3) .xyzTest, .xyzTruth
%
% Authors:
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%
% Last updated:
%   October-29-2026
%

function comparison = compareWithGroundTruth(wavelengthTest, radianceTest, wavelengthTruth, radianceTruth)

    settings = getAnalysisSettings();
    cmfTable = loadColorMatchingFunctions();
    wavelengthRange = settings.rmseWavelengthRange;

    % 1. Radiometric comparison
    truthAtTestBands = interpolateSpectrum(wavelengthTruth, radianceTruth, wavelengthTest);
    inRangeTest  = wavelengthTest  >= wavelengthRange(1) & wavelengthTest  <= wavelengthRange(2);
    inRangeTruth = wavelengthTruth >= wavelengthRange(1) & wavelengthTruth <= wavelengthRange(2);

    comparison.rmse = sqrt(mean((radianceTest(inRangeTest, :) - truthAtTestBands(inRangeTest, :)) .^ 2, 1))';
    meanTruthRadiance = mean(radianceTruth(inRangeTruth, :), 1)';
    comparison.rmseRatio = comparison.rmse ./ meanTruthRadiance * 100;

    % 2. Photometric and colorimetric comparison (CIE 1931 2-degree observer)
    comparison.xyzTest  = computeTristimulusValues(wavelengthTest,  radianceTest,  cmfTable, settings.maximumLuminousEfficacy);
    comparison.xyzTruth = computeTristimulusValues(wavelengthTruth, radianceTruth, cmfTable, settings.maximumLuminousEfficacy);

    comparison.deltaLuminance      = comparison.xyzTest(:, 2) - comparison.xyzTruth(:, 2);
    comparison.deltaLuminanceRatio = comparison.deltaLuminance ./ comparison.xyzTruth(:, 2) * 100;

    uvTest  = convertXyzToUvPrime(comparison.xyzTest);
    uvTruth = convertXyzToUvPrime(comparison.xyzTruth);
    comparison.deltaUvPrime = sqrt(sum((uvTest - uvTruth) .^ 2, 2));
end
