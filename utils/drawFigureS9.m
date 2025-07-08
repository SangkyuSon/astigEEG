function drawFigureS9(dataDir)

figure;
cdata = load(fullfile(dataDir,'std.mat'));

subplot(1,2,1)
shadedplot_custom(cdata.data.chronic,[],'xAxis',-90:22.5:90)
title('Chronic')
ylim([4,8])
ylabel('SD of electrode (\muV)')
xlabel('Deviation from astigmatic axis (deg)')

subplot(1,2,2)
shadedplot_custom(cdata.data.induced,[],'xAxis',-90:22.5:90)
title('Induced')
xlabel('Deviation from astigmatic axis (deg)')
ylim([4,8])

end