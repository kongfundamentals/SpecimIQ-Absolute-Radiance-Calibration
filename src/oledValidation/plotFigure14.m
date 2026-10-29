%% function plotFigure14
%
% Description:
%   Generates Figure 14 (validation with an OLED panel):
%   (a) the reconstructed spectral radiance Le,test at the centre of the
%       OLED (solid line) compared with the ground truth Le,gt measured
%       with the JETI Specbos 1211L (dashed line); the dotted line shows
%       the reconstruction without wavelength correction.
%   (b) the ratio Le,test / Le,gt at the centre and the four corners; the
%       dotted line shows the centre spot without wavelength correction.
%
%   The labels, units and ticks follow the submitted figure. The typo
%   'top_right' in the legend of the submitted figure is corrected.
%
% Inputs:
%   - Reads data from: '../data/processedData/oledRadianceSpecim.csv'
%                      '../data/processedData/oledRadianceJeti.csv'
%
% Outputs:
%   - Saves the figure to: '../output/fig14.tif' (and .png)
%
% Authors:
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%
% Last updated:
%   October-29-2026
%

function plotFigure14

    % 0. SETUP
    % ===================================================================
    paths    = getProjectPaths();
    style    = getFigureStyle();
    settings = getAnalysisSettings().oledValidation;
    finalWidthInches  = style.twoColumnWidth;            % 16 cm
    finalHeightInches = finalWidthInches * 1853 / 1890;  % aspect ratio of the submitted figure
    legendFontSize    = 9;
    wavelengthLimits  = [400, 780];
    % Spectral radiance is plotted as a multiple of 10^-2 W/(m^2 sr nm),
    % as in the submitted figure
    radianceScale = 1e-2;
    spotLabels = {'top-left', 'top-right', 'center', 'bottom-left', 'bottom-right'};
    spotColors = [1.0, 0.647, 0.0; 0.235, 0.702, 0.443; 0.502, 0.502, 0.502; 0.255, 0.412, 0.882; 0.75, 0.0, 0.75];
    centerIndex = find(strcmp(settings.spotNames, 'center'));

    % 1. LOAD DATA
    % ===================================================================
    [specimTable, specimColumns] = readNumericCsv(fullfile(paths.processedData, 'oledRadianceSpecim.csv'));
    [jetiTable, jetiColumns]     = readNumericCsv(fullfile(paths.processedData, 'oledRadianceJeti.csv'));
    wavelengthFactory   = specimTable(:, strcmp(specimColumns, 'wavelengthFactoryNm'));
    wavelengthCorrected = specimTable(:, strcmp(specimColumns, 'wavelengthCorrectedNm'));
    [~, correctedColumns]   = ismember(strcat(settings.spotNames, '_wavelengthCorrected'), specimColumns);
    [~, uncorrectedColumns] = ismember(strcat(settings.spotNames, '_withoutWavelengthCorrection'), specimColumns);
    [~, jetiSpotColumns]    = ismember(settings.spotNames, jetiColumns);
    radianceCorrected   = specimTable(:, correctedColumns);
    radianceUncorrected = specimTable(:, uncorrectedColumns);
    wavelengthJeti      = jetiTable(:, 1);
    radianceJeti        = jetiTable(:, jetiSpotColumns);

    % Ratios Le,test / Le,gt at the Specim IQ bands
    ratioCorrected   = radianceCorrected ./ interpolateSpectrum(wavelengthJeti, radianceJeti, wavelengthCorrected);
    ratioUncorrected = radianceUncorrected(:, centerIndex) ./ ...
                       interpolateSpectrum(wavelengthJeti, radianceJeti(:, centerIndex), wavelengthFactory);

    figureHandle = figure('Units', 'inches', 'Position', [1, 1, finalWidthInches, finalHeightInches], 'Color', 'w');

    % 2. PANEL (a): ABSOLUTE SPECTRAL RADIANCE AT THE CENTRE
    % ===================================================================
    axesAbsolute = axes('Position', [0.12, 0.59, 0.85, 0.36]);
    hold(axesAbsolute, 'on');
    lineHandles(1) = plot(axesAbsolute, wavelengthJeti, radianceJeti(:, centerIndex) / radianceScale, 'k--', 'LineWidth', 1.25);
    lineHandles(2) = plot(axesAbsolute, wavelengthCorrected, radianceCorrected(:, centerIndex) / radianceScale, '-', ...
                          'Color', [0.12, 0.56, 1.0], 'LineWidth', 1.25);
    lineHandles(3) = plot(axesAbsolute, wavelengthFactory, radianceUncorrected(:, centerIndex) / radianceScale, ':', ...
                          'Color', [1, 0, 0], 'LineWidth', 1.5);
    xlim(axesAbsolute, wavelengthLimits);
    ylim(axesAbsolute, [0, 1.25]);
    set(axesAbsolute, 'XTick', 400 : 50 : 750, 'YTick', 0 : 0.2 : 1.2);
    formatAxes(axesAbsolute, 'Wavelength (nm)', {'Spectral radiance', '(W\cdotm^{-2}\cdotsr^{-1}\cdotnm^{-1})'});
    addPanelLabel(axesAbsolute, '(a)', style);
    % Scale factor of the y axis, written above the axis as in the submitted figure
    text(axesAbsolute, 0, 1.01, '\times10^{-2}', 'Units', 'normalized', 'FontName', style.fontName, ...
         'FontSize', style.axisTickFontSize, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');
    title(axesAbsolute, 'Center', 'FontName', style.fontName, 'FontSize', style.titleFontSize, 'FontWeight', 'normal');
    legend(axesAbsolute, lineHandles, {'ground truth', 'Specim, wavelength corrected', 'Specim, wavelength uncorrected'}, ...
           'Location', 'northwest', 'Box', 'on', 'FontName', style.fontName, 'FontSize', legendFontSize);

    % 3. PANEL (b): RATIO TO THE GROUND TRUTH
    % ===================================================================
    axesRatio = axes('Position', [0.12, 0.08, 0.85, 0.38]);
    hold(axesRatio, 'on');
    plot(axesRatio, wavelengthLimits, [1, 1], 'k--', 'LineWidth', 1.25);
    ratioHandles = zeros(1, numel(spotLabels) + 1);
    for spotIndex = 1 : numel(spotLabels)
        ratioHandles(spotIndex) = plot(axesRatio, wavelengthCorrected, ratioCorrected(:, spotIndex), '-', ...
                                       'Color', spotColors(spotIndex, :), 'LineWidth', style.lineWidth);
    end
    ratioHandles(end) = plot(axesRatio, wavelengthFactory, ratioUncorrected, ':', 'Color', [0.5, 0.5, 0.5], 'LineWidth', 1.5);
    xlim(axesRatio, wavelengthLimits);
    ylim(axesRatio, [0, 2]);
    set(axesRatio, 'XTick', 400 : 50 : 750, 'YTick', 0 : 0.5 : 2, 'YMinorGrid', 'on');
    % The ratio of two spectral radiances is dimensionless, so the axis has no unit
    formatAxes(axesRatio, 'Corrected wavelength (nm)', 'Relative spectral radiance');
    addPanelLabel(axesRatio, '(b)', style);
    legend(axesRatio, ratioHandles, [spotLabels, {'center, wavelength uncorrected'}], ...
           'Location', 'southeast', 'Box', 'on', 'FontName', style.fontName, 'FontSize', legendFontSize);

    % 4. SAVE
    % ===================================================================
    saveFigureForPublication(figureHandle, 'fig14', finalWidthInches, finalHeightInches);
    close(figureHandle);
end


%% LOCAL FUNCTION: addPanelLabel
% Panel label to the left of the y-axis label, at the height of the top of
% the axes, as in the submitted figure (the scale factor x10^-2 is written
% at the top-left corner of the axes).
function addPanelLabel(axesHandle, panelLabel, style)
    text(axesHandle, -0.11, 1.0, panelLabel, 'Units', 'normalized', 'FontName', style.fontName, ...
         'FontSize', style.panelLabelFontSize, 'FontWeight', 'bold', ...
         'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');
end
