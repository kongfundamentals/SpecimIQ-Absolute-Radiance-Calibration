%% function plotFigure7
%
% Description:
%   Generates Figure 7: the variation of the beta1(i, j) values at five
%   positions of the field of view, relative to the mean value at the
%   centre position, for two spectral bands: (a) k = 55 and (b) k = 100.
%   The boxplots show the distribution of the 121 pixels (11 x 11) at each
%   position (local uniformity); the black circles show their mean
%   (global uniformity).
%
%   The boxplots are drawn with drawBoxplot, which follows the conventions
%   of MATLAB's boxplot without requiring the Statistics Toolbox.
%
% Inputs:
%   - Reads data from: '../data/processedData/flatFieldBehavior.mat'
%
% Outputs:
%   - Saves the figure to: '../output/fig7.tif' (and .png)
%
% Authors:
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%
% Last updated:
%   October-29-2026
%

function plotFigure7

    % 0. SETUP
    % ===================================================================
    paths = getProjectPaths();
    style = getFigureStyle();
    finalWidthInches  = style.oneColumnWidth;
    finalHeightInches = 13.8 / 2.54;   % 8 cm x 13.8 cm, as submitted
    panelLabels    = {'(a)', '(b)'};
    panelPositions = [0.19, 0.585, 0.78, 0.35; 0.19, 0.11, 0.78, 0.35];

    % 1. LOAD DATA
    % ===================================================================
    uniformity = load(fullfile(paths.processedData, 'flatFieldBehavior.mat'));
    numberOfPositions = numel(uniformity.positionNames);

    figureHandle = figure('Units', 'inches', 'Position', [1, 1, finalWidthInches, finalHeightInches], 'Color', 'w');

    % 2. ONE PANEL PER BAND
    % ===================================================================
    for bandIndex = 1 : numel(uniformity.bands)
        ratios = uniformity.ratios(:, :, bandIndex);
        axesHandle = axes('Position', panelPositions(bandIndex, :));
        drawBoxplot(axesHandle, ratios, 0.5);
        plot(axesHandle, 1 : numberOfPositions, mean(ratios, 1), 'o', 'MarkerSize', 7, ...
             'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');

        xlim(axesHandle, [0.5, numberOfPositions + 0.5]);
        ylim(axesHandle, [0.95, 1.05]);
        set(axesHandle, 'XTick', 1 : numberOfPositions, 'XTickLabel', uniformity.positionNames, 'YTick', 0.95 : 0.01 : 1.05);
        % Keep the position names horizontal (MATLAB rotates them automatically when space is tight)
        set(axesHandle, 'XTickLabelRotation', 0);
        if bandIndex == numel(uniformity.bands)
            xLabelText = 'Source position';
        else
            xLabelText = '';
        end
        formatAxes(axesHandle, xLabelText, 'Ratio', panelLabels{bandIndex});
        title(axesHandle, sprintf('Spatial uniformity ({\\itk} = %d)', uniformity.bands(bandIndex)), ...
              'FontName', style.fontName, 'FontSize', style.titleFontSize, 'FontWeight', 'bold');
    end

    % 3. SAVE
    % ===================================================================
    saveFigureForPublication(figureHandle, 'fig7', finalWidthInches, finalHeightInches);
    close(figureHandle);
end
