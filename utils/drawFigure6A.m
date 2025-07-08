function drawFigure6A(dataDir)

data = glmWeightSummaryMedianSplit(dataDir);
x = -99:625;

figure;
groupName = {'1st','2nd'};
for q = 1:2, 
    subplot(2,1,q)
    data2plot = data.induced.gain(:,:,q);
    shadedplot_custom(data2plot,[],'xAxis',x,'gfilt',10)
    ylim([-0.01,0.04])
    xlim([-100,600])
    subtitle(sprintf('Induced (%s)',groupName{q}))
    xlabel('Time from stimulus onset (ms)')
end


end