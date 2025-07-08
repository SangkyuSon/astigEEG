function drawFigureS7(dataDir)

load(fullfile(dataDir,'Fig4_1.mat'))

figure;

subplot(2,3,1)
heatmap(data.chronicRaw,1:45,1:45)
caxis([3.2,5.2]*1e-2)
setFig

subplot(2,3,2)
heatmap(data.inducedRaw,1:45,1:45)
caxis([3.2,5.2]*1e-2)
setFig

subplot(2,3,3)
heatmap(data.chronicHalfComparison,1:45,1:45)
caxis([-1,1]*20)
setFig

subplot(2,3,4)
heatmap(data.induced1stRaw,1:45,1:45)
caxis([3.2,5.2]*1e-2)
setFig

subplot(2,3,5)
heatmap(data.induced2ndRaw,1:45,1:45)
caxis([3.2,5.2]*1e-2)
setFig

end

function setFig

axis square
xlabel('Pre')
ylabel('Post')
text(44,44,'(100~300ms)','HorizontalAlignment','right')

end