%% function formatAxes
%
% Description:
%   Applies the common axes layout (font, box, grid, line widths) and
%   optionally the axis labels and a panel label such as '(a)'.
%
% Inputs:
%   - axesHandle: axes to format.
%   - xLabelText: (optional) x-axis label ('' to skip).
%   - yLabelText: (optional) y-axis label ('' to skip).
%   - panelLabel: (optional) panel label, e.g. '(a)' ('' to skip).
%
% Authors:
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%
% Last updated:
%   October-29-2026
%

function formatAxes(axesHandle, xLabelText, yLabelText, panelLabel)

    style = getFigureStyle();
    set(axesHandle, 'FontName', style.fontName, 'FontSize', style.axisTickFontSize, ...
        'LineWidth', style.axesLineWidth, 'Box', 'on', 'TickDir', 'in');
    grid(axesHandle, 'on');

    if nargin > 1 && ~isempty(xLabelText)
        xlabel(axesHandle, xLabelText, 'FontName', style.fontName, 'FontSize', style.axisLabelFontSize);
    end
    if nargin > 2 && ~isempty(yLabelText)
        ylabel(axesHandle, yLabelText, 'FontName', style.fontName, 'FontSize', style.axisLabelFontSize);
    end
    if nargin > 3 && ~isempty(panelLabel)
        % Panel label above the top-left corner of the axes, 9 points above
        % the box, so that it does not touch the top tick label
        set(axesHandle, 'Units', 'points');
        axesPositionPoints = get(axesHandle, 'Position');
        set(axesHandle, 'Units', 'normalized');
        text(axesHandle, 0, 1 + 9 / axesPositionPoints(4), panelLabel, 'Units', 'normalized', ...
             'FontName', style.fontName, 'FontSize', style.panelLabelFontSize, 'FontWeight', 'bold', ...
             'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');
    end
end
