%% function computeTristimulusValues
%
% Description:
%   Computes absolute CIE 1931 (2-degree) tristimulus values XYZ from
%   spectral radiance. Y is the luminance in cd/m^2.
%
%   The calculation follows luxpy (v1.6, spd_to_xyz with relative = false),
%   which was used in the original analysis, so that the published values
%   are reproduced exactly:
%     - the colour-matching functions are linearly interpolated to the
%       wavelengths of the spectrum (end values replicated outside 360-830 nm),
%     - the wavelength step of every sample is the mean distance to its
%       neighbours, which also handles the non-equidistant Specim IQ bands,
%     - XYZ = Km * sum(Le(lambda) * cmf(lambda) * dLambda), Km = 683.002 lm/W.
%
% Inputs:
%   - wavelength:       (N x 1) wavelengths of the spectra [nm].
%   - spectralRadiance: (N x M) spectral radiance [W/(m^2 sr nm)], one column per spectrum.
%   - cmfTable:         (L x 4) colour-matching functions [lambda, xBar, yBar, zBar]
%                       (see loadColorMatchingFunctions).
%   - luminousEfficacy: (double) Km [lm/W].
%
% Outputs:
%   - xyz: (M x 3) absolute tristimulus values, one row per spectrum.
%
% Authors:
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%
% Last updated:
%   October-29-2026
%

function xyz = computeTristimulusValues(wavelength, spectralRadiance, cmfTable, luminousEfficacy)

    wavelength = wavelength(:);
    if isvector(spectralRadiance), spectralRadiance = spectralRadiance(:); end

    % 1. Wavelength step of every sample (handles unequal spacing)
    stepBetweenSamples = diff(wavelength);
    wavelengthStep = [stepBetweenSamples(1); stepBetweenSamples(1 : end-1) / 2; stepBetweenSamples(end)] ...
                   + [0; stepBetweenSamples(2 : end) / 2; 0];

    % 2. Colour-matching functions at the wavelengths of the spectrum
    cmfAtWavelength = zeros(numel(wavelength), 3);
    for componentIndex = 1 : 3
        cmfAtWavelength(:, componentIndex) = interp1(cmfTable(:, 1), cmfTable(:, componentIndex + 1), ...
                                                     wavelength, 'linear');
        % Replicate the end values outside the tabulated range (luxpy behaviour)
        cmfAtWavelength(wavelength < cmfTable(1, 1),   componentIndex) = cmfTable(1,   componentIndex + 1);
        cmfAtWavelength(wavelength > cmfTable(end, 1), componentIndex) = cmfTable(end, componentIndex + 1);
    end

    % 3. Discrete integration
    weightedCmf = cmfAtWavelength .* repmat(wavelengthStep, 1, 3);
    xyz = luminousEfficacy * (spectralRadiance' * weightedCmf);
end
