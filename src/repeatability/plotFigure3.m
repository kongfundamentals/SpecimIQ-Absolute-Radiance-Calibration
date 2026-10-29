%% function plotFigure3
%
% Description:
%   Generates Figure 3: (a) spectral distribution of the mean (blue dots)
%   and standard deviation (orange dots) of the digital counts
%   I(251, 262, k) over the 61 repeated measurements, and (b) the
%   corresponding coefficient of variation (CV, Eq. 1).
%
% Inputs:
%   - Reads data from: '../data/processedData/repeatabilityStatistics.csv'
%                      '../data/processedData/repeatability.mat' (pixel coordinates)
%
% Outputs:
%   - Saves the figure to: '../output/fig3.tif' (and .png)
%
% Authors:
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%
% Last updated:
%   October-29-2026
%

function plotFigure3

    % 0. SETUP
    % ===================================================================
    paths = getProjectPaths();
    style = getFigureStyle();
    finalWidthInches  = style.oneColumnWidth;
    finalHeightInches = 14.8 / 2.54;   % 8 cm x 14.8 cm, as submitted
    meanColor      = [0, 0, 1];
    deviationColor = [0.85, 0.33, 0.10];
    markerSize     = 7;

    % 1. LOAD DATA
    % ===================================================================
    [statistics, columnNames] = readNumericCsv(fullfile(paths.processedData, 'repeatabilityStatistics.csv'));
    getColumn = @(name) statistics(:, strcmp(columnNames, name));
    bandNumber = getColumn('bandNumber');
    repeatability = load(fullfile(paths.processedData, 'repeatability.mat'), 'pixel');
    pixelText = sprintf('{\\itI}(%d, %d, {\\itk})', repeatability.pixel(1), repeatability.pixel(2));

    figureHandle = figure('Units', 'inches', 'Position', [1, 1, finalWidthInches, finalHeightInches], 'Color', 'w');

    % 2. PANEL (a): MEAN (LEFT AXIS) AND STANDARD DEVIATION (RIGHT AXIS)
    % ===================================================================
    % Two overlaid axes are used instead of yyaxis, so that the script
    % also runs in GNU Octave.
    panelPosition = [0.20, 0.575, 0.62, 0.37];
    axesMean = axes('Position', panelPosition);
    plot(axesMean, bandNumber, getColumn('meanCounts'), '.', 'Color', meanColor, 'MarkerSize', markerSize);
    xlim(axesMean, [1, 204]);
    ylim(axesMean, [0, 2500]);
    formatAxes(axesMean, 'Spectral band ({\itk})', '', '(a)');
    set(axesMean, 'YTick', 0 : 500 : 2500);
    % Black axes and tick labels; only the axis labels are coloured
    ylabel(axesMean, ['Mean ', pixelText], 'Color', meanColor, 'FontName', style.fontName, 'FontSize', style.axisLabelFontSize);

    axesDeviation = axes('Position', panelPosition, 'Color', 'none', 'YAxisLocation', 'right', 'XTick', []);
    hold(axesDeviation, 'on');
    plot(axesDeviation, bandNumber, getColumn('standardDeviation'), '.', 'Color', deviationColor, 'MarkerSize', markerSize);
    xlim(axesDeviation, [1, 204]);
    ylim(axesDeviation, [0, 12]);
    set(axesDeviation, 'FontName', style.fontName, 'FontSize', style.axisTickFontSize, ...
        'LineWidth', style.axesLineWidth, 'YColor', 'k', 'XTick', [], 'YTick', 0 : 2 : 12);
    ylabel(axesDeviation, ['Standard deviation of ', pixelText], 'Color', deviationColor, ...
           'FontName', style.fontName, 'FontSize', style.axisLabelFontSize);

    % 3. PANEL (b): COEFFICIENT OF VARIATION
    % ===================================================================
    axesCv = axes('Position', [0.20, 0.08, 0.62, 0.38]);
    plot(axesCv, bandNumber, getColumn('coefficientOfVariationPercent'), '.', 'Color', deviationColor, 'MarkerSize', markerSize);
    xlim(axesCv, [1, 204]);
    ylim(axesCv, [0.2, 0.8]);
    set(axesCv, 'YTick', 0.2 : 0.1 : 0.8);
    formatAxes(axesCv, 'Spectral band ({\itk})', 'Coefficient of variation (CV) (%)', '(b)');

    % 4. SAVE
    % ===================================================================
    saveFigureForPublication(figureHandle, 'fig3', finalWidthInches, finalHeightInches);
    close(figureHandle);
end
