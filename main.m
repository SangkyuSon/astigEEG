%% Information
% title              : Dynamic Neural Compensation for Distorted Orientation Perception in Chronic Astigmatism
% authors            : Sangkyu Son , Hyungoo Kang, HyungGoo R. Kim, Won Mok Shim, and Joonyeol Lee
% inquiry about code : Sangkyu Son (ss.sangkyu.son@gmail.com)


%% set up
clear all; close all; clc; warning off;
genDir = pwd;                            % Note, change this line into the proper working directory
utilDir = fullfile(genDir,'/utils');
dataDir = fullfile(genDir,'/data');
addpath(genpath(utilDir))

%% Main figures
drawFigure2C(dataDir);

drawFigure3C(dataDir);
drawFigure3D(dataDir);

drawFigure4B(dataDir);
drawFigure4C(dataDir);

drawFigure5A(dataDir);
drawFigure5B(dataDir);
drawFigure5C(dataDir);

drawFigure6A(dataDir);
drawFigure6B(dataDir);

%% Supplementary figures
drawFigureS3(dataDir);
drawFigureS4(dataDir);
drawFigureS5(dataDir);
drawFigureS6(dataDir);
drawFigureS7(dataDir);
drawFigureS8(dataDir);
drawFigureS9(dataDir);