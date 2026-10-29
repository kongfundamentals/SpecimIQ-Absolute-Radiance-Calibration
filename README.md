# Measuring Absolute Radiance by Calibrating a Hyperspectral Camera Economically: Code and Data

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.13136174.svg)](https://doi.org/10.5281/zenodo.13136174)

This repository provides the source code and data needed to reproduce the data figures (Figures 2–11, 14 and 15) and Tables 1–3 of our publication:

> Xiangzhen Kong, Ching-Wei Lin, & Peter Hanselaer. (2026). *Measuring Absolute Radiance by Calibrating a Hyperspectral Camera Economically*. Color Research & Application, 51(2). DOI: [10.1002/col.70043](https://doi.org/10.1002/col.70043).

The paper characterises and calibrates a commercial hyperspectral camera (Specim IQ) for absolute spectral radiance measurements, using a factory-calibrated spectroradiometer (JETI Specbos 1211L), a helium lamp and a stable broadband calibration source. The calibration is validated with an OLED panel and a Macbeth ColorChecker.

This README is the only documentation file of the repository; every folder is described below.

## Quick Start

Open MATLAB in the root folder of the repository and run:
```matlab
runAllFigures          % creates all figures and tables in /output (about 1 minute)
verifyReproduction     % checks the results and writes /output/verificationLog.txt
```
The processed data are included in `/data/processedData`, so this works directly after downloading the repository. A single figure or table can be made with, for example, `addpath(genpath('src')); plotFigure11`.

To reproduce everything from the raw hyperspectral images:
1. Download the raw hyperspectral images (about 9.4 GB, one zip file per experiment) from Zenodo: [https://doi.org/10.5281/zenodo.13136174](https://doi.org/10.5281/zenodo.13136174).
2. Unzip them into `/data/rawData/hyperspectralImages`, so that, for example, the file `/data/rawData/hyperspectralImages/repeatability/313/capture/313.raw` exists.
3. Run (about 10–15 minutes):
```matlab
runAllAnalyses         % raw hyperspectral images -> /data/processedData
runAllFigures
verifyReproduction
```

## System Requirements

* MATLAB R2021a or newer (tested with R2024a).
* No toolboxes are needed for the figures and tables. The Lilliefors normality test in `analyzeRepeatability` (Section 3.1) uses the Statistics and Machine Learning Toolbox; it is skipped if the toolbox is not installed.
* The raw hyperspectral images are read with MATLAB's `multibandread`. The code also runs in GNU Octave 8.4 (tested), which has no `multibandread`; there the images are read with `fread`, with identical results.

## Repository Structure

The code and the raw hyperspectral images are organised by topic. Each topic corresponds to one section of the paper and has the same name in `/src` and in `/data/rawData/hyperspectralImages`.

```
├── README.md                      this file
├── runAllAnalyses.m               raw hyperspectral images -> processed data
├── runAllFigures.m                processed data -> figures and tables
├── verifyReproduction.m           compares the results with /tests/referenceResults
├── src/
│   ├── repeatability/             Section 3.1   analyzeRepeatability, plotFigure2, plotFigure3
│   ├── linearity/                 Section 3.2   analyzeLinearity, plotFigure4
│   ├── darkCurrent/               Section 3.2   analyzeDarkCurrent, plotFigure5
│   ├── flatFieldBehavior/         Section 3.3   analyzeFlatFieldBehavior, plotFigure6, plotFigure7
│   ├── wavelengthCalibration/     Section 3.4   analyzeWavelengthCalibration, plotFigure8, createTable1
│   ├── radianceCalibration/       Section 3.5   analyzeRadianceCalibration, plotFigure9, plotFigure10, plotFigure11
│   ├── oledValidation/            Section 4.1   analyzeOledValidation, plotFigure14, createTable2
│   ├── colorCheckerValidation/    Section 4.2   analyzeColorCheckerValidation, plotFigure15, createTable3
│   ├── common/                    camera constants, reading the raw cubes and the data files, settings
│   ├── colorimetry/               spectral interpolation, XYZ, u'v', CIELAB, comparison with the ground truth
│   └── plotting/                  figure style and saving
├── data/
│   ├── rawData/
│   │   ├── hyperspectralImages/   raw Specim IQ captures, one folder per topic (download from Zenodo)
│   │   ├── spectroradiometer/     JETI Specbos 1211L spectral radiance (ground truth)
│   │   ├── colorCamera/           LMK 6-5 colour camera region means
│   │   └── regionsOfInterest/     pixel areas used in Sections 3.5 and 4
│   ├── externalData/              CIE 1931 2° colour-matching functions
│   └── processedData/             output of the analyze* scripts, input of the figure scripts
├── tests/referenceResults/        reference results of this release (used by verifyReproduction)
└── output/                        generated figures and tables (created by runAllFigures)
```

In every topic folder, `analyze<Topic>.m` reads the raw hyperspectral images and writes the results to `/data/processedData`; the `plotFigureN.m` and `createTableN.m` scripts read only `/data/processedData` and the small files in `/data/rawData`. Every `.m` file starts with a header that describes its inputs and outputs.

The most important shared functions are:
* `src/common/loadCameraSpecificData.m`: the constants of the Specim IQ camera (cube size, factory wavelengths, dark offset 239 and wavelength error 1.88 nm).
* `src/common/readHyperspectralDataCube.m`: reads one raw capture.
* `src/common/getAnalysisSettings.m`: the captures, pixels and bands used for each topic.

### Figures and tables

| Figure / Table | Content | Analysis | Figure / table script |
|---|---|---|---|
| Fig. 2, 3 | Repeatability (Section 3.1) | `analyzeRepeatability` | `plotFigure2`, `plotFigure3` |
| Fig. 4 | Linearity with integration time (Section 3.2) | `analyzeLinearity` | `plotFigure4` |
| Fig. 5 | Dark current (Section 3.2) | `analyzeDarkCurrent` | `plotFigure5` |
| Fig. 6, 7 | Flat field behavior and spatial responsivity uniformity (Section 3.3) | `analyzeFlatFieldBehavior` | `plotFigure6`, `plotFigure7` |
| Fig. 8, Table 1 | Wavelength calibration with a helium lamp (Section 3.4) | `analyzeWavelengthCalibration` | `plotFigure8`, `createTable1` |
| Fig. 9–11 | Spectral radiance calibration (Section 3.5) | `analyzeRadianceCalibration` | `plotFigure9`, `plotFigure10`, `plotFigure11` |
| Fig. 14, Table 2 | Validation with an OLED panel (Section 4.1) | `analyzeOledValidation` | `plotFigure14`, `createTable2` |
| Fig. 15, Table 3 | Validation with a Macbeth ColorChecker (Section 4.2) | `analyzeColorCheckerValidation` | `plotFigure15`, `createTable3` |

Figures 1, 12 and 13 are not data figures (an illustration adapted from the literature, a flowchart and a photograph of the setup) and are not part of this repository. The figures are generated with the sizes, fonts, axis ranges and ticks of the figures submitted to the journal (one-column figures 8 cm wide, Arial 10).

## Data

### Raw hyperspectral images (`/data/rawData/hyperspectralImages`)

The raw Specim IQ captures are **not stored on GitHub** because of their size. Download them from Zenodo (one zip file per folder below) and unzip them into this folder. Every capture keeps the original folder structure of the camera:

```
<topic>/<captureNumber>/
    capture/<captureNumber>.hdr          ENVI header (wavelengths, integration time "tint")
    capture/<captureNumber>.raw          raw digital counts, 512 x 512 x 204, uint16, BIL order
    capture/DARKREF_<captureNumber>.*    dark reference recorded automatically by the camera (not used)
    capture/WHITEREF_<captureNumber>.*   white reference recorded automatically by the camera (not used)
    metadata/<captureNumber>.xml         capture metadata
    manifest.xml, <captureNumber>.png    camera files (preview image)
```
The reflectance products computed by the camera (`results/` folder) are not included, because they are not used in the paper.

| Folder | Measured on | Captures | Integration time | Content | Used in |
|---|---|---|---|---|---|
| `repeatability` | 17 Feb 2022 | 313–373 | 1 ms | Calibration source, one capture per minute for 60 minutes | Section 3.1, Figs. 2–3 |
| `linearity` | 20 May 2021 | 460, 463, 466, 469, 472, 475, 476 | 1, 5, 25, 100, 200, 215, 235 ms | OLED panel (OLEDWorks Brite 3 FL300) | Section 3.2, Fig. 4 |
| `darkCurrent` | 17 Feb 2022 | 374–382 | 1, 5, 10, 50, 100, 200, 300, 400, 500 ms | Dark frames (lens cap on) | Section 3.2, Fig. 5 |
| `flatFieldBehavior` | 28 Jun 2021 | 222, 224, 225, 226, 227 | 1 ms | Calibration source (Bentham SRS8Q) at the centre, bottom-right, bottom-left, top-left and top-right of the field of view | Section 3.3, Figs. 6–7 |
| `wavelengthCalibration` | 14 Sep 2021 | 253, 254, 255 | 1, 10, 10 ms | Helium discharge lamp (capture 255 is used) | Section 3.4, Fig. 8, Table 1 |
| `radianceCalibration` | 7 Sep 2021 | 240, 241, 242 | 1 ms | Calibration source at the centre of the field of view, three repeats | Section 3.5, Figs. 9 and 11 |
| `oledValidation` | 18 Feb 2022 | 397, 398 | 70 ms | OLED panel and Macbeth ColorChecker scene, two repeats | Section 4.1, Fig. 14, Table 2 |
| `colorCheckerValidation` | 8 Aug 2023 | 809, 819 | 3 ms, 150 ms | 809: calibration source at 1.0 m; 819: Macbeth ColorChecker | Section 4.2, Fig. 15, Table 3 |

The capture numbers are the numbers assigned by the camera, which numbers its captures consecutively.

### Spectroradiometer data (`/data/rawData/spectroradiometer`)

Spectral radiance in W/(m² sr nm), measured with a factory-calibrated JETI Specbos 1211L spectroradiometer. These data are the ground truth of the paper. The files with a metadata header are exports of the JETI LiVal software (measurement settings and photometric values such as Lv and CIE 1931 x, y, followed by the spectral data).

| File | Original file name | Content |
|---|---|---|
| `radianceCalibration_jeti.csv` | `RadianceStandard20210907_beforeAndAfterSpecIMIQ.csv` | 30 measurements of the calibration source (350–1000 nm, 1 nm steps). #1–#10: perpendicular, before the Specim IQ captures; #11–#20: from a small angle (< 5°); #21–#30: perpendicular, after the Specim IQ captures. Measurements #21–#30 are averaged for the calibration (Fig. 10). |
| `oledValidation_jeti.csv` | `350_1000JETI.csv` | 145 measurements (380–780 nm, 1 nm steps): 29 targets x 5 repeats. Targets 1–24: ColorChecker patches; targets 25–29: OLED spots top-left, top-right, centre, bottom-left, bottom-right (Section 4.1). |
| `colorCheckerValidation_calibrationSource_jeti.csv` | `CalLamp_NoFliter_sameTime_As3ms_2023-08-08-16-58-01.csv` | Calibration source at 1.0 m, measured at the same time as Specim IQ capture 809. Row 1: wavelength (nm); row 2: spectral radiance. |
| `colorCheckerValidation_patches_jetiAverage.csv` | `JetiAvg_MCC.csv` | Mean of five measurements at the centre of each of the 24 ColorChecker patches. Row 1: wavelength (nm); rows 2–25: patches 1–24. |

### Colour camera data (`/data/rawData/colorCamera`)

Mean CIE 1931 tristimulus values X, Y, Z (Y = luminance in cd/m²) of rectangular regions, exported from the LabSoft software of the calibrated TechnoTeam LMK 6-5 color camera. They are used for the comparison with a calibrated colour camera in Tables 2 and 3. Columns: `image` (LMK image name), `region` (region number), `areaPixels` (number of camera pixels in the region), `X`, `Y`, `Z`.

| File | Content |
|---|---|
| `oledValidation_lmkRegionMeans.csv` | Three HDR images (`..._1` to `..._3`) of the OLED and ColorChecker scene. Regions 1–24: ColorChecker patches; regions 25–29: OLED spots top-left, top-right, centre, bottom-left, bottom-right. The values of the three images are averaged. |
| `colorCheckerValidation_lmkRegionMeans.csv` | One HDR image of the ColorChecker. Regions 1–24: ColorChecker patches 1–24 (regions 25–42 are smaller test regions that are not used). |

### Regions of interest (`/data/rawData/regionsOfInterest`)

`regionsOfInterest.csv` lists the rectangular pixel areas used in Sections 3.5 and 4, as inclusive index ranges `iMin:iMax` and `jMin:jMax` of the cube returned by `readHyperspectralDataCube.m`:
* `jetiArea`: the calibration area on the calibration source (7 x 7 pixels in 2021, 13 x 13 pixels in 2023),
* `topLeft` ... `bottomRight`: the five 11 x 11 pixel spots on the OLED panel,
* `patch01` ... `patch24`: the central 13 x 13 pixel area of every ColorChecker patch.

The areas were defined in the original Python analysis, in a rotated image orientation, in the coordinate files in `originalCoordinateFiles/` (versions used: OLED `v05`, OLED measuring area `v00`, calibration source 2021 `v03`, calibration source 2023 `v01`, ColorChecker `v03`, ColorChecker measuring area `v02`). They were converted to the orientation of this repository with `i = 512 - x` and `j = y + 1`, where (x, y) are the zero-based column and row indices of the rotated image. With these areas the calibration factors of the original analysis are reproduced exactly. The pixel positions used in Sections 3.1–3.4 are defined in `src/common/getAnalysisSettings.m`.

### External data (`/data/externalData`)

`cie1931_2deg_colorMatchingFunctions.csv`: CIE 1931 2° standard observer colour-matching functions, 360–830 nm in 1 nm steps (wavelength, x̄, ȳ, z̄), from CIE (2019), *CIE 1931 colour-matching functions, 2 degree observer*, DOI: [10.25039/CIE.DS.xvudnb9b](https://doi.org/10.25039/CIE.DS.xvudnb9b). This is the same table that is used by the luxpy toolbox in the original analysis.

### Processed data (`/data/processedData`)

Written by the `analyze<Topic>.m` scripts (`runAllAnalyses.m`) and read by the figure and table scripts. Wavelengths are in nm, spectral radiance in W/(m² sr nm), and the calibration factor in W·s/(m² sr nm count) with the integration time in ms.

| File | Written by | Content |
|---|---|---|
| `repeatability.mat`, `repeatabilityStatistics.csv`, `repeatabilityNonCentralPixels.csv` | `analyzeRepeatability` | I(251, 262, k) of the 61 captures; mean, standard deviation, CV and Lilliefors test per band; maximum CV of the eight non-central pixels |
| `linearity.mat`, `linearityFitResults.csv`, `linearityInterceptStatistics.csv` | `analyzeLinearity` | Digital counts of 10 pixels x 6 bands x 7 integration times, linear fits, intercept statistics and ANOVA |
| `darkCurrent.mat`, `darkCurrentStatistics.csv` | `analyzeDarkCurrent` | Dark frames of band k = 100; statistics of all dark values |
| `flatFieldBehavior.mat`, `flatFieldBehaviorStatistics.csv` | `analyzeFlatFieldBehavior` | β1 ratios of the 11 x 11 areas at five positions; zoomed image for Fig. 6b |
| `heliumSpectrum.csv`, `heliumPeaks.csv` | `analyzeWavelengthCalibration` | Dark corrected helium spectrum; peak table with discrepancy and FWHM |
| `calibrationSourceCounts.csv`, `calibrationSourceJeti.csv`, `calibrationFactor.csv` | `analyzeRadianceCalibration` | I′ of the calibration source; mean JETI spectrum; calibration factor C(λ) with spatial CV, and C(λ) without wavelength correction |
| `oledRadianceSpecim.csv`, `oledRadianceJeti.csv` | `analyzeOledValidation` | Reconstructed and ground-truth spectral radiance of the five OLED spots |
| `calibrationFactorColorChecker.csv`, `colorCheckerRadianceSpecim.csv` | `analyzeColorCheckerValidation` | Calibration factor C′(λ); reconstructed spectral radiance of the 24 patches |

### Reference results (`/tests/referenceResults`)

Copies of the processed data and of the generated tables of this release. `verifyReproduction.m` compares your results with these files (relative tolerance 1e-6). The Lilliefors column of `repeatabilityStatistics.csv` is not compared, because it requires a toolbox. Do not edit these files.

## Conventions Used in the Code

* **Pixel coordinates.** A Specim IQ cube is read as `I(i, j, k)` with the same orientation as MATLAB's `multibandread(..., 'bil')`: `i` is the line index, `j` the sample index and `k` the band number (1–204). All pixel coordinates in the paper and in `/data/rawData/regionsOfInterest` use this orientation. In the images of Figures 5 and 6, `i` is shown on the horizontal (x) axis and `j` on the vertical (y) axis.
* **Dark correction.** `I'(i, j, k) = I(i, j, k) − 239` (Eq. 3).
* **Wavelength correction.** `λcorrected = λfactory − 1.88 nm` (Eq. 4).
* **Spectral interpolation.** JETI spectra (1 nm steps) are resampled to the Specim IQ bands with a cubic spline; outside the measured range the closest measured value is used, and negative values are set to zero (`interpolateSpectrum.m`). This follows the luxpy toolbox that was used in the original analysis.
* **Colorimetry.** XYZ, u′v′ and CIELAB values use the CIE 1931 2° observer (`computeTristimulusValues.m`, `convertXyzToUvPrime.m`, `convertXyzToCielab.m`).

## Reproducibility Notes

This was a multi-year project. The measurements were carried out between 2021 and 2023, starting in the middle of the COVID-19 pandemic, and the analysis went through several rounds of revision by the two first authors, partly in MATLAB and partly in Python. For this repository, all analyses were consolidated into one MATLAB code base, recomputed from the raw data, and checked against the original analysis outputs and the published values:

* The calibration factors C(λ) and C′(λ) and the spatial CV agree with the original analysis output to 10 significant digits.
* Table 3 is reproduced exactly. Table 2 is reproduced within rounding.
* The maximum CV of 1.2 % for non-central pixels (Section 3.1) is reproduced with the eight non-central pixels of the original analysis: 1.23 % at pixel (251, 275) (`repeatabilityNonCentralPixels.csv`).
* The Lilliefors test (Section 3.1) gives 78 of 204 bands that are not normally distributed, as in the paper (requires the Statistics and Machine Learning Toolbox).
* The y-axis ranges of the ratio panels in Figure 15b are computed from the data with the rule of the original (matplotlib) figure: from 0 to the largest ratio over all 204 bands plus a 5 % margin. This reproduces the axis ranges of all 24 published panels. For the dark neutral patches 21–24 the largest ratio lies at the last band (1001.7 nm), outside the plotted 400–780 nm range, which is why these axes extend well above the plotted curves.

Because of the long time span and the several revisions, a few small discrepancies with the published article remain. They are listed below for transparency. None of them changes the conclusions of the paper. If you have questions about them, you are welcome to contact either of the first authors (see [Scope of this Repository](#scope-of-this-repository)).

* **Table 2, LMK columns.** The per-spot values agree with the paper. The averages in the paper (22.9 cd/m², 5.05 %, 0.00065) correspond to the mean of four spots, without the top-left spot. Over all five spots the averages are 22.1 cd/m², 4.88 % and 0.00063.
* **Table 2, ΔLv.** At the bottom-right spot the code gives 14.5 cd/m² (published: 14). The original JETI averages of the five measurements per spot were computed in a spreadsheet; here they are computed directly from the raw JETI export.
* **Section 3.2, ANOVA.** The mean intercept (240.2, CV 0.8 %) is reproduced. The sum-of-squares decomposition in the paper (220 = 5 + 184 + 31 for pixel position, wavelength and interaction) is not reproduced exactly: for the ten pixels (i, j) listed in the paper, the code gives 211 = 18 + 151 + 41. With the two coordinates of every pixel interchanged, i.e. (j, i), the decomposition is 217 = 5 + 186 + 26 (mean intercept 240.18, standard deviation 1.92), which is close to the published values; the published ANOVA was therefore most likely computed with interchanged coordinates. In both cases the pixel position contributes little and the wavelength contributes most, as stated in the paper.
* **Section 3.2, dark current.** The CV of all dark values is 0.216 % (0.21 % in the paper).
* **Section 3.3, spatial uniformity.** Figure 7 is reproduced; it shows the ratios of the dark corrected counts, i.e. of β1. The mean ratios range from 0.986 to 1.019, whereas the text of the paper gives 0.983 to 1.017. The origin of the published range could not be traced; the slightly different centre pixels of an earlier analysis script give 0.984 to 1.019.
* **Section 3.4, FWHM.** The code gives an average of 6.54 nm (minimum 5.40 nm, maximum 8.68 nm), against 6.55, 5.41 and 8.69 nm in the paper. The published values were determined manually.
* **Section 3.5, interpolation.** The paper states that the JETI data were linearly interpolated. The original analysis used a cubic spline (luxpy), which is kept here to reproduce the published values.
* **Figure 2.** The time axis starts at 0 min (the first of the 61 captures) and ends at 60 min; the published figure numbers the captures from 1 to 61. The curves are the same.
* **Figure 9b.** In the published figure the curves of the zoomed panel lie about 1.9 nm to the right, i.e. they were plotted against the factory wavelengths. Here both panels are plotted against the corrected wavelengths, as stated in the figure caption and as in panel (a) and in the original analysis script. The data are the same.
* **Figure 10.** Above 380 nm the curve agrees with the published figure. In the noisy region below 355 nm, the published curve has a slightly higher spike at 352 nm (about 0.19 instead of 0.17 W·m⁻²·sr⁻¹·nm⁻¹). This value is obtained when nine of the ten measurements are averaged (e.g. #20–#29 or #21–#29 instead of #21–#30); the published figure was made from a MATLAB copy of the JETI data that is not available. The calibration factor C(λ), which uses measurements #21–#30, is reproduced exactly, and above 380 nm the two selections differ by less than 0.5 %.

## How to Cite

If you use the code or data from this repository, please cite both the associated publication and this dataset.

**1. Citing the Paper:**
> Xiangzhen Kong, Ching-Wei Lin, & Peter Hanselaer. (2026). *Measuring Absolute Radiance by Calibrating a Hyperspectral Camera Economically*. Color Research & Application, 51(2). DOI: [10.1002/col.70043](https://doi.org/10.1002/col.70043).

**2. Citing the Software/Dataset:**
> Xiangzhen Kong, Ching-Wei Lin, & Peter Hanselaer. (2026). *Measuring Absolute Radiance by Calibrating a Hyperspectral Camera Economically: Code and Data* (Version 1.0.0) [Dataset and computer software]. Zenodo. [https://doi.org/10.5281/zenodo.13136174](https://doi.org/10.5281/zenodo.13136174).

**BibTeX Entry:**
```bibtex
@software{kong_2026_specimIqCalibration,
  author    = {Kong, Xiangzhen and Lin, Ching-Wei and Hanselaer, Peter},
  title     = {{Measuring Absolute Radiance by Calibrating a Hyperspectral Camera Economically: Code and Data}},
  year      = {2026},
  publisher = {Zenodo},
  version   = {1.0.0},
  doi       = {10.5281/zenodo.13136174},
  url       = {https://doi.org/10.5281/zenodo.13136174}
}
```

## Contributions

Xiangzhen Kong and Ching-Wei Lin contributed equally to this work and are co-first authors of the publication. Both designed and carried out the experiments and analysed the data. The original analysis consisted of MATLAB scripts (Sections 3.1–3.5), first written by Xiangzhen Kong and revised and extended by Ching-Wei Lin. It also included a Python pipeline by Ching-Wei Lin for the calibration factor and the validations (Sections 3.5 and 4), including the additional validation measurements of 2023. For this release, Xiangzhen Kong consolidated all analyses into a single MATLAB code base. Peter Hanselaer contributed to the conceptualization, the experiment design and the supervision.

## Statement on the Use of AI Tools

The core scientific algorithms and data analysis logic were designed and implemented by the authors. This repository was refactored and documented with the assistance of generative AI tools (primarily [Claude](https://www.anthropic.com/claude) by Anthropic) to improve readability and to follow the FAIR principles. These tools assisted with tasks such as:
* Translating the original Python analysis into MATLAB and checking that it reproduces the original outputs.
* Refactoring and cleaning code for improved readability.
* Generating boilerplate code, such as plotting templates and file I/O operations.
* Suggesting improvements for documentation and comments.

All AI-generated content was critically reviewed, tested and adapted by the authors to ensure that it correctly implements the intended logic and meets the scientific standards of the project.

## Scope of this Repository

This repository contains the data and code needed to reproduce the data figures and tables of the publication. For inquiries regarding other measurements of the project, please contact either of the first authors, Xiangzhen Kong (x.kong@tue.nl) or Ching-Wei Lin (jingwei.edu@gmail.com).

## License

This project consists of different components, which are covered by different licenses.

### Source Code (MIT License)
All source code in this repository (all `.m` files) is licensed under the **[MIT License](https://opensource.org/license/mit)**. Please see the `LICENSE` file for the full text.

### Data and Documentation (CC BY 4.0 License)
The text of this `README.md` file, all figures generated in the `/output` directory, and all raw and processed data (in `/data/rawData`, `/data/processedData` and the hyperspectral images on Zenodo) are licensed under the **[Creative Commons Attribution license (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/)**, in accordance with the open-access policy of the original publication.

### Third-Party Data
The CIE 1931 2° colour-matching functions in `/data/externalData` are published by the International Commission on Illumination (CIE): *CIE 1931 colour-matching functions, 2 degree observer*, DOI: [10.25039/CIE.DS.xvudnb9b](https://doi.org/10.25039/CIE.DS.xvudnb9b). They are included here for reproducibility, under the license of the CIE.
