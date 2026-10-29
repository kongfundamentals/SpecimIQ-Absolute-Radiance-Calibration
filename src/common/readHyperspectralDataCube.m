%% function readHyperspectralDataCube
%
% Description:
%   Reads one raw hyperspectral data cube captured by the Specim IQ camera.
%   Specim IQ stores every capture as an ENVI file pair (.hdr + .raw) in
%   the folder <hsiNumber>/capture/. The ENVI format is a flat binary
%   raster file with an accompanying ASCII header file
%   (https://www.nv5geospatialsoftware.com/docs/ENVIImageFiles.html).
%   The data can be stored in three interleave types:
%     - BSQ (band sequential): all lines of band 1, then all lines of band 2, ...
%     - BIP (band interleaved by pixel): all bands of pixel 1, then of pixel 2, ...
%     - BIL (band interleaved by line): line 1 of every band, then line 2 of every band, ...
%   Specim IQ uses BIL, with 12-bit digital counts stored as little-endian
%   unsigned 16-bit integers.
%
%   In MATLAB the cube is read with multibandread. GNU Octave has no
%   multibandread, so there the same BIL stream is read with fread. Both
%   give identical results: dataCube(i, j, k), where i is the line index,
%   j the sample index and k the band number. All pixel coordinates (i, j)
%   quoted in the paper refer to this orientation.
%
% Inputs:
%   - measurementFolder: Folder that contains the numbered capture folders
%                        (e.g. '.../hyperspectralImages/repeatability').
%   - hsiNumber:         Capture number assigned by Specim IQ (e.g. 313).
%                        Example: hsiNumber 313 refers to the file
%                        <measurementFolder>/313/capture/313.raw
%
% Outputs:
%   - dataCube:           (512 x 512 x 204 double) raw digital counts I(i, j, k).
%   - wavelengthFactory:  (204 x 1 double) factory-set centre wavelength of each band [nm].
%   - integrationTimeMs:  (double) integration time of the capture [ms].
%
% Authors:
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%
% Last updated:
%   October-29-2026
%

function [dataCube, wavelengthFactory, integrationTimeMs] = readHyperspectralDataCube(measurementFolder, hsiNumber)

    captureName = num2str(hsiNumber);
    headerPath  = fullfile(measurementFolder, captureName, 'capture', [captureName, '.hdr']);
    rawPath     = fullfile(measurementFolder, captureName, 'capture', [captureName, '.raw']);
    if ~exist(rawPath, 'file')
        error('readHyperspectralDataCube:fileNotFound', ...
            'Cannot find %s. Did you download and unzip the raw data from Zenodo? See README.md.', rawPath);
    end

    % 1. READ THE ENVI HEADER AND CHECK IT AGAINST THE CAMERA CONSTANTS
    % ======================================================
    header = readEnviHeader(headerPath);
    camera = loadCameraSpecificData();
    if ~strcmpi(header.interleave, 'bil') || header.dataType ~= 12 || ...
       header.lines ~= camera.numberOfLines || header.samples ~= camera.numberOfSamples || header.bands ~= camera.numberOfBands
        error('readHyperspectralDataCube:unexpectedFormat', ...
            'The header %s does not describe a 512 x 512 x 204 uint16 BIL cube.', headerPath);
    end

    % 2. READ THE BINARY DATA
    % ======================================================
    isOctave = exist('OCTAVE_VERSION', 'builtin') > 0;
    if ~isOctave
        % MATLAB: size is [lines, samples, bands]; header offset 0 bytes
        dataCube = multibandread(rawPath, [header.lines, header.samples, header.bands], ...
                                 'uint16=>double', 0, 'bil', 'ieee-le');
    else
        % GNU Octave: in BIL order the sample index runs fastest, then the band, then the line
        fileId    = fopen(rawPath, 'r', 'ieee-le');
        rawStream = fread(fileId, header.samples * header.bands * header.lines, 'uint16=>double');
        fclose(fileId);
        dataCube = reshape(rawStream, [header.samples, header.bands, header.lines]);
        dataCube = permute(dataCube, [3, 1, 2]);   % -> (line, sample, band)
    end

    wavelengthFactory = header.wavelength(:);
    integrationTimeMs = header.integrationTimeMs;
end


%% LOCAL FUNCTION: readEnviHeader
% Parses the few ENVI header fields needed for reading a Specim IQ cube.
function header = readEnviHeader(headerPath)

    headerText = fileread(headerPath);

    header.samples    = readNumericField(headerText, 'samples');
    header.lines      = readNumericField(headerText, 'lines');
    header.bands      = readNumericField(headerText, 'bands');
    header.dataType   = readNumericField(headerText, 'data type');
    header.interleave = strtrim(readTextField(headerText, 'interleave'));

    % Specim IQ writes the integration time as "tint = <ms>"
    header.integrationTimeMs = readNumericField(headerText, 'tint');

    % The wavelength list is written between curly brackets
    wavelengthToken = regexp(headerText, 'wavelength\s*=\s*\{([^}]*)\}', 'tokens', 'once');
    header.wavelength = str2double(strsplit(wavelengthToken{1}, ','));
end


function value = readNumericField(headerText, fieldName)
    value = str2double(readTextField(headerText, fieldName));
end


function value = readTextField(headerText, fieldName)
    % Match "fieldName = value" at the start of a line
    token = regexp(headerText, ['(?m)^\s*', fieldName, '\s*=\s*([^\r\n]*)'], 'tokens', 'once');
    if isempty(token)
        error('readHyperspectralDataCube:missingField', 'Field "%s" not found in the ENVI header.', fieldName);
    end
    value = token{1};
end
