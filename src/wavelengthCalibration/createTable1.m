%% function createTable1
%
% Description:
%   Generates Table 1 of the publication: the comparison between the
%   measured (factory-set) and the theoretical peaks of a helium lamp.
%   The FWHM of every peak (Section 3.4) is added as an extra column.
%
% Inputs:
%   - Reads data from: '../data/processedData/heliumPeaks.csv'
%
% Outputs:
%   - Saves the table to: '../output/table1_heliumPeaks.csv'
%
% Authors:
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%
% Last updated:
%   October-29-2026
%

function createTable1

    paths = getProjectPaths();
    [peakTable, columnNames] = readNumericCsv(fullfile(paths.processedData, 'heliumPeaks.csv'));
    getColumn = @(name) peakTable(:, strcmp(columnNames, name));

    measuredPeak    = getColumn('measuredPeakNm');
    theoreticalPeak = getColumn('theoreticalPeakNm');
    discrepancy     = getColumn('discrepancyNm');
    fwhm            = getColumn('fwhmNm');
    numberOfPeaks   = numel(measuredPeak);

    tableValues = [(1 : numberOfPeaks)', measuredPeak, theoreticalPeak, discrepancy, fwhm; ...
                   NaN, NaN, NaN, mean(discrepancy), mean(fwhm)];
    rowLabels   = [arrayfun(@num2str, 1 : numberOfPeaks, 'UniformOutput', false), {'Average'}]';

    writeNumericCsv(fullfile(paths.output, 'table1_heliumPeaks.csv'), ...
        {'row', 'number', 'measuredFactorySetPeakNm', 'theoreticalPeakNm', 'discrepancyNm', 'fwhmNm'}, ...
        tableValues, rowLabels);

    % Print the table in the layout of the paper
    fprintf('\nTable 1. Measured and theoretical peaks of a helium lamp\n');
    fprintf('%-8s %12s %12s %12s %10s\n', 'No.', 'Measured', 'Theoretical', 'Discrepancy', 'FWHM');
    for peakIndex = 1 : numberOfPeaks
        fprintf('%-8d %12.2f %12.1f %+12.2f %10.2f\n', peakIndex, measuredPeak(peakIndex), ...
                theoreticalPeak(peakIndex), discrepancy(peakIndex), fwhm(peakIndex));
    end
    fprintf('%-8s %12s %12s %+12.2f %10.2f\n', 'Average', '', '', mean(discrepancy), mean(fwhm));
    fprintf('Table saved to: %s\n', fullfile(paths.output, 'table1_heliumPeaks.csv'));
end
