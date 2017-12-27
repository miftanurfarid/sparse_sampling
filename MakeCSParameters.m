%%Written by Taylor Williams
%
%A function that constructs an A matrix and a y vector from two separate
%data sets. Input parameters specify exactly how to do this.

%%Input Parameters
%   Let T = number of transmitters in full data set
%       R = number of receivers in full data set
%
%   adata: a TxR cell array containing range profiles from a centered point
%          reflector. Data used to construct the a matrix
%
%   ydata: a TxR cell array containing range profiles from the unknown
%          scene. used to construct the y measurement vector.
%
%   dataparams.G - number of data sets to use (must be <= T*R)
%   dataparams.g - a 2xG matrix where g(:,i) contains [tx rx]' where
%                  tx is the transmitter number (from 1 to T) and
%                  rx is the receiver number (from 1 to R).
%                  This matrix describes exactly what data to use.
%   dataparams.gpos - a 2xG matrix where gpos(:,i) contains [ptx prx]'
%                     where ptx and prx are complex numbers with the
%                     location of the transmitter or receiver in the
%                     2D plane (x+iy) in meters.
%   dataparams.nmax - maximum cutoff length for range profiles. (600 used
%                     throughout thesis research.)
%   dataparams.TM - a transformation matrix used to make the effective
%                   measurement. Must be nmax by nmax.
%                   (randn(600,600) used throughout research)
%   dataparams.keepsamples - a 1xG cell array where each entry is a row
%                            vector of the same length (<nmax) listing
%                            the integer valued entries of each effective
%                            measurement to keep. (for research, these were
%                            pre-determined randomly as 150 samples out of
%                            the 600 for each geometry)
%                            All cell elements must be vectors of
%                            the same ...length!!
%
% imageparameters.L - length in meters of the unknown scene.
%                     Assumed to be square (LxL meters)
% imageparameters.N - number of pixels along one edge of the unknown
%                     scene. Final modeled image is NxN pixels square.
%
%%Output Parameters
% A - MxN matrix. M = (number of geometries)(length of effective measurement)
%     and N = (imageparameters.N)^2
%     Each column of A is the stacked ideal measurement of all G
%     geometries based on the adata provided. See below for more
%     algorithmic details.
%
% y - an Mx1 vector representing the effective measurement of the imaged
%     scene
%

function [A, y] = MakeCSParameters(adata, ydata, dataparams)
fs = 96000;
c = 343;

L = imageparams.L; %square image dimension (meters) centered at (0,0)
N = imageparams.N; %square image pixels (NxN image)

G = dataparams.G;
gpos = dataparams.gpos;
nmax = dataparams.nmax;

keepsamples = dataparams.keepsamples;
T = dataparams.TM;

%length of each effective measurement
nEff = length(dataparams.keepsamples{1});

%make cell vector for just the used data (maps from {tx,rx} to {g})
for k = 1:dataparams.G
    Adata{k} = adata.data{dataparams.g(k,1),dataparams.g(k,2)};
    if (length(Adata{k}) < dataparams.nmax)
        Adata{k} = [Adata{k} zeros(1,length(dataparams.nmax-Adata{k}))];
    end
    Ydata{k} = ydata.data{dataparams.g(k,1),dataparams.g(k,2)};
    if (length(Ydata{k}) < dataparams.nmax)
        Ydata{k} = [Ydata{k} zeros(1,length(dataparams.nmax-Ydata{k}))];
    end
end

%%Form the A matrix
%%caculate the offset required for each component of the A matrix
%create a 2D matrix with the positions in meters of each pixel
pixpos = (linspace(-L/2,L/2,N)'*ones(1,N))' + ...
    linspace(-L/2*i,L/2*i,N)'*ones(1,N);

centerDistance = abs(gpos(:,1)) + abs(gpos(:,2));
for g = 1:G
    xydelay{g} = fs/c*((abs(gpos(g,1)-pixpos)+abs(pixpos-gpos(g,2)))-centerDistance(g)
    pixvec = xydelayfgg(:,1);
    for n = 2:N
        pixvec = [pixvec; xydelay{g}(:,n)];
    end
    delay{g} = pixvec;
end

%%Apply Time shift in frequency domain and construct matrix using
%%sample points

A = zeros(G*nEff,N^2);

for g = 1:G
    FreqData{g} = fft(Adata{g}(1:nmax),nmax);
end

indexes = (nEff*(0:G))+1;

df = 1/(nmax*1/fs);
f = df*(1:nmax);

for pixel=1:N^2
    if (mod(pixel,fix(N^2/100))==0)
        fprintf('%d ',pixel);
    end
    for g = 1:G
        tau = round(delay{g}(pixel))/fs;
        e = exp(j*2*pi.*f*-tau);
        %apply shift in time in freq domain
        FreqD = e.*FreqData{g};
        %sample based on input parameters from user
        datapoints = T*real(ifft(FreqD))';
        datapoints = datapoints(round(keepsamples{g}));
        %normalize measurement
        datapoints = datapoints./max(datapoints);
        %place into the empty A matrix
        A(indexes(g):(indexes(g+1)-1),pixel) = datapoints;
    end
end

%% create y vector of measurements
indexes = (nEff*(0:dataparams.G))+1;
for g=1:dataparams.G
    datapoints = (dataparams.TM*Ydata{g}(1:dataparams.nmax)');
    datapoints = datapoints(round(dataparams.keepsamples{g}));
    datapoints = datapoints./max(datapoints);
    y(indexes(g):(indexes(g+1)-1),1) = datapoints;
end

end