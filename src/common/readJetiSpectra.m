%% function readJetiSpectra
%
% Description:
%   Reads spectral radiance data measured with the JETI Specbos 1211L
%   spectroradiometer. Three file layouts occur in this dataset:
%
%   1) 'lival'  - export of the JETI LiVal software: a block of metadata
%                 rows, then a row starting with "Wavelength [nm]", then one
%                 row per wavelength with one column per measurement
%                 (radianceCalibration_jeti.csv and oledValidation_jeti.csv).
%   2) 'rows'   - two rows: wavelengths in the first row and the spectral
%                 radiance in the second row (colorCheckerValidation_calibrationSource_jeti.csv,
%                 written by the JETI control script used on that day).
%   3) 'table'  - first row: a label followed by the wavelengths; every
%                 next row: a patch index followed by its spectral radiance
%                 (colorCheckerValidation_patches_jetiAverage.csv).
%
%   The layout is detected automatically.
%
% Inputs:
%   - filePath: path of the JETI file.
%
% Outputs:
%   - wavelength:       (N x 1 double) wavelengths [nm].
%   - spectralRadiance: (N x M double) spectral radiance [W/(m^2 sr nm)],
%                       one column per measurement (or per patch).
%
% Authors:
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%
% Last updated:
%   October-29-2026
%

function [wavelength, spectralRadiance] = readJetiSpectra(filePath)

    allLines = strsplit(fileread(filePath), {'\r\n', '\n'});
    allLines = allLines(~cellfun(@(textLine) isempty(strtrim(textLine)), allLines));

    wavelengthRow = find(strncmp(allLines, 'Wavelength [nm]', 15), 1);

    if ~isempty(wavelengthRow)
        % ----- Layout 1: JETI LiVal export -----
        dataLines = allLines(wavelengthRow + 1 : end);
        values = parseNumericLines(dataLines);
        wavelength       = values(:, 1);
        spectralRadiance = values(:, 2 : end);

    else
        firstRow = str2double(strsplit(allLines{1}, ','));
        if all(~isnan(firstRow))
            % ----- Layout 2: wavelengths in row 1, radiance in row 2 -----
            values = parseNumericLines(allLines(1 : 2));
            wavelength       = values(1, :)';
            spectralRadiance = values(2, :)';
        else
            % ----- Layout 3: label + wavelengths, then index + radiance -----
            values = parseNumericLines(allLines);
            wavelength       = values(1, 2 : end)';
            spectralRadiance = values(2 : end, 2 : end)';
        end
    end

    % Some exports end with an empty trailing column
    validColumns     = ~all(isnan(spectralRadiance), 1);
    spectralRadiance = spectralRadiance(:, validColumns);
end


%% LOCAL FUNCTION: parseNumericLines
% Converts comma-separated text lines to a numeric matrix (NaN for text).
function values = parseNumericLines(textLines)
    splitLines = cellfun(@(textLine) strsplit(textLine, ','), textLines, 'UniformOutput', false);
    numberOfColumns = max(cellfun(@numel, splitLines));
    values = nan(numel(splitLines), numberOfColumns);
    for lineIndex = 1 : numel(splitLines)
        rowValues = str2double(splitLines{lineIndex});
        values(lineIndex, 1 : numel(rowValues)) = rowValues;
    end
end
