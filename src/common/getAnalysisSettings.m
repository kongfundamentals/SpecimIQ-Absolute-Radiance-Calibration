%% function getAnalysisSettings
%
% Description:
%   Central place for the measurement identifiers (folder names, capture
%   numbers, pixels and bands) used in the analysis, grouped by topic. The
%   topic names are the same as the folder names in /src and in
%   /data/rawData/hyperspectralImages. Every number in this file is
%   described in the associated publication (section numbers are given in
%   the comments).
%
% Outputs:
%   - settings: struct with the analysis constants (see comments below).
%
% Authors:
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%
% Last updated:
%   October-29-2026
%

function settings = getAnalysisSettings()

    % ---------------------------------------------------------------
    % General constants (the camera constants, such as the dark offset
    % and the wavelength error, are in loadCameraSpecificData.m)
    % ---------------------------------------------------------------
    % Luminous efficacy constant used for the CIE 1931 2-degree observer
    % (identical to the value used by the luxpy toolbox in the original analysis)
    settings.maximumLuminousEfficacy = 683.002;

    % Wavelength range used for the RMSE and the mean spectral radiance
    % in Tables 2 and 3 [nm]
    settings.rmseWavelengthRange = [400, 780];

    % ---------------------------------------------------------------
    % Section 3.1 - Repeatability (Figures 2 and 3)
    % ---------------------------------------------------------------
    settings.repeatability.folderName     = 'repeatability';
    settings.repeatability.hsiNumbers     = 313 : 373;    % 61 captures, 1 per minute, t = 1 ms
    settings.repeatability.pixel          = [251, 262];   % central pixel (i, j) of the source aperture
    % Eight non-central pixels (i, j) of the source aperture, taken from the
    % original analysis script (CVAnalysisForMultiplePixelLocations.m)
    settings.repeatability.nonCentralPixels = [251 249; 251 275; 242 262; 260 262; ...
                                               257 255; 257 268; 245 255; 245 268];
    settings.repeatability.bandsToPlot    = [25, 50, 100, 150, 200];
    settings.repeatability.significance   = 0.05;         % Lilliefors normality test

    % ---------------------------------------------------------------
    % Section 3.2 - Linearity with integration time (Figure 4)
    % ---------------------------------------------------------------
    settings.linearity.folderName   = 'linearity';
    settings.linearity.hsiNumbers   = [460, 463, 466, 469, 472, 475, 476];  % t = 1, 5, 25, 100, 200, 215, 235 ms
    settings.linearity.bands        = 25 : 5 : 50;
    % Ten randomly chosen pixels (i, j) of the OLED panel
    settings.linearity.pixels       = [294 216; 304 309; 217 308; 305 253; 273 290; ...
                                       213 214; 234 246; 264 303; 310 289; 311 308];
    settings.linearity.pixelsToPlot = [1, 3];  % (294, 216) and (217, 308) are shown in Figure 4

    % ---------------------------------------------------------------
    % Section 3.2 - Dark current (Figure 5)
    % ---------------------------------------------------------------
    settings.darkCurrent.folderName = 'darkCurrent';
    settings.darkCurrent.hsiNumbers = 374 : 382;  % t = 1, 5, 10, 50, 100, 200, 300, 400, 500 ms (lens cap on)
    settings.darkCurrent.bandToPlot = 100;

    % ---------------------------------------------------------------
    % Section 3.3 - Flat field behavior and spatial responsivity uniformity (Figures 6 and 7)
    % ---------------------------------------------------------------
    settings.flatFieldBehavior.folderName    = 'flatFieldBehavior';
    settings.flatFieldBehavior.hsiNumbers    = [222, 224, 225, 226, 227];
    settings.flatFieldBehavior.positionNames = {'Center', 'BR', 'BL', 'TL', 'TR'};
    % Center pixel (i, j) of the calibration source aperture in each capture
    settings.flatFieldBehavior.centerPixels  = [237 311; 441 463; 76 469; 74 87; 411 89];
    settings.flatFieldBehavior.halfWidth     = 5;          % 11 x 11 pixel area
    settings.flatFieldBehavior.bands         = [55, 100];
    settings.flatFieldBehavior.bandForImage  = 19;         % band displayed in Figure 6b
    settings.flatFieldBehavior.zoomHalfWidth = 16;         % half width of the zoomed image in Figure 6b (33 x 33 px, as submitted)

    % ---------------------------------------------------------------
    % Section 3.4 - Wavelength calibration (Figure 8, Table 1)
    % ---------------------------------------------------------------
    settings.wavelengthCalibration.folderName = 'wavelengthCalibration';
    settings.wavelengthCalibration.hsiNumber  = 255;          % helium lamp, t = 10 ms
    settings.wavelengthCalibration.pixel      = [254, 250];
    % Band numbers of the eight helium peaks identified in the spectrum
    settings.wavelengthCalibration.peakBands  = [19, 27, 34, 38, 67, 94, 107, 115];
    % Theoretical helium emission lines (Table 1) [nm]
    settings.wavelengthCalibration.theoreticalPeaks = [447.1, 471.3, 492.1, 504.7, 587.5, 667.8, 706.5, 728.1];
    % Width of the horizontal bandwidth markers in Figure 8 [nm]
    settings.wavelengthCalibration.bandwidthMarkerWidth = 12;

    % ---------------------------------------------------------------
    % Section 3.5 - Spectral radiance calibration (Figures 9-11)
    % ---------------------------------------------------------------
    settings.radianceCalibration.folderName        = 'radianceCalibration';
    settings.radianceCalibration.hsiNumbers        = [240, 241, 242];   % three repeated captures, t = 1 ms
    settings.radianceCalibration.centerPixels      = [259 248; 257 248; 257 248];  % (i, j) for Figure 9
    settings.radianceCalibration.hsiNumberForFactor = 242;              % capture used for C(lambda)
    settings.radianceCalibration.jetiFile          = 'radianceCalibration_jeti.csv';
    % JETI measurements #21-#30 were taken perpendicular to the source
    % aperture right after the Specim IQ captures (see README.md, section Data)
    settings.radianceCalibration.jetiMeasurements  = 21 : 30;

    % ---------------------------------------------------------------
    % Section 4.1 - Validation with an OLED panel (Figure 14, Table 2)
    % ---------------------------------------------------------------
    settings.oledValidation.folderName   = 'oledValidation';
    settings.oledValidation.hsiNumbers   = [397, 398];   % two repeated captures, t = 70 ms
    settings.oledValidation.spotNames    = {'topLeft', 'topRight', 'center', 'bottomLeft', 'bottomRight'};
    settings.oledValidation.jetiFile     = 'oledValidation_jeti.csv';
    % JETI targets (5 repeats each): 1-24 ColorChecker patches, 25-29 OLED spots
    settings.oledValidation.jetiTargets  = 25 : 29;
    settings.oledValidation.repeatsPerTarget = 5;
    settings.oledValidation.lmkFile      = 'oledValidation_lmkRegionMeans.csv';
    settings.oledValidation.lmkRegions   = 25 : 29;

    % ---------------------------------------------------------------
    % Section 4.2 - Validation with a Macbeth ColorChecker (Figure 15, Table 3)
    % ---------------------------------------------------------------
    settings.colorCheckerValidation.folderName        = 'colorCheckerValidation';
    settings.colorCheckerValidation.calibrationHsiNumber = 809;   % calibration source, t = 3 ms (C'(lambda))
    settings.colorCheckerValidation.sceneHsiNumber    = 819;      % ColorChecker, t = 150 ms
    settings.colorCheckerValidation.calibrationJetiFile = 'colorCheckerValidation_calibrationSource_jeti.csv';
    settings.colorCheckerValidation.patchJetiFile     = 'colorCheckerValidation_patches_jetiAverage.csv';
    settings.colorCheckerValidation.lmkFile           = 'colorCheckerValidation_lmkRegionMeans.csv';
    settings.colorCheckerValidation.lmkRegions        = 1 : 24;
    settings.colorCheckerValidation.whitePatch        = 19;       % reference white for CIELAB (Raza et al., 2022)
    settings.colorCheckerValidation.patchNames = {'Dark skin', 'Light skin', 'Blue sky', 'Foliage', 'Blue flower', 'Bluish green', ...
                                        'Orange', 'Purplish blue', 'Moderate red', 'Purple', 'Yellow green', 'Orange yellow', ...
                                        'Blue', 'Green', 'Red', 'Yellow', 'Magenta', 'Cyan', ...
                                        'White', 'Neutral 8', 'Neutral 6.5', 'Neutral 5', 'Neutral 3.5', 'Black'};
end
