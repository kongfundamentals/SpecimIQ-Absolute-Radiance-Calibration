%% function convertXyzToCielab
%
% Description:
%   Converts tristimulus values to CIELAB (CIE 15:2018) using a given
%   reference white. In Table 3, the white patch (No. 19) of the
%   ColorChecker measured with the JETI is used as the reference white for
%   both the test and the ground-truth data, following Raza et al. (2022).
%
% Inputs:
%   - xyz:          (M x 3) tristimulus values.
%   - xyzReference: (1 x 3) tristimulus values of the reference white.
%
% Outputs:
%   - lab: (M x 3) [L*, a*, b*].
%
% Authors:
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%
% Last updated:
%   October-29-2026
%

function lab = convertXyzToCielab(xyz, xyzReference)

    relativeXyz = xyz ./ repmat(xyzReference, size(xyz, 1), 1);

    % Cube-root compression with the linear segment for dark colours
    linearLimit = (24 / 116) ^ 3;
    compressedXyz = relativeXyz .^ (1 / 3);
    isDark = relativeXyz <= linearLimit;
    compressedXyz(isDark) = (841 / 108) * relativeXyz(isDark) + 16 / 116;

    lab = [116 * compressedXyz(:, 2) - 16, ...
           500 * (compressedXyz(:, 1) - compressedXyz(:, 2)), ...
           200 * (compressedXyz(:, 2) - compressedXyz(:, 3))];

    % L* in the linear segment
    isDarkY = isDark(:, 2);
    lab(isDarkY, 1) = (841 / 108) * 116 * relativeXyz(isDarkY, 2);
end
