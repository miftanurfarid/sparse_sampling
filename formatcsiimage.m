%%Written by Taylor Williams
%
%simple method to take a vectorized image x (containing N columns of N
%pixels stacked consecutively) back into an NxN image

function image = formatcsiimage(x,N)
    indices = ((0:N)*N)+1;
    for col = 1:N
        image(1:N,col) = flipud(x(indices(col):(indices(col+1)-1)));
    end
end