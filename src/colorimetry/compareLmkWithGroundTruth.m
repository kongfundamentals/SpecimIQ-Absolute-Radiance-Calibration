%% function compareLmkWithGroundTruth
%
% Description:
%   Photometric and colorimetric comparison of the calibrated LMK 6-5
%   colour camera with the ground truth (right part of Tables 2 and 3).
%   The LMK region means (exported from the LMK LabSoft software) are
%   averaged over all images in which the region was evaluated.
%
% Inputs:
%   - lmkFilePath: path of an LMK region-mean file (columns image, region, areaPixels, X, Y, Z).
%   - regionNumbers: (M x 1) LMK region numbers, in the order of the targets.
%   - xyzTruth:    (M x 3) ground-truth tristimulus values (from the JETI spectra).
%
% Outputs:
%   - comparison: struct with (M x 1) fields .deltaLuminance, .deltaLuminanceRatio,
%                 .deltaUvPrime and (M x 3) .xyzLmk
%
% Authors:
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%
% Last updated:
%   October-29-2026
%

function comparison = compareLmkWithGroundTruth(lmkFilePath, regionNumbers, xyzTruth)

    [lmkTable, columnNames] = readNumericCsv(lmkFilePath);
    regionColumn = lmkTable(:, strcmp(columnNames, 'region'));
    xyzColumns   = lmkTable(:, ismember(columnNames, {'X', 'Y', 'Z'}));

    numberOfTargets = numel(regionNumbers);
    comparison.xyzLmk = zeros(numberOfTargets, 3);
    for targetIndex = 1 : numberOfTargets
        comparison.xyzLmk(targetIndex, :) = mean(xyzColumns(regionColumn == regionNumbers(targetIndex), :), 1);
    end

    comparison.deltaLuminance      = comparison.xyzLmk(:, 2) - xyzTruth(:, 2);
    comparison.deltaLuminanceRatio = comparison.deltaLuminance ./ xyzTruth(:, 2) * 100;
    comparison.deltaUvPrime = sqrt(sum((convertXyzToUvPrime(comparison.xyzLmk) - convertXyzToUvPrime(xyzTruth)) .^ 2, 2));
end
