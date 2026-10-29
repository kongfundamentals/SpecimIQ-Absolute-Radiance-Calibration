%% function readRegionsOfInterest
%
% Description:
%   Returns the rectangular pixel regions of one measurement from
%   /data/rawData/regionsOfInterest/regionsOfInterest.csv.
%   Every region is given as inclusive pixel index ranges in the cube
%   orientation of readHyperspectralDataCube: rows iMin:iMax and columns jMin:jMax.
%
% Inputs:
%   - measurementName: name in the 'measurement' column (e.g. 'oledValidation').
%
% Outputs:
%   - regions: struct array with fields .name, .iRange, .jRange, .description.
%
% Authors:
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%
% Last updated:
%   October-29-2026
%

function regions = readRegionsOfInterest(measurementName)

    paths = getProjectPaths();
    [data, columnNames, textColumns] = readNumericCsv(fullfile(paths.regionsOfInterest, 'regionsOfInterest.csv'));

    measurementColumn = strcmp(columnNames, 'measurement');
    nameColumn        = strcmp(columnNames, 'regionName');
    descriptionColumn = strcmp(columnNames, 'description');
    iMin = data(:, strcmp(columnNames, 'iMin'));
    iMax = data(:, strcmp(columnNames, 'iMax'));
    jMin = data(:, strcmp(columnNames, 'jMin'));
    jMax = data(:, strcmp(columnNames, 'jMax'));

    selectedRows = find(strcmp(textColumns(:, measurementColumn), measurementName));
    if isempty(selectedRows)
        error('readRegionsOfInterest:notFound', 'No regions defined for "%s".', measurementName);
    end

    regions = struct('name', {}, 'iRange', {}, 'jRange', {}, 'description', {});
    for regionIndex = 1 : numel(selectedRows)
        row = selectedRows(regionIndex);
        regions(regionIndex).name        = textColumns{row, nameColumn};
        regions(regionIndex).iRange      = iMin(row) : iMax(row);
        regions(regionIndex).jRange      = jMin(row) : jMax(row);
        regions(regionIndex).description = textColumns{row, descriptionColumn};
    end
end
