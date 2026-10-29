%% function writeNumericCsv
%
% Description:
%   Writes a numeric matrix to a CSV file with a header line. Used instead
%   of writetable so that the code also runs in GNU Octave.
%
% Inputs:
%   - filePath:    path of the CSV file to create.
%   - columnNames: (1 x columns cell) header names.
%   - data:        (rows x columns double) numeric values.
%   - rowLabels:   (optional, rows x 1 cell) text written as an extra first column.
%
% Authors:
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%
% Last updated:
%   October-29-2026
%

function writeNumericCsv(filePath, columnNames, data, rowLabels)

    hasRowLabels = nargin > 3 && ~isempty(rowLabels);
    expectedColumns = size(data, 2) + hasRowLabels;
    if numel(columnNames) ~= expectedColumns
        error('writeNumericCsv:size', 'Expected %d column names, got %d.', expectedColumns, numel(columnNames));
    end

    fileId = fopen(filePath, 'w');
    if fileId < 0
        error('writeNumericCsv:cannotWrite', 'Cannot create %s.', filePath);
    end
    cleanupObject = onCleanup(@() fclose(fileId));

    fprintf(fileId, '%s\n', strjoin(columnNames, ','));
    for rowIndex = 1 : size(data, 1)
        if hasRowLabels
            fprintf(fileId, '%s,', rowLabels{rowIndex});
        end
        % %.10g keeps full precision for small radiance values
        rowText = sprintf('%.10g,', data(rowIndex, :));
        fprintf(fileId, '%s\n', rowText(1 : end - 1));
    end
end
