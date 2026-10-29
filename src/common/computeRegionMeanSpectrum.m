%% function computeRegionMeanSpectrum
%
% Description:
%   Averages the digital counts of a rectangular pixel region for every
%   spectral band.
%
% Inputs:
%   - digitalCounts: (lines x samples x bands) hyperspectral cube.
%   - region:        struct with fields .iRange and .jRange (see readRegionsOfInterest).
%
% Outputs:
%   - meanSpectrum: (bands x 1) mean digital counts of the region.
%
% Authors:
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%
% Last updated:
%   October-29-2026
%

function meanSpectrum = computeRegionMeanSpectrum(digitalCounts, region)

    regionCounts = digitalCounts(region.iRange, region.jRange, :);
    numberOfPixels = numel(region.iRange) * numel(region.jRange);
    meanSpectrum = reshape(sum(sum(regionCounts, 1), 2), [], 1) / numberOfPixels;
end
