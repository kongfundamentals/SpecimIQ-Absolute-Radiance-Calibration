%% function plotFigure8
%
% Description:
%   Generates Figure 8: the dark corrected digital counts
%   I'(254, 250, lambdaFactory) of a helium lamp (t = 10 ms) on the
%   factory-set wavelength scale. Dashed vertical lines mark the eight
%   measured peaks; the black horizontal lines represent a 12 nm range at
%   half the peak height, indicating the bandwidth.
%
% Inputs:
%   - Reads data from: '../data/processedData/heliumSpectrum.csv'
%                      '../data/processedData/heliumPeaks.csv'
%
% Outputs:
%   - Saves the figure to: '../output/fig8.tif' (and .png)
%
% Authors:
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%
% Last updated:
%   October-29-2026
%

function plotFigure8

    % 0. SETUP
    % ===================================================================
    paths    = getProjectPaths();
    style    = getFigureStyle();
    settings = getAnalysisSettings().wavelengthCalibration;
    finalWidthInches  = style.twoColumnWidth;
    finalHeightInches = 9.4 / 2.54;   % 16 cm x 9.4 cm, as submitted
    halfMarkerWidth   = settings.bandwidthMarkerWidth / 2;
    peakLineColor     = [0.6, 0.6, 0.6];

    % 1. LOAD DATA
    % ===================================================================
    spectrum = readNumericCsv(fullfile(paths.processedData, 'heliumSpectrum.csv'));
    [peaks, peakColumns] = readNumericCsv(fullfile(paths.processedData, 'heliumPeaks.csv'));
    wavelengthFactory   = spectrum(:, 2);
    darkCorrectedCounts = spectrum(:, 3);
    peakWavelengths = peaks(:, strcmp(peakColumns, 'measuredPeakNm'));
    peakCounts      = peaks(:, strcmp(peakColumns, 'peakCounts'));

    % 2. CREATE THE FIGURE
    % ===================================================================
    figureHandle = figure('Units', 'inches', 'Position', [1, 1, finalWidthInches, finalHeightInches], 'Color', 'w');
    axesHandle = axes('Position', [0.10, 0.12, 0.87, 0.84]);
    hold(axesHandle, 'on');
    yLimits = [0, 4000];

    for peakIndex = 1 : numel(peakWavelengths)
        % Measured peak (dashed vertical line)
        plot(axesHandle, peakWavelengths([peakIndex, peakIndex]), yLimits, '--', 'Color', peakLineColor, 'LineWidth', style.lineWidth);
        % 12 nm range at half maximum (bandwidth marker)
        plot(axesHandle, peakWavelengths(peakIndex) + [-halfMarkerWidth, halfMarkerWidth], ...
             peakCounts([peakIndex, peakIndex]) / 2, 'k-', 'LineWidth', 2.5);
    end
    plot(axesHandle, wavelengthFactory, darkCorrectedCounts, 'k-', 'LineWidth', style.lineWidth);
    plot(axesHandle, wavelengthFactory, darkCorrectedCounts, 'ko', 'MarkerFaceColor', 'w', 'MarkerSize', 3);
    plot(axesHandle, peakWavelengths, peakCounts, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 3);

    % 3. FORMAT
    % ===================================================================
    xlim(axesHandle, [400, 800]);
    ylim(axesHandle, yLimits);
    set(axesHandle, 'XTick', 400 : 50 : 800, 'YTick', 0 : 500 : 4000);
    formatAxes(axesHandle, 'Wavelength (nm)', ...
               sprintf('{\\itI}''(%d, %d, \\lambda_{factory})', settings.pixel(1), settings.pixel(2)));

    % 4. SAVE
    % ===================================================================
    saveFigureForPublication(figureHandle, 'fig8', finalWidthInches, finalHeightInches);
    close(figureHandle);
end
