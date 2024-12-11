function drawFigure2C(dataDir)

dofitVonMises = 1; % change this into 1 if you want to see fitted VonMises version of tuning; Note, this will take time depending on your computing power
timeOfInterest = (250:350)+100;
data = tuningSummary(dataDir);

figure
groupName = {'chronic','induced'};
conditionName = {'astig','emme'};
for g = 1:2, % group loop : 1 = chronic astigmatism group / 2 = induced astigmatism group
    for c = 1:2, % vision condition loop : 1 = astigmatic vision condition / 2 = emme. vision condition
        if c == 1, col = [1,0,0]; else col = [0,0,0]; end
        data2plot = data.(groupName{g}).(conditionName{c});
        
        [curTuning] = processTuning(data2plot,0);
        avgTuning = mean(curTuning(:,:,timeOfInterest),3);
        x = linspace(-90,90,size(avgTuning,2));

        if dofitVonMises,
            for m = 1:size(avgTuning,1),
                fittedOutput = fitVonMises((-180:45:180),avgTuning(m,:));
                fittedTune(m,:) = fittedOutput.estimates.tuningCurve';
            end
            avgTuning = fittedTune;
            x = fittedOutput.estimates.directions/2;
        end

        subplot(1,2,g)
        shadedplot_custom(avgTuning,[],'xAxis',x,'Color',col)
        xlabel(sprintf('Deviation\nfrom actual (%s)',char(176)))
        ylabel(sprintf('Amplitude (a.u.)'))
        subtitle(groupName{g})
        ylim([-1,1]*5)
    end
end

end