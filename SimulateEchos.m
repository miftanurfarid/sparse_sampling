%%Written by Taylor Williams (Last Edited: 3/23/2011)
%
% Code to Simulate ideal data from a provided geometry of transmiters,
% receivers and reflectors.
%
%% Input Parameters
% All Distances in Meters
% reflectors: row vector where each entry is a complex number
% corresponding to the location of each point ...reflector

% in a 2D plane (0,0) is the center of the scene
% Tx: row vector where each entry is a complex number ...corresponding to
% the location of each transmitter on a 2D plane
% Rx: row vector where each entry is a complex number ...corresponding to
% the location of each receiver on a 2D plane
%
% s: transmit waveform to be convolved to generate r
%
% fs: sampling frequency (Hz)
%
%% Output Parameters
% data: cell array where datafx,yg is the signal received by the yth
% receiver from the xth transmitter. Ideal impulse response ...assumed for
% every point reflector
%
% cdata: cell array where cdatafx,yg is the signal datafx,yg ...correlated
% against s and shifted so that the peak of the correlation is ...at the
% same location as the original impulse in datafx,yg
%%%%%%%%%%%%

function [data, cdata]=SimulateEchos(Rfs, Tx, Rx, s, fs)
    c = 343; %speed of sound, assumed constant
    nTx = length(Tx); nRx = length(Rx); nRfs = length(Rfs);

%calculate the distance between each reflector and Receiver, each
%reflector and transmitter respectively
    for r = 1:length(Rfs)
        dTxR(r,:) = abs(Tx-Rfs(r));
        dRxR(r,:) = abs(Rx-Rfs(r));
    end

    N=nTx*nRx;
%Start by creating dataftx,rxg which contains an ideal impulse ...response
%at the location of each reflector. Data is positioned so that t=0
%corresponds to the speaker location.

fprintf('Simulating Data...',N);
for tx = 1:nTx
    fprintf('.');
    for rx = 1:nRx
        %calculate the path lengths for all reflectors
        d = (dTxR(:,tx)+dRxR(:,rx))';
        %caclulate the appropriate index corresponding to those ...lengths
        n = fix(d./c.*fs);
        %intitialize the output data array to all zeros
        data{tx,rx} = zeros(1,max(n));
        %add 1 for every reflector position
        for rfs = 1:nRfs
            data{tx,rx}(n(rfs)) = data{tx,rx}(n(rfs)) + 1;
        end
     end
 end
fprintf(' Complete.\n');

%%Next, pulse shape with the provided waveform correlated against ...itself
%Adjust the result so that the peak of the correlation function is ...at the
%same place as the ideal response
    fprintf('Correlating Data...');

    %generate pulse shape (s(t)*s(?t)) using ffts
    d = real(fftshift(ifft(fft(s).*fft(fliplr(s)))));

%shape each dataftx,rxg to make the cdataftx,rxg vector
for tx = 1:nTx
    fprintf('.');
    for rx = 1:nRx
        %first, extend data by length(d)/2 so that we can do
        %convolution using ffts and not have any difference in
        %result
        zpaddata = [data{tx,rx} zeros(1,length(d)/2)];
        %pulse shape with d
        cd = real(ifft(fft(zpaddata,length(d)).*fft(d)));
        %Shift signal so that peaks line up with ideal response
        cdata{tx,rx} = cd(length(cd)/2:length(cd));
        %truncate arbitrarily to twice the original length
        cdata{tx,rx} = cdata{tx,rx}(1:(2*length(data{tx,rx})));
        end
    end
    fprintf(' Complete.\n');
end
