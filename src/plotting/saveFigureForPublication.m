%% function saveFigureForPublication
%
% Description:
%   Saves a figure at a fixed physical size as a 300 dpi TIFF (as
%   submitted to the journal) and a PNG for quick viewing.
%
% Inputs:
%   - figureHandle:   handle of the figure.
%   - outputFileName: base name without extension (e.g. 'fig2').
%   - widthInches:    final width of the figure [inch].
%   - heightInches:   final height of the figure [inch].
%
% Outputs:
%   - Writes <outputFileName>.tif and <outputFileName>.png to /output.
%
% Authors:
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%
% Last updated:
%   October-29-2026
%

function saveFigureForPublication(figureHandle, outputFileName, widthInches, heightInches)

    paths = getProjectPaths();

    % Keep the colours as shown on screen (e.g. gray axes backgrounds in Figure 15)
    set(figureHandle, 'InvertHardcopy', 'off', 'Color', 'w');
    set(figureHandle, 'PaperUnits', 'inches');
    set(figureHandle, 'PaperSize', [widthInches, heightInches]);
    set(figureHandle, 'PaperPosition', [0, 0, widthInches, heightInches]);

    filePathTif = fullfile(paths.output, [outputFileName, '.tif']);
    filePathPng = fullfile(paths.output, [outputFileName, '.png']);

    % The figure is rendered once (TIFF); the PNG is written from the same
    % image, so that both files are identical (a second rendering could, for
    % example, place a legend with 'Location','best' slightly differently).
    print(figureHandle, filePathTif, '-dtiff', '-r300');
    imwrite(imread(filePathTif), filePathPng);

    fprintf('Figure saved to: %s (and .png)\n', filePathTif);
end
