%% function plotFigure6
%
% Description:
%   Generates Figure 6: (a) the five geometric positions of the calibration
%   source in the focal plane across the Specim IQ field of view (red dots);
%   (b) a zoomed-in view of the source at the centre position. The dashed
%   square indicates the 11 x 11 pixel area used for the analysis and the
%   red circle marks the centre pixel.
%
%   In the original figure the dashed square was drawn manually; here it
%   is drawn from the analysis settings, so it shows exactly the pixels
%   used in Figure 7.
%
% Inputs:
%   - Reads data from: '../data/processedData/flatFieldBehavior.mat'
%
% Outputs:
%   - Saves the figure to: '../output/fig6.tif' (and .png)
%
% Authors:
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%
% Last updated:
%   October-29-2026
%

function plotFigure6

    % 0. SETUP
    % ===================================================================
    paths = getProjectPaths();
    style = getFigureStyle();
    finalWidthInches  = 7 / 2.54;      % 7 cm x 13.7 cm, as submitted
    finalHeightInches = 13.7 / 2.54;
    markerColor = [0.85, 0.33, 0.10];

    % 1. LOAD DATA
    % ===================================================================
    uniformity = load(fullfile(paths.processedData, 'flatFieldBehavior.mat'));

    figureHandle = figure('Units', 'inches', 'Position', [1, 1, finalWidthInches, finalHeightInches], 'Color', 'w');

    % 2. PANEL (a): POSITIONS IN THE FIELD OF VIEW
    % ===================================================================
    axesPositions = axes('Position', [0.22, 0.585, 0.72, 0.36]);
    plot(axesPositions, uniformity.centerPixels(:, 1), uniformity.centerPixels(:, 2), 'o', ...
         'MarkerSize', 8, 'MarkerFaceColor', markerColor, 'MarkerEdgeColor', markerColor);
    xlim(axesPositions, [0, 512]);
    ylim(axesPositions, [0, 512]);
    axis(axesPositions, 'square');
    set(axesPositions, 'XTick', 0 : 100 : 500, 'YTick', 0 : 100 : 500);
    formatAxes(axesPositions, '{\itx} coordinate', '{\ity} coordinate', '(a)');

    % 3. PANEL (b): ZOOMED IMAGE OF THE CENTRE POSITION
    % ===================================================================
    % The zoomed image is displayed with the first pixel index (i) on the
    % horizontal axis, as in the original analysis.
    axesZoom = axes('Position', [0.12, 0.04, 0.82, 0.45]);
    % In the transposed image the horizontal axis is i and the vertical axis is j
    imagesc(axesZoom, uniformity.zoomRows, uniformity.zoomColumns, uniformity.zoomImage');
    set(axesZoom, 'XLim', [uniformity.zoomRows(1) - 0.5, uniformity.zoomRows(end) + 0.5], ...
        'YLim', [uniformity.zoomColumns(1) - 0.5, uniformity.zoomColumns(end) + 0.5]);
    colormap(axesZoom, gray(256));
    axis(axesZoom, 'image');
    hold(axesZoom, 'on');

    centerPixel = uniformity.centerPixels(1, :);
    squareEdges = [centerPixel - uniformity.halfWidth - 0.5; centerPixel + uniformity.halfWidth + 0.5];
    plot(axesZoom, squareEdges([1 2 2 1 1], 1), squareEdges([1 1 2 2 1], 2), '--', ...
         'Color', [0.5, 0.5, 0.5], 'LineWidth', 1.25);
    plot(axesZoom, centerPixel(1), centerPixel(2), 'o', 'Color', [1, 0, 0], 'MarkerSize', 5, 'LineWidth', 1.25);
    set(axesZoom, 'XTick', [], 'YTick', [], 'Box', 'on');
    text(axesZoom, 0, 1.03, '(b)', 'Units', 'normalized', 'FontName', style.fontName, ...
         'FontSize', style.panelLabelFontSize, 'FontWeight', 'bold', ...
         'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');

    % 4. SAVE
    % ===================================================================
    saveFigureForPublication(figureHandle, 'fig6', finalWidthInches, finalHeightInches);
    close(figureHandle);
end
