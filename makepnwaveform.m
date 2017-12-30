%%Adapted by Taylor Williams using code from Arthur C. Ludwig
 % ...
%(http://www.silcom.com/�aludwig/Signal processing/Maximum length sequence
% s.htm)
%
%%Input Parameters:
% T: total time for the entire symbol sequence to occur
% N: Symbol sequence will be of length 2^(N)-1. Must be in the range
% [3, 18].
% alpha: SRRC pulse shaping parameter. See SRRC.m
% fs: sampling rate of signal
%
%%Output Parameters:
% s: final waveform at fs sampling rate. Padded with zeros so that...the
% signal has a length of a power of two for FFT speed-up.
%
% seq: upsampled version of the PN code by U. Can be used to plot...s vs.
% seq and see exactly where the symbols match up.
%
% sequence: Maximum Length Sequence (no sampling rate). Just a ...series
% of symbols in f?1,1g.
%
% Ns: Upsampling factor in order to meet the required time. Integer
% value >= 1.

function [s, seq, sequence, Ns] = makepnwaveform(T, N, alpha, fs)
    len = T*fs;


%%generate Maximum Length Sequence of length 255 (2�8?1)
%code section from
%http://www.silcom.com/�aludwig/Signal processing/Maximum length sequences.htm

%Copyright, Arthur C. Ludwig, 2001.
    if N == 18; taps=[0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 1]; end
    if N == 17; taps=[0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 1]; end
    if N == 16; taps=[0 0 0 1 0 0 0 0 0 0 0 0 1 0 1 1]; end
    if N == 15; taps=[0 0 0 0 0 0 0 0 0 0 0 0 0 1 1]; end
    if N == 14; taps=[0 0 0 1 0 0 0 1 0 0 0 0 1 1]; end
    if N == 13; taps=[0 0 0 0 0 0 0 0 1 1 0 1 1]; end
    if N == 12; taps=[0 0 0 0 0 1 0 1 0 0 1 1]; end
    if N == 11; taps=[0 0 0 0 0 0 0 0 1 0 1]; end
    if N == 10; taps=[0 0 0 0 0 0 1 0 0 1]; end
    if N == 9; taps=[0 0 0 0 1 0 0 0 1]; end
    if N == 8; taps=[0 0 0 1 1 1 0 1]; end
    if N == 7; taps=[0 0 0 1 0 0 1]; end
    if N == 6; taps=[0 0 0 0 1 1]; end
    if N == 5; taps=[0 0 1 0 1]; end
    if N == 4; taps=[0 0 1 1]; end
    if N == 3; taps=[0 1 1]; end


    M = 2^N-1;
    m = ones(1,N);
    regout = zeros(1,M);
    for ind = 1:M
        buf = mod(sum(taps.*m),2);
        m(2:N) = m(1:N-1);
        m(1)=buf;
        regout(ind) = m(N);
    end
    comp = ~ regout;
    sequence = regout-comp;
    
%%Create SRRC pulse for shaping
U = fix(len/(2^N-1)); %upsample factor
Ns = U;
g = SRRC(4,alpha,U);
g = g./max(g); %normalize to 1

x = upsample(sequence,U);
seq = [zeros(1,4*U) x];


%% shape pulse and create s(t) that is length of power of 2
s = conv(x,g);

s = [s zeros(1,2^(ceil(log2(len)))-length(s))];
end
