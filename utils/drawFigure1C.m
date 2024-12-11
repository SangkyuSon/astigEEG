function drawFigure1C(dataDir)

x = -90:22.5:0;

bias = summarizeBias(dataDir);

bias.chronic = decal(bias.chronic',5)';
bias.induced = decal(bias.induced',5)';

shadedplot_custom(bias.chronic,[],'Color',[1,0,0],'xAxis',x)
shadedplot_custom(bias.induced,[],'Color',[0,0,0],'xAxis',x)

biasHat = simulateBias(dataDir);
plot(x,mean(biasHat.chronic,1),'Color',[1,0,0],'LineStyle','--')
plot(x,biasHat.induced,'Color',[0,0,0],'LineStyle','--')

xlabel(['Deviation from astigmatic axis (',char(176),')'])
ylabel(['Bias (',char(176),')'])

end

