function pts = sigLine(p,varargin)
% draw significnat line
% sigLine(p,varargin)
% varargin
%     'position',       0,                  ...   
%     'Color',          [0,0,0],            ...
%     'LineWidth',      2,                  ...
%     'LineStyle',      '-',                ...
%     'xAxis',          1:length(p),      ...
%     'alpha',          [0.05,0.01,0.001]);

if size(p,1)~=1, p = p'; end

%% check parameters with default
options = struct('position',       0,                  ...   
                 'Color',          [0,0,0],            ...
                 'LineWidth',      0.7124,                  ...
                 'LineStyle',      '-',                ...
                 'xAxis',          1:length(p),      ...
                 'alpha',          [0.05,0.01,0.001],...
                 'data',           []);
optionNames = fieldnames(options);
if mod(length(varargin),2) == 1
	error('Please provide propertyName/propertyValue pairs')
end
for pair = reshape(varargin,2,[])    % pair is {propName; propValue}
	if any(strcmp(pair{1}, optionNames))
        options.(pair{1}) = pair{2};
    else
        error('%s is not a recognized parameter name', pair{1})
	end
end
if ~isempty(options.data),
    tmp = mean(options.data,1);
    options.position = min(tmp(:))*0.5;
end

for al = 1:length(options.alpha)
    %% find the start & end significant point
    sig  = p < options.alpha(al);
    sigS = find(diff(sig(1,:),[],2)==1)+1;
    sigE = find(diff(sig(1,:),[],2)==-1)+1;
    if length(sigS)+length(sigE) > 0
        if length(sigS) > length(sigE),
            sigE(end+1) = length(options.xAxis);
        elseif length(sigS) < length(sigE),
            sigS = [1,sigS];
        elseif sigS(1) > sigE(1),
            sigE(end+1) = length(options.xAxis);
            sigS = [1,sigS];
        end
    elseif isempty(sigS) && sig(1,1) == 1 && sig(1,end) == 1
        sigS = 1; sigE = length(sig);
    end
    
    %% draw lines
    for s = 1:length(sigS)
        
        line(...
            [options.xAxis(sigS(s)),options.xAxis(sigE(s))],...
            repmat(options.position,1,2),...
            'Color',options.Color,...
            'LineWidth',options.LineWidth*al,...
            'LineStyle',options.LineStyle)
    end
    
    %% return points
    pts(al).bgn = sigS;
    pts(al).end = sigE;
end
end