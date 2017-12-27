%Jason T. Parker

function showimages(result,bounds,spacing,f_hand,title_string,cscale)

if bounds(5) == bounds(6) %2-D image in X-Y plane
showduadimensi(result,bounds,f_hand, title_string,cscale,'X (m)','Y ...(m)');
elseif bounds(1) == bounds(2) %2?D image in Y-Z plane

%Fix the bounds
    bounds = bounds(1,3:end);
showduadimensi(squeeze(result).',bounds,f_hand,title_string,cscale,'Y...(m)','Z (m)');

elseif bounds(3) == bounds(4) %2-D image in X-Z plane

%Fix the bounds
bounds = [bounds(1,1:2) bounds(1,5:6)];
showduadimensi(squeeze(result).',bounds,f_hand,title_string,cscale,'X...(m)','Z (m)');

else

    figure(f_hand)
    clf

    %Generate the coordinate vectors
    x = bounds(1):spacing:bounds(2);
    y = bounds(3):spacing:bounds(4);
    z = bounds(5):spacing:bounds(6);

    % %Call plotting code option 1
    % contours = linspace(cscale(1),cscale(2),20);
    % ...plot3 patch(f hand,x,y,z,20*log10(abs(result/max(abs(result(:))))),contours,linsp

    %Plotting code, option 2
    isosurface(x,y,z,20*log10(abs(result)/max(abs(result(:)))),cscale(1));
    axis(bounds);
    title(title_string);
end