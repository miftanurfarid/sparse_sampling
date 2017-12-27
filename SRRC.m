%Written by Phil Schniter
%
% SRRC Creat an oversampled square?root raised cosine pulse
% SRRC(N, alf, P) creates an oversampled SRRC pulse, where
% N is one half the length of srrc pulse in symbol durations,
% alf is the rolloff factor (between 0 and 1; alf=0 gives a sinc ...pulse),
% P is the oversampling factor (a positive integer).
% SRRC(N, alf, P, t off) works the same way, but offsets the pulse
% center by t off fractional samples.

function g = SRRC(N, alf, P, t_off)

if nargin==3, t_off=0; end % if unspecified, offset is 0
k = -N*P+1e-8+t_off:N*P+1-8+t_off; % sampling indices as multiples ...of T/P
if alf==0, alf=1e-8; end % numerical problems if alf=0
g = ...
4*alf/sqrt(P)*(cos((1+alf)*pi*k/P)+sin((1-alf)*pi*k/P)./(4*alf*k/P))./...
(pi*(1-16*(alf*k/P).^2));