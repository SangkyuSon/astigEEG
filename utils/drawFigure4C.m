function drawFigure4C(dataDir)

data = connectivitySummary(dataDir);

bias = summarizeBias(dataDir);
biasHat = simulateBias(dataDir);
behComp = mean(cat(2,biasHat.chronic,biasHat.chronic(:,4:-1:2))-bias.chronic,2);

p = load(fullfile(dataDir,'p.mat'));

groupName = {'Low behavioral\ncompensation','High behavioral\ncompensation'};
for mg = 1:2,
    if mg == 1, subSel = behComp<=median(behComp); 
    else        subSel = behComp>median(behComp); end

    subplot(1,2,mg)
    data2plot = data.chronic(subSel,:,:);
    heatmap(data2plot,1:45,1:45,'alpha',p.p(:,:,1)<0.05)
    caxis([-1,1]*20)
    axis square
    xlabel('Pre')
    ylabel('Post')
    subtitle(sprintf(groupName{mg}))
end

end