%% function getFigureStyle
%
% Description:
%   Common layout settings of all figures, so that every figure of the
%   publication has the same fonts, line widths and column widths
%   (8 cm for a one-column figure and 16 cm for a two-column figure, with
%   Arial 10, as in the figures submitted to Color Research & Application).
%
% Outputs:
%   - style: struct with fonts, font sizes, line widths and figure widths.
%
% Authors:
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%
% Last updated:
%   October-29-2026
%

function style = getFigureStyle()

    % Arial 10 for all text, as in the figures submitted to the journal
    style.fontName           = 'Arial';
    style.axisLabelFontSize  = 10;
    style.axisTickFontSize   = 10;
    style.titleFontSize      = 10;
    style.panelLabelFontSize = 10;
    style.legendFontSize     = 10;
    style.lineWidth          = 1;
    style.axesLineWidth      = 0.5;

    style.oneColumnWidth = 8 / 2.54;    % 8 cm [inch]
    style.twoColumnWidth = 16 / 2.54;   % 16 cm [inch]
end
