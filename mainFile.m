clear all; close all; clc;

addpath(genpath(pwd));

s = GenerateS; % generate waveform s
positions; % generate position of transmitter, receiver and reflector

[data, cdata] = SimulateEchos(Rfs1, Tx1, Rx1, s, fs);

% image parameters (the width of the scene in meters and pixels)
imageparams.L = 0.7; % 0.7m x 0.7m
imageparams.N = 100; % 199px x 199px

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


%% SPARSE-SAMPLING
dataparams.G = length(Tx1)*length(Rx1); % number of data sets to use (must be <= T*R)

counter = 1;
for idx = 1:length(Tx1)
    for idy = 1:length(Rx1)
        dataparams.g(counter,:) = [idx idy];
        counter = counter + 1;
    end
end

counter = 1;
for idx = 1:length(Tx1)
    for idy = 1:length(Rx1)
        dataparams.gpos(counter,:) = [Tx1(idx) Rx1(idy)];
        counter = counter + 1;
    end
end

dataparams.nmax = 300;
dataparams.TM = randn(300,300);

[adata.data acdata.data] = SimulateEchos(Rfs2, Tx2, Rx2, s, fs);
[ydata.data ycdata.data] = SimulateEchos(Rfs1, Tx1, Rx1, s, fs);

counter = 1;
for idx = 1:length(Tx1)
    for idy = 1:length(Rx1)
        dataparams.keepsamples{counter} = FormEffectiveMeasurement2(ycdata.data{idx,idy}, 150);
        dataparams.keepsamples{counter} = FormEffectiveMeasurement2(acdata.data{idx,idy}, 150);
        counter = counter + 1;
    end
end

[A, y] = MakeCSParameters(acdata, ycdata, dataparams, imageparams);
opts = spgSetParms('optTol',1e-4);                                         
[x,r,g,info] = spgl1(A, y, 0, 1e-3, [], opts); % sigma = 1000;
bounds = [-0.35,0.35,-0.35,0.35,-0.35,0.35]; % [minX,maxX,minY,maxY,minZ,maxZ]
title_string = 'Hasil Sparse-sampling';
cscale = [-10 1]; % min -10 dB max 1 dB
x_string = 'X (m)';
y_string = 'Y (m)';
f_hand = 2; % number figure
image2 = FormatCSImage(x,sqrt(length(x)));
% result backprojection
figure(2);
Show2DImage(image2,bounds,f_hand,title_string,cscale,x_string,y_string);