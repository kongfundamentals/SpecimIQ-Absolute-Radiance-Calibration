%% function plotFigure4
%
% Description:
%   Generates Figure 4: linearity of the digital counts with integration
%   time for two representative pixels of the OLED panel,
%   (a) (i, j) = (294, 216) and (b) (i, j) = (217, 308), and six spectral
%   bands (k = 25 to 50 in steps of 5). Open circles: measured digital
%   counts; solid lines: linear fits (Eq. 2).
%
% Inputs:
%   - Reads data from: '../data/processedData/linearity.mat'
%
% Outputs:
%   - Saves the figure to: '../output/fig4.tif' (and .png)
%
% Authors:
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%
% Last updated:
%   October-29-2026
%

function plotFigure4

    % 0. SETUP
    % ===================================================================
    paths    = getProjectPaths();
    style    = getFigureStyle();
    settings = getAnalysisSettings().linearity;
    finalWidthInches  = style.oneColumnWidth;
    finalHeightInches = 14 / 2.54;   % 8 cm x 14 cm, as submitted
    panelLabels    = {'(a)', '(b)'};
    panelPositions = [0.20, 0.585, 0.75, 0.37; 0.20, 0.085, 0.75, 0.37];
    % y axis of each panel, as in the submitted figure
    yLimits = [0, 4200; 0, 3500];
    yTicks  = {0 : 1000 : 4000, 0 : 500 : 3500};
    timeAxis = 0 : 250;   % integration time range of the fitted lines [ms]

    % 1. LOAD DATA
    % ===================================================================
    linearity = load(fullfile(paths.processedData, 'linearity.mat'));

    figureHandle = figure('Units', 'inches', 'Position', [1, 1, finalWidthInches, finalHeightInches], 'Color', 'w');

    % 2. ONE PANEL PER PIXEL
    % ===================================================================
    for panelIndex = 1 : numel(settings.pixelsToPlot)
        pixelIndex = settings.pixelsToPlot(panelIndex);
        axesHandle = axes('Position', panelPositions(panelIndex, :));
        hold(axesHandle, 'on');
        lineColors = get(axesHandle, 'ColorOrder');

        lineHandles  = zeros(1, numel(linearity.bands));
        legendLabels = cell(1, numel(linearity.bands));
        for bandIndex = 1 : numel(linearity.bands)
            lineColor = lineColors(mod(bandIndex - 1, size(lineColors, 1)) + 1, :);
            fittedCounts = linearity.intercepts(pixelIndex, bandIndex) + linearity.slopes(pixelIndex, bandIndex) * timeAxis;
            lineHandles(bandIndex) = plot(axesHandle, timeAxis, fittedCounts, '-', 'Color', lineColor, 'LineWidth', style.lineWidth);
            plot(axesHandle, linearity.integrationTimeMs, reshape(linearity.digitalCounts(pixelIndex, bandIndex, :), 1, []), ...
                 'o', 'Color', lineColor, 'LineWidth', style.lineWidth, 'MarkerSize', 5);
            legendLabels{bandIndex} = sprintf('{\\itk} = %d', linearity.bands(bandIndex));
        end

        xlim(axesHandle, [0, 250]);
        ylim(axesHandle, yLimits(panelIndex, :));
        set(axesHandle, 'XTick', 0 : 50 : 250, 'YTick', yTicks{panelIndex});
        pixel = linearity.pixels(pixelIndex, :);
        formatAxes(axesHandle, 'Integration time (ms)', ...
                   sprintf('Digital counts {\\itI}(%d, %d, {\\itk})', pixel(1), pixel(2)), panelLabels{panelIndex});
        % As in the original analysis script: MATLAB chooses the legend
        % position that overlaps least with the data
        legend(axesHandle, lineHandles, legendLabels, 'Location', 'best', 'Box', 'off', 'Color', 'none', ...
               'FontName', style.fontName, 'FontSize', style.legendFontSize);
    end

    % 3. SAVE
    % ===================================================================
    saveFigureForPublication(figureHandle, 'fig4', finalWidthInches, finalHeightInches);
    close(figureHandle);
end
