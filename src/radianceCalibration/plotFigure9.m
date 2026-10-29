%% function plotFigure9
%
% Description:
%   Generates Figure 9: (a) the dark current corrected and wavelength
%   corrected signal I'(ic, jc, lambda) of the central pixel of the
%   calibration source in three repeated captures (coloured dashed lines)
%   and their average (solid black line). The rectangle indicates the
%   region shown in (b), a zoomed-in view of the spectral peak (580-620 nm)
%   highlighting the repeatability of the measurements.
%
% Inputs:
%   - Reads data from: '../data/processedData/calibrationSourceCounts.csv'
%
% Outputs:
%   - Saves the figure to: '../output/fig9.tif' (and .png)
%
% Authors:
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%
% Last updated:
%   October-29-2026
%

function plotFigure9

    % 0. SETUP
    % ===================================================================
    paths = getProjectPaths();
    style = getFigureStyle();
    finalWidthInches  = style.oneColumnWidth;
    finalHeightInches = 13.8 / 2.54;   % 8 cm x 13.8 cm, as submitted
    captureColors = [226, 100, 46; 108, 210, 141; 79, 139, 240] / 255;
    zoomWavelengthRange = [580, 620];
    zoomCountRange      = [2100, 2250];
    yLabelText = '{\itI}''({\iti}_c, {\itj}_c, \lambda)';

    % 1. LOAD DATA
    % ===================================================================
    [counts, columnNames] = readNumericCsv(fullfile(paths.processedData, 'calibrationSourceCounts.csv'));
    wavelengthCorrected = counts(:, strcmp(columnNames, 'wavelengthCorrectedNm'));
    captureColumns = find(strncmp(columnNames, 'darkCorrectedCountsHsi', 22));
    meanCounts     = counts(:, strcmp(columnNames, 'darkCorrectedCountsMean'));

    figureHandle = figure('Units', 'inches', 'Position', [1, 1, finalWidthInches, finalHeightInches], 'Color', 'w');

    % 2. PANEL (a): FULL SPECTRUM
    % ===================================================================
    axesFull = axes('Position', [0.22, 0.585, 0.73, 0.37]);
    hold(axesFull, 'on');
    for captureIndex = 1 : numel(captureColumns)
        plot(axesFull, wavelengthCorrected, counts(:, captureColumns(captureIndex)), '--', ...
             'Color', captureColors(captureIndex, :), 'LineWidth', style.lineWidth);
    end
    plot(axesFull, wavelengthCorrected, meanCounts, 'k-', 'LineWidth', 1.5);
    % Rectangle marking the zoomed region of panel (b): exactly the axis
    % ranges of panel (b), as in the submitted figure
    plot(axesFull, zoomWavelengthRange([1 2 2 1 1]), zoomCountRange([1 1 2 2 1]), 'k-', 'LineWidth', 1.5);
    xlim(axesFull, [400, 1000]);
    ylim(axesFull, [0, 2500]);
    set(axesFull, 'XTick', 400 : 200 : 1000, 'YTick', 0 : 500 : 2500);
    formatAxes(axesFull, '', yLabelText, '(a)');

    % 3. PANEL (b): ZOOMED REGION
    % ===================================================================
    axesZoom = axes('Position', [0.22, 0.09, 0.73, 0.37]);
    hold(axesZoom, 'on');
    legendHandles = zeros(1, numel(captureColumns) + 1);
    for captureIndex = 1 : numel(captureColumns)
        legendHandles(captureIndex) = plot(axesZoom, wavelengthCorrected, counts(:, captureColumns(captureIndex)), '--', ...
                                           'Color', captureColors(captureIndex, :), 'LineWidth', style.lineWidth);
    end
    legendHandles(end) = plot(axesZoom, wavelengthCorrected, meanCounts, 'k-', 'LineWidth', 1.5);
    xlim(axesZoom, zoomWavelengthRange);
    ylim(axesZoom, zoomCountRange);
    set(axesZoom, 'XTick', 580 : 10 : 620, 'YTick', 2100 : 50 : 2250);
    formatAxes(axesZoom, 'Wavelength (nm)', yLabelText, '(b)');
    legend(axesZoom, legendHandles, {'1', '2', '3', 'Average'}, 'Location', 'northwest', 'Box', 'off', ...
           'FontName', style.fontName, 'FontSize', style.legendFontSize);

    % 4. SAVE
    % ===================================================================
    saveFigureForPublication(figureHandle, 'fig9', finalWidthInches, finalHeightInches);
    close(figureHandle);
end
