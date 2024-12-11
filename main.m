%% Information
% title              : Neural Gain Modulation Propagates from Posterior to Anterior Brain Regions 
%                      to Optimize Orientation Perception in Chronic Astigmatism
% authors            : Sangkyu Son , Hyungoo Kang, HyungGoo R. Kim, Won Mok Shim, and Joonyeol Lee
% inquiry about code : Sangkyu Son (ss.sangkyu.son@gmail.com)

%% set up
clear all; close all; clc; warning off;
genDir = pwd;                            % Note, change this line into proper working directory
utilDir = fullfile(genDir,'/utils');
dataDir = fullfile(genDir,'/data');
addpath(genpath(utilDir))

%% Main figures
drawFigure1C(dataDir);

drawFigure2C(dataDir);
drawFigure2D(dataDir);

drawFigure3B(dataDir);
drawFigure3C(dataDir);

drawFigure4A(dataDir);
drawFigure4B(dataDir);
drawFigure4C(dataDir);

drawFigure5A(dataDir);
drawFigure5B(dataDir);

%% Extended data figures
drawFigure2_1(dataDir);
drawFigure2_2(dataDir);

drawFigure3_1(dataDir);
drawFigure3_2(dataDir);

drawFigure4_1(dataDir);

drawFigure5_1(dataDir);