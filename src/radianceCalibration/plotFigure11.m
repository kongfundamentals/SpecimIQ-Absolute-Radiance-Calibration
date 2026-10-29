%% function plotFigure11
%
% Description:
%   Generates Figure 11: (a) the spectral calibration factor C(lambda)
%   averaged over the 7 x 7 pixel area measured by the JETI, and (b) the
%   spatial coefficient of variation (CV) across these 49 pixels. The gray
%   dashed line represents the mean CV across the spectral range.
%
% Inputs:
%   - Reads data from: '../data/processedData/calibrationFactor.csv'
%
% Outputs:
%   - Saves the figure to: '../output/fig11.tif' (and .png)
%
% Authors:
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%
% Last updated:
%   October-29-2026
%

function plotFigure11

    % 0. SETUP
    % ===================================================================
    paths = getProjectPaths();
    style = getFigureStyle();
    finalWidthInches  = style.oneColumnWidth;
    finalHeightInches = 14 / 2.54;   % 8 cm x 14 cm, as submitted
    wavelengthLimits  = [350, 1050];

    % 1. LOAD DATA
    % ===================================================================
    [calibration, columnNames] = readNumericCsv(fullfile(paths.processedData, 'calibrationFactor.csv'));
    wavelengthCorrected = calibration(:, strcmp(columnNames, 'wavelengthCorrectedNm'));
    calibrationFactor   = calibration(:, strcmp(columnNames, 'calibrationFactor'));
    spatialCv           = calibration(:, strcmp(columnNames, 'spatialCvPercent'));

    figureHandle = figure('Units', 'inches', 'Position', [1, 1, finalWidthInches, finalHeightInches], 'Color', 'w');

    % 2. PANEL (a): CALIBRATION FACTOR
    % ===================================================================
    axesFactor = axes('Position', [0.26, 0.585, 0.69, 0.37]);
    plot(axesFactor, wavelengthCorrected, calibrationFactor, 'k-', 'LineWidth', style.lineWidth);
    xlim(axesFactor, wavelengthLimits);
    ylim(axesFactor, [0, 0.016]);
    set(axesFactor, 'XTick', 400 : 200 : 1000, 'YTick', 0 : 0.002 : 0.016);
    formatAxes(axesFactor, '', {'Spectral calibration factor {\itC}', ...
               '(W \cdot m^{-2} \cdot sr^{-1} \cdot nm^{-1} \cdot count^{-1})'}, '(a)');

    % 3. PANEL (b): SPATIAL CV
    % ===================================================================
    axesCv = axes('Position', [0.26, 0.09, 0.69, 0.37]);
    hold(axesCv, 'on');
    plot(axesCv, wavelengthLimits, [mean(spatialCv), mean(spatialCv)], '--', 'Color', [0.6, 0.6, 0.6], 'LineWidth', 1.5);
    plot(axesCv, wavelengthCorrected, spatialCv, 'k-', 'LineWidth', style.lineWidth);
    xlim(axesCv, wavelengthLimits);
    ylim(axesCv, [0, 3]);
    set(axesCv, 'XTick', 400 : 200 : 1000, 'YTick', 0 : 0.5 : 3);
    formatAxes(axesCv, 'Corrected wavelength (nm)', 'Spatial CV (%)', '(b)');

    % 4. SAVE
    % ===================================================================
    saveFigureForPublication(figureHandle, 'fig11', finalWidthInches, finalHeightInches);
    close(figureHandle);
end
