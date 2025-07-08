function drawFigure4B(dataDir)

data = glmWeightSummary(dataDir);
x = -99:625;

figure;
groupName = {'chronic','induced'};
for g = 1:2, % group loop : 1 = chronic astigmatism group / 2 = induced astigmatism group
    subplot(1,2,g)
    data2plot = data.(groupName{g}).gain;
    shadedplot_custom(data2plot,[],'xAxis',x,'gfilt',10)
    ylim([-0.01,0.04])
    xlim([-100,600])
    subtitle(groupName{g})
end


end