function pixel = deg2pixel(deg,varargin)
% convert visual angle into monitor's pixel

% argument check
options = struct('monitorSize',   [40.6,30.4],                  ...    % horizontal 40.6cm, vertical 30.4cm
                 'eyeDistance',   60,...                                 % eye distance 60cm
                 'screenResol',   [800,600]);
 options = checkOptions(options,varargin{:});

%
%ratio = [env(3)/options.monitorSize(1),env(4)/options.monitorSize(2)];
ratio = sqrt(sum(options.screenResol.^2))/sqrt(sum(options.monitorSize.^2));
pixel = round(options.eyeDistance*tand(deg).*ratio);

end

function options = checkOptions(options,varargin)
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
end