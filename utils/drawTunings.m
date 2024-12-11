function [C] = drawTunings(resol,power)
% draws basis tuning functions
resol = resol*2;
peakPoint = 0:resol:(360-resol);
points = peakPoint; %-180:resol:(180-resol);
C = zeros(length(points));
for peak = peakPoint, % peak = 0;S
    C(:,points==peak) = (0.5+0.5.*cosd(points - peak)).^power;
end
%plot(C)
end