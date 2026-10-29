%% function plotFigure2
%
% Description:
%   Generates Figure 2: the repeatability of the digital counts of the
%   central pixel I(251, 262, k) over 61 measurements (one per minute) for
%   five spectral bands (k = 25, 50, 100, 150 and 200).
%
% Inputs:
%   - Reads data from: '../data/processedData/repeatability.mat'
%
% Outputs:
%   - Saves the figure to: '../output/fig2.tif' (and .png)
%
% Authors:
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%
% Last updated:
%   October-29-2026
%

function plotFigure2

    % 0. SETUP
    % ===================================================================
    paths    = getProjectPaths();
    style    = getFigureStyle();
    settings = getAnalysisSettings().repeatability;
    finalWidthInches  = style.oneColumnWidth;
    finalHeightInches = 6.3 / 2.54;   % 8 cm x 6.3 cm, as submitted

    % 1. LOAD DATA
    % ===================================================================
    repeatability = load(fullfile(paths.processedData, 'repeatability.mat'));
    bandsToPlot   = settings.bandsToPlot;

    % 2. CREATE THE FIGURE
    % ===================================================================
    figureHandle = figure('Units', 'inches', 'Position', [1, 1, finalWidthInches, finalHeightInches], 'Color', 'w');
    axesHandle = axes('Position', [0.20, 0.20, 0.75, 0.75]);
    hold(axesHandle, 'on');

    lineColors = get(axesHandle, 'ColorOrder');
    for bandIndex = 1 : numel(bandsToPlot)
        countsOverTime = repeatability.digitalCounts(:, bandsToPlot(bandIndex));
        plot(axesHandle, repeatability.timeMinutes, countsOverTime, '-', ...
             'Color', lineColors(bandIndex, :), 'LineWidth', style.lineWidth);
        % Label each line at its right end
        text(axesHandle, repeatability.timeMinutes(end) + 2, mean(countsOverTime), ...
             sprintf('{\\itk}=%d', bandsToPlot(bandIndex)), ...
             'FontName', style.fontName, 'FontSize', style.axisTickFontSize, 'VerticalAlignment', 'middle');
    end

    % 3. FORMAT
    % ===================================================================
    xlim(axesHandle, [0, 75]);
    ylim(axesHandle, [0, 2500]);
    set(axesHandle, 'XTick', 20 : 20 : 60, 'YTick', 0 : 500 : 2500);
    formatAxes(axesHandle, 'Time (minute)', ...
               sprintf('Digital counts {\\itI}(%d, %d, {\\itk})', repeatability.pixel(1), repeatability.pixel(2)));

    % 4. SAVE
    % ===================================================================
    saveFigureForPublication(figureHandle, 'fig2', finalWidthInches, finalHeightInches);
    close(figureHandle);
end
