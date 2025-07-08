function drawFigureS6(dataDir)

bias = summarizeBias(dataDir);
biasHat = simulateBias(dataDir);
behComp = mean(repmat([biasHat.induced,biasHat.induced(4:-1:2)],size(bias.induced,1),1)-bias.induced,2);

data = glmWeightSummary(dataDir);
x = -99:625;

figure;
subplot(1,2,1)
histogram(behComp,linspace(-5,5,11),'FaceColor',[0,0,0],'FaceAlpha',0.1)
xlabel(['Behavioral compensation (',char(176),')'])
xlim([-5,5])
ylim([0,8])

groupName = {'Low','High'};
for mg = 1:2,
    if mg == 1, subSel = behComp<=median(behComp); col = [1,1,0]*0.8;
    else        subSel = behComp>median(behComp); col = [1,0,0];end

    subplot(1,2,2)
    data2plot = data.induced.gain(subSel,:);
    shadedplot_custom(data2plot,[],'xAxis',x,'gfilt',10,'Color',col)
    ylim([-0.01,0.05])
    xlim([-100,600])
    ylabel('Gain (a.u.)')
    xlabel('Time from stimulus onset (ms)')
end

end