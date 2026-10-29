%% function plotFigure15
%
% Description:
%   Generates Figure 15 (validation with a Macbeth ColorChecker):
%   (a) the spectral radiance determined with the hyperspectral camera
%       Le,test (solid lines) compared with the ground truth Le,gt (dotted
%       lines) for each of the 24 patches,
%   (b) the ratio Le,test / Le,gt.
%   A gray background is used for samples 16 (yellow) and 19 (white) to
%   improve visibility.
%
% Inputs:
%   - Reads data from: '../data/processedData/colorCheckerRadianceSpecim.csv'
%                      '../data/rawData/spectroradiometer/colorCheckerValidation_patches_jetiAverage.csv'
%
% Outputs:
%   - Saves the figure to: '../output/fig15.tif' (and .png)
%
% Authors:
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%
% Last updated:
%   October-29-2026
%

function plotFigure15

    % 0. SETUP
    % ===================================================================
    paths    = getProjectPaths();
    style    = getFigureStyle();
    settings = getAnalysisSettings().colorCheckerValidation;
    finalWidthInches  = style.twoColumnWidth;
    finalHeightInches = finalWidthInches * 5002 / 4252;   % aspect ratio of the submitted figure
    wavelengthLimits  = [400, 780];
    patchesWithGrayBackground = [16, 19];
    tickFontSize = 6;

    % Line colours of the patches (named colours of the original figure)
    patchColors = [0.804 0.522 0.247; 1.000 0.855 0.725; 0.529 0.808 0.922; 0.133 0.545 0.133; 0.867 0.627 0.867; 0.498 1.000 0.831;
                   1.000 0.549 0.000; 0.392 0.584 0.929; 0.980 0.502 0.447; 0.502 0.000 0.502; 0.678 1.000 0.184; 1.000 0.843 0.000;
                   0.000 0.000 1.000; 0.196 0.804 0.196; 1.000 0.000 0.000; 1.000 1.000 0.000; 1.000 0.000 1.000; 0.000 0.808 0.820;
                   1.000 0.980 0.980; 0.863 0.863 0.863; 0.753 0.753 0.753; 0.663 0.663 0.663; 0.502 0.502 0.502; 0.412 0.412 0.412];

    % 1. LOAD DATA
    % ===================================================================
    [specimTable, specimColumns] = readNumericCsv(fullfile(paths.processedData, 'colorCheckerRadianceSpecim.csv'));
    wavelengthCorrected = specimTable(:, strcmp(specimColumns, 'wavelengthCorrectedNm'));
    radianceSpecim      = specimTable(:, strncmp(specimColumns, 'patch', 5));
    [wavelengthJeti, radianceJeti] = readJetiSpectra(fullfile(paths.spectroradiometer, settings.patchJetiFile));
    radianceRatio = radianceSpecim ./ interpolateSpectrum(wavelengthJeti, radianceJeti, wavelengthCorrected);
    numberOfPatches = size(radianceSpecim, 2);

    figureHandle = figure('Units', 'inches', 'Position', [1, 1, finalWidthInches, finalHeightInches], 'Color', 'w');

    % Panel grid: 4 rows x 6 columns for (a) on top and for (b) below
    panelWidth   = 0.110;
    panelHeight  = 0.058;
    leftEdges    = 0.095 + (0 : 5) * 0.152;
    bottomEdgesA = 0.905 - (0 : 3) * 0.115;
    bottomEdgesB = 0.405 - (0 : 3) * 0.115;
    isInWavelengthRange = wavelengthJeti >= wavelengthLimits(1) & wavelengthJeti <= wavelengthLimits(2);

    % 2. DRAW ONE SMALL PANEL PER PATCH FOR (a) AND (b)
    % ===================================================================
    for patchIndex = 1 : numberOfPatches
        rowIndex    = ceil(patchIndex / 6);
        columnIndex = patchIndex - 6 * (rowIndex - 1);
        lineColor   = patchColors(patchIndex, :);
        if ismember(patchIndex, patchesWithGrayBackground)
            backgroundColor = [0.83, 0.83, 0.83];
        else
            backgroundColor = [1, 1, 1];
        end

        % (a) absolute spectral radiance
        axesAbsolute = axes('Position', [leftEdges(columnIndex), bottomEdgesA(rowIndex), panelWidth, panelHeight], ...
                            'Color', backgroundColor);
        hold(axesAbsolute, 'on');
        % Spectral radiance in W/(m^2 sr nm), written as a multiple of a
        % power of ten per panel (e.g. x10^-3), as in the submitted figure
        isInPlotRange = wavelengthCorrected >= wavelengthLimits(1) & wavelengthCorrected <= wavelengthLimits(2);
        maximumRadiance = max([radianceJeti(isInWavelengthRange, patchIndex); radianceSpecim(isInPlotRange, patchIndex)]);
        radianceExponent = floor(log10(maximumRadiance));
        radianceScale    = 10 ^ radianceExponent;
        plot(axesAbsolute, wavelengthCorrected, radianceSpecim(:, patchIndex) / radianceScale, '-', 'Color', lineColor, 'LineWidth', 1.25);
        plot(axesAbsolute, wavelengthJeti, radianceJeti(:, patchIndex) / radianceScale, 'k:', 'LineWidth', 1.25);
        xlim(axesAbsolute, wavelengthLimits);
        setRoundTicks(axesAbsolute, maximumRadiance / radianceScale);
        formatSmallPanel(axesAbsolute, sprintf('Sample %d', patchIndex), tickFontSize, style);
        text(axesAbsolute, 0, 1.01, sprintf('\\times10^{%d}', radianceExponent), 'Units', 'normalized', ...
             'FontName', style.fontName, 'FontSize', 5, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');

        % (b) ratio to the ground truth
        axesRatio = axes('Position', [leftEdges(columnIndex), bottomEdgesB(rowIndex), panelWidth, panelHeight], ...
                         'Color', backgroundColor);
        hold(axesRatio, 'on');
        plot(axesRatio, wavelengthLimits, [1, 1], 'k:', 'LineWidth', 1);
        plot(axesRatio, wavelengthCorrected, radianceRatio(:, patchIndex), '-', 'Color', lineColor, 'LineWidth', 1.25);
        xlim(axesRatio, wavelengthLimits);
        setRatioAxisAsSubmitted(axesRatio, radianceRatio(:, patchIndex));
        formatSmallPanel(axesRatio, sprintf('Sample %d', patchIndex), tickFontSize, style);
    end

    % 3. SHARED LABELS
    % ===================================================================
    labelAxes = axes('Position', [0, 0, 1, 1], 'Visible', 'off');
    text(labelAxes, 0.01, 0.985, '(a)', 'FontName', style.fontName, 'FontSize', style.panelLabelFontSize, 'FontWeight', 'bold');
    text(labelAxes, 0.01, 0.49, '(b)', 'FontName', style.fontName, 'FontSize', style.panelLabelFontSize, 'FontWeight', 'bold');
    text(labelAxes, 0.02, 0.76, 'Spectral radiance (W\cdotm^{-2}\cdotsr^{-1}\cdotnm^{-1})', 'Rotation', 90, ...
         'HorizontalAlignment', 'center', 'FontName', style.fontName, 'FontSize', style.axisLabelFontSize);
    % The ratio of two spectral radiances is dimensionless, so the axis has no unit
    text(labelAxes, 0.02, 0.26, 'Relative spectral radiance', 'Rotation', 90, ...
         'HorizontalAlignment', 'center', 'FontName', style.fontName, 'FontSize', style.axisLabelFontSize);
    text(labelAxes, 0.5, 0.52, 'Corrected wavelength (nm)', 'HorizontalAlignment', 'center', ...
         'FontName', style.fontName, 'FontSize', style.axisLabelFontSize);
    text(labelAxes, 0.5, 0.02, 'Corrected wavelength (nm)', 'HorizontalAlignment', 'center', ...
         'FontName', style.fontName, 'FontSize', style.axisLabelFontSize);

    % 4. SAVE
    % ===================================================================
    saveFigureForPublication(figureHandle, 'fig15', finalWidthInches, finalHeightInches);
    close(figureHandle);
end


%% LOCAL FUNCTION: formatSmallPanel
% Layout of one small panel.
function formatSmallPanel(axesHandle, titleText, tickFontSize, style)
    set(axesHandle, 'FontName', style.fontName, 'FontSize', tickFontSize, 'Box', 'on', ...
        'LineWidth', 0.5, 'XTick', 400 : 100 : 700, 'Layer', 'top');
    % Keep the tick labels horizontal (MATLAB rotates them automatically when space is tight)
    set(axesHandle, 'XTickLabelRotation', 0);
    % Title written as text, a little above the scale factor (x10^n) of the y axis
    text(axesHandle, 0.5, 1.2, titleText, 'Units', 'normalized', 'FontName', style.fontName, 'FontSize', 7, ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
end


%% LOCAL FUNCTION: setRoundTicks
% Sets the y axis from 0 to a rounded maximum, with a round tick step
% (1, 2, 2.5 or 5 times a power of ten) and at most five intervals.
function setRoundTicks(axesHandle, maximumValue)
    candidateSteps = [1, 2, 2.5, 5, 10] * 10 ^ floor(log10(maximumValue));
    candidateSteps = [candidateSteps / 10, candidateSteps];
    tickStep = min(candidateSteps(ceil(maximumValue ./ candidateSteps) <= 5));
    upperLimit = tickStep * ceil(maximumValue / tickStep);
    ylim(axesHandle, [0, upperLimit]);
    set(axesHandle, 'YTick', 0 : tickStep : upperLimit);
end


%% LOCAL FUNCTION: setRatioAxisAsSubmitted
% Follows the y axis of the ratio panels of the submitted figure (made
% with matplotlib): from 0 to the maximum ratio over all 204 bands (also
% those outside the plotted 400-780 nm range) plus a 5% margin of the data
% range, with the coarsest tick step (0.25, 0.5, 1 or 2) that gives at most
% six ticks, and tick labels with a fixed number of decimals.
function setRatioAxisAsSubmitted(axesHandle, ratioValues)
    upperLimit = max(ratioValues) + 0.05 * (max(ratioValues) - min(ratioValues));
    candidateSteps = [0.25, 0.5, 1, 2];
    tickStep = candidateSteps(find(floor(upperLimit ./ candidateSteps) + 1 <= 6, 1, 'first'));
    tickValues = 0 : tickStep : upperLimit;
    if tickStep == 0.25
        labelFormat = '%.2f';
    elseif tickStep == 0.5
        labelFormat = '%.1f';
    else
        labelFormat = '%d';
    end
    ylim(axesHandle, [0, upperLimit]);
    set(axesHandle, 'YTick', tickValues, 'YTickLabel', arrayfun(@(value) sprintf(labelFormat, value), tickValues, 'UniformOutput', false));
end
