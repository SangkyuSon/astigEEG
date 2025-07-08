function drawFigureS4(dataDir)

dofitVonMises = 0; % change this into 1 if you want to see fitted VonMises version of tuning; Note, this will take time depending on your computing power
data = tuningSummary(dataDir);

x = -99:625;
groupName = {'chronic','induced'};
nrow = 3;

figure
for g = 1:2,
    [curTuning,amp,skew] = processTuning(data.(groupName{g}).emme,dofitVonMises);
    y = linspace(-90,90,size(curTuning,2));
    
    subplot(nrow,2,g)
    heatmap(curTuning,x,y)
    ylabel(sprintf('Deviation \n from actual (%s)',char(176)))
    subtitle(groupName{g})
    
    subplot(nrow,2,g+2)
    shadedplot_custom(skew,[],'xAxis',x)
    ylabel(sprintf('Skewness (%s)','\gamma'))
    
    subplot(nrow,2,g+4)
    shadedplot_custom(amp,[],'xAxis',x)
    
    xlabel('Time from stimulus onset (ms)')
    ylabel('Accuracy (a.u.)')

end

end