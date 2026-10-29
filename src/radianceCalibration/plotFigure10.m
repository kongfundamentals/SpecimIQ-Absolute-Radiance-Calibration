%% function plotFigure10
%
% Description:
%   Generates Figure 10: the spectral radiance of the calibration source
%   measured with the JETI Specbos 1211L from a perpendicular direction,
%   averaged over ten measurements. The dashed vertical lines indicate the
%   visible spectral range (380 and 780 nm).
%
% Inputs:
%   - Reads data from: '../data/processedData/calibrationSourceJeti.csv'
%
% Outputs:
%   - Saves the figure to: '../output/fig10.tif' (and .png)
%
% Authors:
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%
% Last updated:
%   October-29-2026
%

function plotFigure10

    % 0. SETUP
    % ===================================================================
    paths = getProjectPaths();
    style = getFigureStyle();
    finalWidthInches  = style.oneColumnWidth;
    finalHeightInches = 8 / 2.54;   % 8 cm x 8 cm, as submitted
    visibleRange = [380, 780];   % [nm]
    yLimits      = [0, 0.8];

    % 1. LOAD DATA
    % ===================================================================
    jeti = readNumericCsv(fullfile(paths.processedData, 'calibrationSourceJeti.csv'));

    % 2. CREATE THE FIGURE
    % ===================================================================
    figureHandle = figure('Units', 'inches', 'Position', [1, 1, finalWidthInches, finalHeightInches], 'Color', 'w');
    axesHandle = axes('Position', [0.20, 0.15, 0.73, 0.81]);
    hold(axesHandle, 'on');

    plot(axesHandle, jeti(:, 1), jeti(:, 2), 'k.-', 'LineWidth', style.lineWidth, 'MarkerSize', 6);
    for boundaryIndex = 1 : numel(visibleRange)
        plot(axesHandle, visibleRange([boundaryIndex, boundaryIndex]), yLimits, 'k--', 'LineWidth', 0.5);
        % Label at mid height, written along the line on its right-hand side
        % (rotated text: 'top' alignment places the text to the right of the anchor)
        text(axesHandle, visibleRange(boundaryIndex) + 8, mean(yLimits), sprintf('%d nm', visibleRange(boundaryIndex)), ...
             'Rotation', 90, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', ...
             'FontName', style.fontName, 'FontSize', style.axisLabelFontSize);
    end

    % 3. FORMAT
    % ===================================================================
    xlim(axesHandle, [300, 1000]);
    ylim(axesHandle, yLimits);
    set(axesHandle, 'XTick', 400 : 200 : 1000, 'YTick', 0 : 0.1 : 0.8);
    formatAxes(axesHandle, 'Wavelength (nm)', 'Spectral radiance (W \cdot m^{-2} \cdot sr^{-1} \cdot nm^{-1})');

    % 4. SAVE
    % ===================================================================
    saveFigureForPublication(figureHandle, 'fig10', finalWidthInches, finalHeightInches);
    close(figureHandle);
end
