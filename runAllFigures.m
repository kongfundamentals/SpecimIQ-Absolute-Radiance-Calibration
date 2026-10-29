%% Main script to reproduce all figures and tables from the paper "Measuring Absolute Radiance by Calibrating a Hyperspectral Camera Economically"
% Journal
%   Color Research & Application
% DOI
%   10.1002/col.70043
%
% Description:
%   Generates Figures 2-11, 14 and 15 and Tables 1-3 from the processed
%   data in /data/processedData and the small raw data files (JETI and LMK
%   exports) in /data/rawData. All outputs are saved to /output.
%
%   Figures 1, 12 and 13 are not data figures (an illustration adapted from
%   the literature, a flowchart and a photograph of the setup) and are
%   therefore not generated here.
%
%   To regenerate the processed data from the raw hyperspectral images,
%   run runAllAnalyses first (see README.md). To check the results, run
%   verifyReproduction afterwards.
%
% Authors
%   Xiangzhen Kong (x.kong@tue.nl) and Ching-Wei Lin (jingwei.edu@gmail.com)
%

clear; close all; clc;

fprintf('Setting up paths...\n');
addpath(genpath(fullfile(fileparts(mfilename('fullpath')), 'src')));

fprintf('Generating Figure 2...\n');   plotFigure2;
fprintf('Generating Figure 3...\n');   plotFigure3;
fprintf('Generating Figure 4...\n');   plotFigure4;
fprintf('Generating Figure 5...\n');   plotFigure5;
fprintf('Generating Figure 6...\n');   plotFigure6;
fprintf('Generating Figure 7...\n');   plotFigure7;
fprintf('Generating Figure 8...\n');   plotFigure8;
fprintf('Generating Figure 9...\n');   plotFigure9;
fprintf('Generating Figure 10...\n');  plotFigure10;
fprintf('Generating Figure 11...\n');  plotFigure11;
fprintf('Generating Figure 14...\n');  plotFigure14;
fprintf('Generating Figure 15...\n');  plotFigure15;

fprintf('Generating Table 1...\n');    createTable1;
fprintf('Generating Table 2...\n');    createTable2;
fprintf('Generating Table 3...\n');    createTable3;

fprintf('\nAll figures and tables have been generated and saved in the /output folder.\n');
close all
