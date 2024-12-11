function drawFigure4B(dataDir)

data = connectivitySummary(dataDir);

p = load(fullfile(dataDir,'p.mat'));
heatmap(data.chronic,1:45,1:45,'alpha',p.p(:,:,1)<0.05)
caxis([-1,1]*20)
axis square
xlabel('Pre')
ylabel('Post')
text(44,44,'(100~300ms)','HorizontalAlignment','right')

end