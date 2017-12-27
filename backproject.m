%%Written by Taylor Williams 3/23/2011
%
% Code that takes correlated time?domain recordings and produces an ...image
% through backprojection
%
% Input Parameters:
% cdata: cell structure where cdataftx,rxg is the recording from the
% specified Tx and Rx. t=0 when the sound leaves the speaker.
%
% Tx/Rx: vector telling the positions of each transmitter and ...receiver
% in the x-y plane using complex numbers (x+iy) in meters
%
% L: Width of the scene to image. Produced image will span from
% [-L/2, L/2] in both x and y directions
%
% N: Width in pixels of image to produce. Function produces an NxN
% image.
%
%
% Output Parameters:
% pixelgrid: NxN matrix where each entry is the location in the x?y
% plane of the center of that pixel.
% image: NxN matrix with the result of the backprojection in the ...scene.
% magnitudes normalized to be from 0 to 1.

function [pixelgrid image] = backproject(cdata, Tx, Rx, L, N)
%Static Variables ? speed of sound and sampling rate
c = 343;
fs = 96000;

nTx = length(Tx); nRx = length(Rx);

%Resample provided data vectors so that there is one point per pixel
% either interpolating or decimating by a rational factor

R = (c/fs)/(L/N); %resampling factor (provided delta x / image ...delta x)

%use interp1 to create a new interpolated data vector to fit N ...pixels
% This is alot faster to do ahead of time all in one swoop

fprintf('Resampling Data . . .');


for tx = 1:nTx
    for rx = 1:nRx
        len = length(cdata{tx,rxg});
        cdata{tx,rx} = ...
            interpl(1:len,cdata{tx,rx},linspace(1,len,fix(len*R)));
      end
end
fprintf(' Complete.\n');

%make sure N is odd (number of pixels in final image)
%guarantees a (0,0) pixel
if (mod(N,2)==0) N = N-1; end

%create 2D NxN vector that contains the positions of the center ...of each
%pixel (using complex numbers for x,y coordinates)
pixpos = ...
    (linspace(-L/2,L/2,N)'*ones(1,N))'+linspace(-L/2*i,L/2*i,N)'*ones(1,N);

%initialize image to zeros
image = zeros(N,N);

%Looping through each pixel in the final image
fprintf('Constructing Image: ');
tic;
mark = 0;
for x=1:N
    %display status
    t=toc;
    if (floor(t)>mark) fprintf('%d%%, ',ceil(x/N*100)); mark = ...
        mark + 1; end
    for y=1:N
        %examining the contribution from each geometry
        for tx=1:nTx
            for rx=1:nRx
                %calculate the path distance from the chosen ...Tx/Rx to
                %the pixel being examined
                d = abs(Tx(tx)-pixpos(x,y))+abs(Rx(rx)-pixpos(x,y));
                n = fix(R*d/c*fs);
                %determine the index for the ...distance using the resampling factor
                %add to the pixel the value from the range profile
                if (n <= length(cdataftx,rxg)) image(x,y) =...
                    image(x,y) + cdataftx,rxg(n); end
            end
        end
    end
end
fprintf(' Completed.\n');

%normalize image
image = image./max(max(image));

pixelgrid = pixpos;

end