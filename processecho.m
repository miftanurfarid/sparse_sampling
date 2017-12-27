%%Written by Taylor Williams
%
% Process to take measured data for the background and the scene, match
% filter and perform background subtraction.
%
%%Input Parameters
% bdata -a NxM cell array where N is the number of transmitters ...and M is
% the number of receivers. background recording with no reflectors ...in the
% scene.
%
% sdata -an NxM cell array where N is the number of transmitters ...and M
% is the number of receivers. recording with reflectors in the scene.
%
% s -transmit waveform at 96kHz
%
% dmax -maximum range for echoes. Used to determine time gating. 
%
% ndelay - hardware delay in samples at 96kHz. Is applied to each ...data
% set % HARDWARE DELAY using TASCAM Box 412 SAMPLES (4,29 ms)
%
%%Output Parameters
%
% data - an NxM cell array where N is the number of transmitters ...and M is
% the number of receivers. Each signal in data is the result of
% subtracting the match filtered background from the match filtered
% scene and adjusting for all delays.

function data = processecho(bdata,sdata,s,dmax,ndelay)

    [nTx nRx] = size(bdata);

    for tx = 1:nTx
        for rx = 1:nRx
        %correlate background and scene data
        cback{tx,rx} = processData(bdata{tx,rx}',s,0,dmax/343);
        cdata{tx,rx} = processData(sdata{tx,rx}',s,0,dmax/343);
        %perform background subtraction
        data{tx,rx} = cdata{tx,rx}-cback{tx,rx};
        %account for hardware delays
        data{tx,rx} = data{tx,rx} (ndelay:length(data{tx,rx}));
        end
    end

end

%%cr = processData(r,s,Tstart,Tmax)
% takes a recorded waveform r and match filters against s, and ...applies a
% shift to guarantee that the peak from the correlation occurs at the
% beginning of the echo.
% Tstart is the experiment time delay between the start of ...recording and
% the start of transmission. Typically 0.
% Tmax is a time gating parameter. The resulting match filtered ...result
% will be truncated in time assuming a sampling rate of 96000 Hz.
function cr = processData(r,s,Tstart,Tmax)
    fs = 96000;
    c = 343;

    M = length(s);
    N = length(r);

    nstart = fix(Tstart*fs);
    nmax = fix(Tmax*fs);

    if (length(r) < length(s)) r = [r zeros(1,length(s)-length(r))]; end

    %correlate and shift so that the peak occurs at the first sample ...of the
    %original signal
    cr = real(ifft(fft(r,N+M-1).*fft(fliplr(s),N+M-1)));
    cr = cr(M:length(cr));

    %ignore the first Tstart seconds ? given delay from start of ...record to
    %time of transmit
    cr = cr((nstart+1):length(cr));

    %gate the signal in time ? limit to Tmax after the time when the ...signal
    %starts
    cr = cr(1:nmax);
end