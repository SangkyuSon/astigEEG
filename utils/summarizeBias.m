function bias = summarizeBias(dataDir)

load(fullfile(dataDir,'behavior.mat'))

subjType = {'chronic','induced'};
for st = 1:length(subjType),
    err = eval(sprintf('data.%s.error',subjType{st}));
    idx = eval(sprintf('data.%s.axisIdx',subjType{st}));

    clear avgBias
    for m = 1:length(err),
        for o = 1:8,
            avgBias(m,o) = circ_mean_ori(err{m}(idx{m}==o)); % you need circ_mean toolbox for this
        end
    end

    avgBias(:,1:5) = -avgBias(:,1:5);
    bias.(subjType{st}) = avgBias;
end


end

