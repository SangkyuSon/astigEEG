function drawFigure4C(dataDir)

bias = summarizeBias(dataDir);
biasHat = simulateBias(dataDir);
behComp = mean(cat(2,biasHat.chronic,biasHat.chronic(:,4:-1:2))-bias.chronic,2);

data = glmWeightSummary(dataDir);
x = -99:625;

figure;
subplot(1,3,1)
histogram(behComp,linspace(-5,10,11),'FaceColor',[0,0,0],'FaceAlpha',0.1)
xlabel(['Behavioral compensation (',char(176),')'])
xlim([-5,10])
ylim([0,8])

groupName = {'Low','High'};
for mg = 1:2,
    if mg == 1, subSel = behComp<=median(behComp); 
    else        subSel = behComp>median(behComp); end

    subplot(1,3,mg+1)
    data2plot = data.chronic.gain(subSel,:);
    shadedplot_custom(data2plot,[],'xAxis',x,'gfilt',10)
    subtitle(sprintf('%s\n(chronic)',groupName{mg}))
    ylim([-0.01,0.05])
    xlim([-100,600])
    ylabel('Gain (a.u.)')
end

end