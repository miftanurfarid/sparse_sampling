clear all; close all; clc;

addpath(genpath(pwd));

s = GenerateS; % generate waveform s
positions; % generate position of transmitter, receiver and reflector

[data, cdata] = SimulateEchos(Rfs1, Tx1, Rx1, s, fs);

% image parameters (the width of the scene in meters and pixels)
imageparams.L = 0.7; % 0.7m x 0.7m
imageparams.N = 199; % 199px x 199px

% backprojection
[pixelgrid, image] = Backproject(cdata, Tx1, Rx1, imageparams.L, imageparams.N);

% image parameters
bounds = [-0.35,0.35,-0.35,0.35,-0.35,0.35]; % [minX,maxX,minY,maxY,minZ,maxZ]
title_string = 'Hasil Backprojection';
cscale = [-10 1]; % min -10 dB max 1 dB
x_string = 'X (m)';
y_string = 'Y (m)';
f_hand = 1; % number figure

% result backprojection
Show2DImage(image,bounds,f_hand,title_string,cscale,x_string,y_string);

dataparams.G = length(Tx1)*length(Rx1); % number of data sets to use (must be <= T*R)

counter = 1;
for idx = 1:length(Tx1)
    for idy = 1:length(Rx1)
        dataparams.g(:,counter) = [idx idy]';
        counter = counter + 1;
    end
end

counter = 1;
for idx = 1:length(Tx1)
    for idy = 1:length(Rx1)
        dataparams.gpos(:,counter) = [Tx1(idx) Rx1(idy)];
        counter = counter + 1;
    end
end

dataparams.nmax = 600;
dataparams.TM = randn(600,600);
% dataparams.keepsamples = 150*ones(1,dataparams.G);

[adata.data acdata.data] = SimulateEchos(Rfs2, Tx2, Rx2, s, fs);
[ydata.data ycdata.data] = SimulateEchos(Rfs1, Tx1, Rx1, s, fs);

for idx = 1:length(Tx1)
    for idy = 1:length(Rx1)
        y = FormEffectiveMeasurement(acdata.data{idx,idy}, dataparams.TM, keepsamples);
    end
end

% [A, y] = MakeCSParameters(acdata, ycdata, dataparams, imageparams);
% image = FormatCSImage(x,N);