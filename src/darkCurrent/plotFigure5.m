%% function plotFigure5
%
% Description:
%   Generates Figure 5: spatial variations of the dark current at nine
%   integration times (1 to 500 ms) for spectral band k = 100. Every image
%   shows the full sensor (512 x 512 pixels) with the first pixel index i
%   on the horizontal axis and the second index j on the vertical axis, as
%   in the submitted figure and in Figure 6. The colour scale represents
%   the digital counts, which are integers, so the colour bar has integer
%   ticks.
%
% Inputs:
%   - Reads data from: '../data/processedData/darkCurrent.mat'
%
% Outputs:
%   - Saves the figure to: '../output/fig5.tif' (and .png)
%
% Authors:
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%
% Last updated:
%   October-29-2026
%

function plotFigure5

    % 0. SETUP
    % ===================================================================
    paths = getProjectPaths();
    style = getFigureStyle();
    finalWidthInches  = style.twoColumnWidth;
    finalHeightInches = finalWidthInches * 1901 / 2105;   % aspect ratio of the submitted figure
    colorLimits = [238, 243];   % digital counts

    % Layout of the 3 x 3 image grid (normalised figure units)
    imageWidth  = 0.245;
    imageHeight = 0.275;
    leftEdges   = [0.02, 0.30, 0.58];
    bottomEdges = [0.67, 0.355, 0.04];

    % 1. LOAD DATA
    % ===================================================================
    darkCurrent = load(fullfile(paths.processedData, 'darkCurrent.mat'));

    figureHandle = figure('Units', 'inches', 'Position', [1, 1, finalWidthInches, finalHeightInches], 'Color', 'w');
    if exist('parula', 'file') == 2 || exist('parula', 'builtin') == 5
        colormap(parula(256));    % MATLAB default colour map
    else
        colormap(viridis(256));   % GNU Octave
    end

    % 2. ONE IMAGE PER INTEGRATION TIME
    % ===================================================================
    for frameIndex = 1 : numel(darkCurrent.integrationTimeMs)
        rowIndex    = ceil(frameIndex / 3);
        columnIndex = frameIndex - 3 * (rowIndex - 1);
        axesHandle = axes('Position', [leftEdges(columnIndex), bottomEdges(rowIndex), imageWidth, imageHeight]);

        % Transposed, so that i is on the horizontal axis and j on the vertical axis
        imagesc(axesHandle, double(darkCurrent.darkFrames(:, :, frameIndex))');
        set(axesHandle, 'YDir', 'normal', 'XTick', [], 'YTick', [], 'Box', 'on', 'LineWidth', style.axesLineWidth);
        caxis(axesHandle, colorLimits);
        axis(axesHandle, 'square');
        title(axesHandle, sprintf('%d ms', darkCurrent.integrationTimeMs(frameIndex)), ...
              'FontName', style.fontName, 'FontSize', style.titleFontSize, 'FontWeight', 'bold');
    end

    % 3. SHARED COLOUR BAR
    % ===================================================================
    colorbarHandle = colorbar(axesHandle);
    set(colorbarHandle, 'Position', [0.88, 0.04, 0.025, 0.905], 'FontName', style.fontName, 'FontSize', style.axisTickFontSize);
    % Integer ticks only (digital counts are integers)
    if exist('OCTAVE_VERSION', 'builtin') > 0
        set(colorbarHandle, 'YTick', colorLimits(1) : colorLimits(2));   % GNU Octave
    else
        set(colorbarHandle, 'Ticks', colorLimits(1) : colorLimits(2));
    end
    % Adding the colour bar can resize the last image: restore its position
    set(axesHandle, 'Position', [leftEdges(3), bottomEdges(3), imageWidth, imageHeight]);
    ylabel(colorbarHandle, 'Digital counts', 'FontName', style.fontName, 'FontSize', style.axisLabelFontSize);

    % 4. SAVE
    % ===================================================================
    saveFigureForPublication(figureHandle, 'fig5', finalWidthInches, finalHeightInches);
    close(figureHandle);
end
