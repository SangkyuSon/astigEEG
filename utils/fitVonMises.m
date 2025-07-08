function dirTuningInfo = fitVonMises(directions, resp, fixedDir);
%
% Function for getting direction tuning (von mises:wrapnormal)
% Modified for using in EEG data
%
% Joonyeol Lee
% 12/22/2018
% joonyeol@g.skku.edu
%
% fixed by ssk
% 12/02/2019 // 12/05/2019


    isfixed = (nargin == 3) && ~isempty(fixedDir);
    
    xData = directions*pi./180.0;
	yData = resp;
	dirTuningInfo = [];
    rMax = max(resp);
    
    if ~isfixed,
        
        maxIndex = find(resp == rMax);
        if length(maxIndex) > 1
            maxIndex = maxIndex(1);
        end
        startDir = directions(maxIndex)*pi/180.0;
        startDirPre = directions(maxIndex)-60;
        if startDirPre < -180
            startDirPre = startDirPre+360.0;
        end
        startDirPre = startDirPre*pi/180.0;
        startDirPost = directions(maxIndex)+60;
        if startDirPost > 180.0
            startDirPost = startDirPost-360.0;
        end
        startDirPost = startDirPost*pi/180.0;
        
        x0 = [rMax 0.5 startDir min(resp);rMax 1 startDir min(resp);rMax 4 startDir min(resp);rMax 0.5 startDirPre min(resp);rMax 0.5 startDirPost min(resp)];
        
        x = zeros(size(x0));
        output = zeros(size(x0, 1), 1);
        for i = 1:size(x0, 1)
            try,[x(i,:),fval,eFlag,output(i)] = fitSumDirTuning(x0(i,:), xData, yData); end
        end
    else
        fixedDir = fixedDir*pi/180;
        
        x0 = [rMax 0.5 min(resp);rMax 1 min(resp);rMax 4 min(resp)];
        
        x = zeros(size(x0));
        output = zeros(size(x0, 1), 1);
        for i = 1:size(x0, 1)
            [x(i,:),fval,eFlag,output(i)] = fitSumDirTuning(x0(i,:), xData, yData, fixedDir);
        end
    end


    
    

    maxOut = nanmax(output);
    maxOutArray = find(output == maxOut);
    ctDirs = linspace(-180,180,40);%[-180:0.1:179];
    ctDirsRad = ctDirs*pi./180.0;
    
    if isempty(maxOutArray)
        param0 = [nan nan nan];
        ev0 = nan;
        estDir = param0;
        evDir = ev0;
        tuningEstimates = NaN(1, length(ctDirs));
        offset = nan;
        peak = nan;
        halfWidth = nan;
    else
        param0 = x(maxOutArray(1), :);
        ev0 = maxOut;
        estDir = param0;
        evDir = ev0;
        if ~isfixed,
            tuningEstimates = circularNormalFunc(estDir, ctDirsRad);
        else
            tuningEstimates = circularNormalFunc(estDir, ctDirsRad,fixedDir);
        end
        offset = min(tuningEstimates);
        peak = max(tuningEstimates) - offset;
        halfWidth = 2*acos((log(0.5 + 0.5*exp(-2*estDir(2))))/estDir(2)+1);
        halfWidth = halfWidth*180.0/pi;
    end
    
    
    if ~isfixed,
        dirTuningInfo.estimates.pfDir = estDir(3)*180.0/pi;
    else
        dirTuningInfo.estimates.pfDir = fixedDir*180.0/pi;
    end

	dirTuningInfo.params.fit = estDir;
	dirTuningInfo.params.ev = evDir;
	dirTuningInfo.estimates.offset = offset;
	dirTuningInfo.estimates.amplitude = peak;
	dirTuningInfo.estimates.halfWidth = halfWidth;
	dirTuningInfo.estimates.directions = ctDirs;
	dirTuningInfo.estimates.tuningCurve = tuningEstimates;

	
function [x,fval,eFlag,output] = fitSumDirTuning(initGuess, directions, y, fixedDir)

	x0 = initGuess;
	
    opts = optimset('fmincon');
	opts = optimset(opts, 'MaxFunEvals', 10000, 'MaxIter', 10000, 'TolFun', 1e-12, 'TolX', 1e-12, 'FunValCheck','on');
	opts = optimset(opts, 'LargeScale', 'off', 'Display', 'off', 'Algorithm', 'active-set');
    
    if nargin < 4,
        vlb = [1 0.001 -pi -1000];                	% lower bounds
        vub = [800 5 pi 1000];         		% upper bounds
        
        [x,fval,eFlag,output] = fmincon(@(param) sumLsqDirTuning(param, directions, y), x0, [], [], [], [], vlb, vub, [], opts);
        y_hat = circularNormalFunc(x, directions);
        ss0 = sumLsqDirTuning(x, directions, y);
    else
        vlb = [1 0.001 -1000];                	% lower bounds
        vub = [800 5 1000];         		% upper bounds
        
        [x,fval,eFlag,output] = fmincon(@(param) sumLsqDirTuning(param, directions, y,fixedDir), x0, [], [], [], [], vlb, vub, [], opts);
        y_hat = circularNormalFunc(x, directions,fixedDir);
        ss0 = sumLsqDirTuning(x, directions, y,fixedDir);
    end
    
    
    ss0 = ss0/(length(y)-1);
    var0 = var(y);
    evVal = 1-ss0/var0;
    output = evVal;
	
function minValue = sumLsqDirTuning(param, directions, y, fixedDir)

    if nargin < 4,
        y_hat = circularNormalFunc(param, directions);
    else
        y_hat = circularNormalFunc(param, directions,fixedDir);
    end
    lsq_sum = (y - y_hat).^2;
	minValue = sum(lsq_sum);

function y_hat = circularNormalFunc(param, directions,fixedDir)
    if nargin < 3,
        y_hat = param(1)*exp(param(2)*(cos(directions - param(3))-1))+param(4);
    else
        y_hat = param(1)*exp(param(2)*(cos(directions - fixedDir)-1))+param(3);
    end
	


