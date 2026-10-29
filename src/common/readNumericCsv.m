%% function readNumericCsv
%
% Description:
%   Reads a comma-separated file with one header line followed by numeric
%   rows. Text columns are returned as NaN. This small reader is used
%   instead of readtable so that the code also runs in GNU Octave.
%
% Inputs:
%   - filePath: path of the CSV file.
%
% Outputs:
%   - data:        (rows x columns double) numeric content.
%   - columnNames: (1 x columns cell) names from the header line.
%   - textColumns: (rows x columns cell) raw text of every cell.
%
% Authors:
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%
% Last updated:
%   October-29-2026
%

function [data, columnNames, textColumns] = readNumericCsv(filePath)

    fileId = fopen(filePath, 'r');
    if fileId < 0
        error('readNumericCsv:fileNotFound', 'Cannot open %s.', filePath);
    end
    cleanupObject = onCleanup(@() fclose(fileId));

    headerLine  = fgetl(fileId);
    columnNames = strtrim(strsplit(headerLine, ','));

    textColumns = {};
    rowIndex = 0;
    currentLine = fgetl(fileId);
    while ischar(currentLine)
        if ~isempty(strtrim(currentLine))
            rowIndex = rowIndex + 1;
            cells = strsplit(currentLine, ',');
            cells(end+1 : numel(columnNames)) = {''};   % pad short rows
            textColumns(rowIndex, :) = strtrim(cells(1 : numel(columnNames))); %#ok<AGROW>
        end
        currentLine = fgetl(fileId);
    end

    data = str2double(textColumns);
end
