%%Written by Taylor Williams
%
% Code to generate the transmit waveform s(t) used in the acoustic ...imaging
% tests referenced in "SONAR Imaging using Compressive Sensing"
%
 %% Output Parameters
 % s: A digital waveform at a 96kHz sampling rate representing a ...waveform
% that is band?limited from 2.5kHz?30kHz and was formed from an
 % original PN sequence of length 2�16?1 as seen in ...MakePNWaveform.m
%%%%%%%%%%%%

function s = GenerateS ()

 %Motivation: We want to create a signal that is bandlimited to ...roughly
%[2.5kHz, 30kHz] since the chosen speakers have low gains below ...2.4kHz and
%the speakers start to alias above 31 kHz. To do this, we design...a PN
 %waveform using an upsampling factor of 1 and use a bandpass ...filter design

%generate ideal PN Code for transmission
fs = 8000; %sample rate
[s, seq, sequence, Ns] = makepnwaveform(1,8,0,fs);

L = 160;
fsa = 0.025;
fpa = 0.05; %0.05*nyquist = 2.4 kHz
fpb = 0.6; %0.6 *nyquist = 28.8 kHz
fsb = 0.65;
dels = 3e-5; %90dB stopband attentuation
delp = 0.8279; %10% passband variation allowed

%create LS FIR Bandpass Filter
F = [0,fsa,fpa,fpb,fsb,1];
A = [0,0,1,1,0,0];
W = [1/dels,1/delp,1/dels];

hbp = firls(L,F,A,W);


%create bandpass version of s and make sure that correlation is ...still
%sufficient. Since the original signal only has significant ...frequency
%content up to about 24 kHz, the filtering should not affect the ... signal
%very much.

s = real(ifft(fft(s).*fft(hbp,length(s))));


end