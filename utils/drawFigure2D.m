function drawFigure2D(dataDir)

dofitVonMises = 0; % change this into 1 if you want to see fitted VonMises version of tuning; Note, this will take time depending on your computing power
data = tuningSummary(dataDir);

% chronic astigmatism group
[curTuning,amp,skew] = processTuning(data.chronic.astig,dofitVonMises);

x = -99:625;
y = linspace(-90,90,size(curTuning,2));

subplot(4,2,[1,3])
heatmap(curTuning,x,y)
ylabel(sprintf('Deviation \n from actual (%s)',char(176)))

subplot(4,2,5)
shadedplot_custom(skew,[],'xAxis',x)
ylabel(sprintf('Skewness (%s)','\gamma'))

subplot(4,2,7)
shadedplot_custom(amp,[],'xAxis',x)

xlabel('Time from stimulus onset (ms)')
ylabel('Accuracy (a.u.)')

% induced astigmatism group
[curTuning,amp,skew] = processTuning(data.induced.astig,dofitVonMises);

subplot(4,2,[2,4])
heatmap(curTuning,x,y)

subplot(4,2,6)
shadedplot_custom(skew,[],'xAxis',x)

subplot(4,2,8)
shadedplot_custom(amp,[],'xAxis',x)

xlabel('Time from stimulus onset (ms)')

end

