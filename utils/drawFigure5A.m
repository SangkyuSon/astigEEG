function drawFigure5A(dataDir)

data = glmWeightSummaryAllChan(dataDir);

figure
tn = size(data.chronic,3);
groupName = {'chronic','induced'};
for g = 1:2,
    
    gdata = data.(groupName{g});
    
    for t = 1:tn,
        subplot(2,tn,t+(g-1)*tn);
        topoplot64(mean(gdata(:,:,t),1));
        colormap('jet')
        caxis([-1,1]*0.05)        
        
        axis on
        set(gca,'xtick',[])
        set(gca,'ytick',[])
        set(gca,'Color','None')
        set(gca,'XColor','None')
        set(gca,'YColor','None')
        if g == 2, 
            text(mean(xlim), min(ylim) - 0.1, sprintf('(%d~%d)', (t-1)*30+80, t*30+80), ...
                'HorizontalAlignment', 'center', 'Color', 'k', 'FontSize', 12);
        end
        if t == 1, 
            text(min(xlim) - 0.2, mean(ylim), groupName{g}, ...
                'Rotation', 90, 'HorizontalAlignment', 'center', 'Color', 'k', 'FontSize', 12);
        end
        
        if t == 4 & g == 2,
            text(mean(xlim), min(ylim) - 0.1, 'Time from stimulus onset (ms)', ...
                'HorizontalAlignment', 'center', 'Color', 'k', 'FontSize', 12);
        end
        
    end
end

end