%% function interpolateSpectrum
%
% Description:
%   Resamples spectral data to new wavelengths, following the procedure of
%   the luxpy toolbox (v1.6, function cie_interp with kind = 'spd') that
%   was used in the original analysis:
%     - cubic spline interpolation (not-a-knot end conditions),
%     - extrapolation by replicating the closest measured value
%       (CIE 15 recommendation),
%     - negative values are set to zero.
%
%   It is used to bring the 1-nm JETI spectra to the (non-equidistant)
%   centre wavelengths of the Specim IQ bands.
%
% Inputs:
%   - wavelength:          (N x 1) wavelengths of the input data [nm].
%   - spectra:             (N x M) spectral data, one spectrum per column.
%   - wavelengthResampled: (P x 1) target wavelengths [nm].
%
% Outputs:
%   - spectraResampled:    (P x M) resampled spectra.
%
% Authors:
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%
% Last updated:
%   October-29-2026
%

function spectraResampled = interpolateSpectrum(wavelength, spectra, wavelengthResampled)

    wavelength          = wavelength(:);
    wavelengthResampled = wavelengthResampled(:);
    if isvector(spectra), spectra = spectra(:); end

    % Cubic spline inside the measured range
    spectraResampled = interp1(wavelength, spectra, wavelengthResampled, 'spline');
    if isvector(spectraResampled), spectraResampled = spectraResampled(:); end

    % Replicate the end values outside the measured range
    belowRange = wavelengthResampled < wavelength(1);
    aboveRange = wavelengthResampled > wavelength(end);
    spectraResampled(belowRange, :) = repmat(spectra(1, :),   sum(belowRange), 1);
    spectraResampled(aboveRange, :) = repmat(spectra(end, :), sum(aboveRange), 1);

    % Spectral radiance cannot be negative
    spectraResampled(spectraResampled < 0) = 0;
end
