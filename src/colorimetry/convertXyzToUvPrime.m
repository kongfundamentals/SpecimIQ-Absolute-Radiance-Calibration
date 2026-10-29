%% function convertXyzToUvPrime
%
% Description:
%   Converts tristimulus values to CIE 1976 UCS chromaticity coordinates.
%       u' = 4X / (X + 15Y + 3Z),   v' = 9Y / (X + 15Y + 3Z)
%
% Inputs:
%   - xyz: (M x 3) tristimulus values.
%
% Outputs:
%   - uvPrime: (M x 2) chromaticity coordinates [u', v'].
%
% Authors:
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%
% Last updated:
%   October-29-2026
%

function uvPrime = convertXyzToUvPrime(xyz)

    denominator = xyz(:, 1) + 15 * xyz(:, 2) + 3 * xyz(:, 3);
    uvPrime = [4 * xyz(:, 1) ./ denominator, 9 * xyz(:, 2) ./ denominator];
end
