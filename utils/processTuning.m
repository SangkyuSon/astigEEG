function [data,amp,skew] = processTuning(tuningData,dofitVonMises)
if nargin < 2, dofitVonMises = 0; end

obliqueOrientationIdx = [2,3,4,6,7,8];
data = mean(tuningData(:,:,:,obliqueOrientationIdx),4);
data = -bsxfun(@minus,data,mean(data,2));
data = gfilt3(data,15)*1e3;

amp = cosamp(data);
for m = 1:size(data,1),
    for t = 1:size(data,3), 
        skew(m,t) = skewnessPDF(cat(2,zeros(1,3),data(m,:,t),data(m,1,t),zeros(1,3))); 
    end
end

if dofitVonMises,
    mdata = squeeze(mean(data));
    ftune = zeros(40,size(mdata,2));
    for t = 1:size(mdata,2),
        out = fitVonMises((-180:45:135),mdata(:,t)');
        ftune(:,t) = out.estimates.tuningCurve';
    end
    data = ftune;
else
    data = cat(2,data,data(:,1,:));
end

end