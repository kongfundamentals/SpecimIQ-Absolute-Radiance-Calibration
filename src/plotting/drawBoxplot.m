%% function drawBoxplot
%
% Description:
%   Draws box-and-whisker plots with the same conventions as MATLAB's
%   boxplot (Statistics and Machine Learning Toolbox), so that Figure 7
%   can be reproduced without that toolbox:
%     - box from the 25th to the 75th percentile, line at the median,
%     - percentiles computed as in MATLAB's prctile (midpoint method),
%     - whiskers to the most extreme data within 1.5 x IQR of the box,
%     - values beyond the whiskers drawn as red '+' outliers.
%
% Inputs:
%   - axesHandle: axes to draw in.
%   - values:     (n x groups) data; every column is one box.
%   - boxWidth:   (optional) total width of a box in x units (default 0.5).
%
% Authors:
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%
% Last updated:
%   October-29-2026
%

function drawBoxplot(axesHandle, values, boxWidth)

    if nargin < 3, boxWidth = 0.5; end
    halfWidth  = boxWidth / 2;
    capWidth   = boxWidth / 4;
    hold(axesHandle, 'on');

    for groupIndex = 1 : size(values, 2)
        groupValues = sort(values(:, groupIndex));
        quartiles   = computePercentile(groupValues, [25, 50, 75]);
        interQuartileRange = quartiles(3) - quartiles(1);

        upperLimit = quartiles(3) + 1.5 * interQuartileRange;
        lowerLimit = quartiles(1) - 1.5 * interQuartileRange;
        upperWhisker = max(groupValues(groupValues <= upperLimit));
        lowerWhisker = min(groupValues(groupValues >= lowerLimit));
        outliers = groupValues(groupValues > upperLimit | groupValues < lowerLimit);

        x = groupIndex;
        % Box and median
        plot(axesHandle, [x - halfWidth, x + halfWidth, x + halfWidth, x - halfWidth, x - halfWidth], ...
             [quartiles(1), quartiles(1), quartiles(3), quartiles(3), quartiles(1)], 'k-', 'LineWidth', 0.75);
        plot(axesHandle, [x - halfWidth, x + halfWidth], [quartiles(2), quartiles(2)], 'k-', 'LineWidth', 1);
        % Whiskers and caps
        plot(axesHandle, [x, x], [quartiles(3), upperWhisker], 'k--', 'LineWidth', 0.75);
        plot(axesHandle, [x, x], [lowerWhisker, quartiles(1)], 'k--', 'LineWidth', 0.75);
        plot(axesHandle, [x - capWidth, x + capWidth], [upperWhisker, upperWhisker], 'k-', 'LineWidth', 0.75);
        plot(axesHandle, [x - capWidth, x + capWidth], [lowerWhisker, lowerWhisker], 'k-', 'LineWidth', 0.75);
        % Outliers
        if ~isempty(outliers)
            plot(axesHandle, repmat(x, size(outliers)), outliers, 'r+', 'MarkerSize', 6);
        end
    end
end


%% LOCAL FUNCTION: computePercentile
% Percentiles of sorted data with MATLAB's prctile definition: the sorted
% values are placed at the percentages 100*((1:n) - 0.5)/n and linearly
% interpolated; values outside this range take the minimum or maximum.
function percentileValues = computePercentile(sortedValues, percentages)

    numberOfValues = numel(sortedValues);
    samplePercentages = 100 * ((1 : numberOfValues)' - 0.5) / numberOfValues;
    percentileValues = interp1(samplePercentages, sortedValues, percentages, 'linear');
    percentileValues(percentages < samplePercentages(1))   = sortedValues(1);
    percentileValues(percentages > samplePercentages(end)) = sortedValues(end);
end
