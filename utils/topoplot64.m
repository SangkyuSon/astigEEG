function topoplot64(dat,minmax,flipper)
if nargin < 2, minmax = [-max(abs(dat)),max(abs(dat))]; end
if nargin < 3, flipper = 0; end
if size(dat,1) ~= 64, dat = dat'; end
load(fullfile(pwd,'data','chanlocs'))

if flipper, dat = fliptopo64(dat,chanlocs); end

topoplot_new(dat, chanlocs,'maplimits',minmax,'headrad','rim');
%topoplot(dat, chanlocs,'maplimits','absmax','headrad','rim');
end


function [handle,Zi,grid,Xi,Yi] = topoplot_new(Values,loc_file,p1,v1,p2,v2,p3,v3,p4,v4,p5,v5,p6,v6,p7,v7,p8,v8,p9,v9,p10,v10,p11,v11)

%
%%%%%%%%%%%%%%%%%%%%%%%% Set defaults %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%


% ------------------------------------------------------
% -------------- EEGLAB DEFINITION (V 4.0) -------------
% ------------------------------------------------------

EEGLAB_VERSION = '6.03b'; % EEGLAB version s=stable, b=beta, a=alpha (SCCN only)

TUTORIAL_URL = 'http://sccn.ucsd.edu/eeglab/eeglabdocs.html'; % online version
% NB: If there is a local copy of the web site,
%     replace the line above with a line like the following:
% TUTORIAL_URL = 'file://C:\folder\eeglabtutorial\eeglabdocs.html'; % Windows
% TUTORIAL_URL = 'file:///home/user/eeglabtutorial/eeglabdocs.html'; % Unix
% TUTORIAL_URL = 'file://::disk:folder:eeglabtutorial:eeglabdocs.html'; % Mac

%ICABINARY = '/home/duann/matlab/fmrlab4.0/ica_linux2.4';
ICABINARY = '/data/common/matlab/eeglab/functions/resources/ica_linux';
%                           % <=INSERT location of ica executable for binica.m above
%                           % If none, use []

YDIR  = 1;                  % positive potential up = 1; negative up = -1
HZDIR = 'up';               % ascending freqs = 'up'; descending = 'down'
% (e.g., timef/newtimef frequency direction)
DEFAULT_SRATE = 256.0175;   % default local sampling rate
DEFAULT_TIMLIM = [-1000 2000]; % default local epoch limits (ms)




% Set EEGLAB figure and GUI colors
% --------------------------------
if get(0, 'screendepth') <=8 % if mono or 8-bit color
    fprintf('icadefs(): Setting display parameters for mono or 8-bit color\n');
    %BACKCOLOR           = [1 1 1];    % Background figure color
    BACKCOLOR           = [0 0 0];    % Background figure color
    BACKEEGLABCOLOR     = [1 1 1];    % EEGLAB main window background
    GUIBUTTONCOLOR      = [1 1 1];    % Buttons colors in figures
    GUIPOPBUTTONCOLOR   = [1 1 1];    % Buttons colors in GUI windows
    GUIBACKCOLOR        = [1 1 1];    % GUI background color
    GUITEXTCOLOR        = [0 0 0];      % GUI foreground color for text
    PLUGINMENUCOLOR     = [.5 0 .5];  % plugin menu color
    
else % if full color screen
    BACKCOLOR           = [.93 .96 1];    % EEGLAB Background figure color
    %     BACKCOLOR           = [0 0 0];    % EEGLAB Background figure color
    BACKEEGLABCOLOR     = [.66 .76 1];    % EEGLAB main window background
    GUIBUTTONCOLOR      = BACKEEGLABCOLOR;% Buttons colors in figures
    GUIPOPBUTTONCOLOR   = BACKCOLOR;      % Buttons colors in GUI windows
    GUIBACKCOLOR        = BACKEEGLABCOLOR;% EEGLAB GUI background color <---------
    GUITEXTCOLOR        = [0 0 0.4];      % GUI foreground color for text
    PLUGINMENUCOLOR     = [.5 0 .5];      % plugin menu color
end;


% THE FOLLOWING PARAMETERS WILL BE DEPRECATED IN LATER VERSIONS
% -------------------------------------------------------------

SHRINKWARNING = 1;          % Warn user about the shrink factor in topoplot() (1/0)

MAXENVPLOTCHANS   = 264;  % maximum number of channels to plot in envproj.m
MAXPLOTDATACHANS  = 264;  % maximum number of channels to plot in dataplot.m
MAXPLOTDATAEPOCHS = 264;  % maximum number of epochs to plot in dataplot.m
MAXEEGPLOTCHANS   = 264;  % maximum number of channels to plot in eegplot.m
MAXTOPOPLOTCHANS  = 264;  % maximum number of channels to plot in topoplot.m

DEFAULT_ELOC  = 'chan.locs'; % default electrode location file for topoplot.m
DEFAULT_EPOCH = 10;       % default epoch width to plot in eegplot(s) (in sec)

SC  =  ['binica.sc'];           % Master .sc script file for binica.m
% MATLAB will use first such file found
% in its path of script directories.
% Copy to pwd to alter ICA defaults
% read defaults MAXTOPOPLOTCHANS and DEFAULT_ELOC and BACKCOLOR
if ~exist('BACKCOLOR')  % if icadefs.m does not define BACKCOLOR
    BACKCOLOR = [.93 .96 1];  % EEGLAB standard
end
cmap = colormap;
cmaplen = size(cmap,1);
whitebk = 'off';  % by default, make gridplot background color = EEGLAB screen background color

plotgrid = 'off';
plotchans = [];
noplot  = 'off';
handle = [];
Zi = [];
chanval = NaN;
rmax = 0.5;             % actual head radius - Don't change this!
INTERPLIMITS = 'head';  % head, electrodes
INTSQUARE = 'on';       % default, interpolate electrodes located though the whole square containing
% the plotting disk
default_intrad = 1;     % indicator for (no) specified intrad
MAPLIMITS = 'absmax';   % absmax, maxmin, [values]
GRID_SCALE = 67;        % plot map on a 67X67 grid
CIRCGRID   = 201;       % number of angles to use in drawing circles
AXHEADFAC = 1.3;        % head to axes scaling factor
CONTOURNUM = 6;         % number of contour levels to plot
STYLE = 'both';         % default 'style': both,straight,fill,contour,blank
HEADCOLOR = [0 0 0];    % default head color (black)
CCOLOR = [0.2 0.2 0.2]; % default contour color
ELECTRODES = [];        % default 'electrodes': on|off|label - set below
MAXDEFAULTSHOWLOCS = 64;% if more channels than this, don't show electrode locations by default
EMARKER = '.';          % mark electrode locations with small disks
ECOLOR = [0 0 0];       % default electrode color = black
EMARKERSIZE = [];       % default depends on number of electrodes, set in code
EMARKERLINEWIDTH = 1;   % default edge linewidth for emarkers
EMARKERSIZE1CHAN = 40;  % default selected channel location marker size
EMARKERCOLOR1CHAN = 'red'; % selected channel location marker color
EMARKER2CHANS = [];      % mark subset of electrode locations with small disks
EMARKER2 = 'o';          % mark subset of electrode locations with small disks
EMARKER2COLOR = 'r';     % mark subset of electrode locations with small disks
EMARKERSIZE2 = 10;      % default selected channel location marker size
EMARKER2LINEWIDTH = 1;
EFSIZE = get(0,'DefaultAxesFontSize'); % use current default fontsize for electrode labels
HLINEWIDTH = 1.7;         % default linewidth for head, nose, ears
BLANKINGRINGWIDTH = .035;% width of the blanking ring
HEADRINGWIDTH    = .007;% width of the cartoon head ring
SHADING = 'flat';       % default 'shading': flat|interp
shrinkfactor = [];      % shrink mode (dprecated)
intrad       = [];      % default interpolation square is to outermost electrode (<=1.0)
plotrad      = [];      % plotting radius ([] = auto, based on outermost channel location)
headrad      = [];      % default plotting radius for cartoon head is 0.5
squeezefac = 1.0;
MINPLOTRAD = 0.15;      % can't make a topoplot with smaller plotrad (contours fail)
VERBOSE = 'off';
MASKSURF = 'off';
CONVHULL = 'off';       % dont mask outside the electrodes convex hull
DRAWAXIS = 'off';
CHOOSECHANTYPE = 0;

%%%%%% Dipole defaults %%%%%%%%%%%%
DIPOLE  = [];
DIPNORM   = 'on';
DIPSPHERE = 85;
DIPLEN    = 1;
DIPSCALE  = 1;
DIPORIENT  = 1;
DIPCOLOR  = [0 0 0];
NOSEDIR   = '+X';
CHANINFO  = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
%%%%%%%%%%%%%%%%%%%%%%% Handle arguments %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if nargin< 1
    help topoplot;
    return
end
nargs = nargin;
if nargs == 1
    if isstr(Values)
        if any(strcmp(lower(Values),{'example','demo'}))
            fprintf(['This is an example of an electrode location file,\n',...
                'an ascii file consisting of the following four columns:\n',...
                ' channel_number degrees arc_length channel_name\n\n',...
                'Example:\n',...
                ' 1               -18    .352       Fp1 \n',...
                ' 2                18    .352       Fp2 \n',...
                ' 5               -90    .181       C3  \n',...
                ' 6                90    .181       C4  \n',...
                ' 7               -90    .500       A1  \n',...
                ' 8                90    .500       A2  \n',...
                ' 9              -142    .231       P3  \n',...
                '10               142    .231       P4  \n',...
                '11                 0    .181       Fz  \n',...
                '12                 0    0          Cz  \n',...
                '13               180    .181       Pz  \n\n',...
                ...
                'In topoplot() coordinates, 0 deg. points to the nose, positive\n',...
                'angles point to the right hemisphere, and negative to the left.\n',...
                'The model head sphere has a circumference of 2; the vertex\n',...
                '(Cz) has arc_length 0. Locations with arc_length > 0.5 are below\n',...
                'head center and are plotted outside the head cartoon.\n'....
                'Option plotrad controls how much of this lower-head "skirt" is shown.\n',...
                'Option headrad controls if and where the cartoon head will be drawn.\n',...
                'Option intrad controls how many channels will be included in the interpolation.\n',...
                ])
            return
        end
    end
end
if nargs < 2
    loc_file = DEFAULT_ELOC;
    if ~exist(loc_file)
        fprintf('default locations file "%s" not found - specify chan_locs in topoplot() call.\n',loc_file)
        error(' ')
    end
end
if isempty(loc_file)
    loc_file = 0;
end
if isnumeric(loc_file) & loc_file == 0
    loc_file = DEFAULT_ELOC;
end

if nargs > 2
    if ~(round(nargs/2) == nargs/2)
        error('Odd number of input arguments??')
    end
    for i = 3:2:nargs
        Param = eval(['p',int2str((i-3)/2 +1)]);
        Value = eval(['v',int2str((i-3)/2 +1)]);
        if ~isstr(Param)
            error('Flag arguments must be strings')
        end
        Param = lower(Param);
        switch Param
            case 'conv'
                CONVHULL = lower(Value);
                if ~strcmp(CONVHULL,'on') & ~strcmp(CONVHULL,'off')
                    error('Value of ''conv'' must be ''on'' or ''off''.');
                end
            case 'colormap'
                if size(Value,2)~=3
                    error('Colormap must be a n x 3 matrix')
                end
                colormap(Value)
            case 'intsquare'
                INTSQUARE = lower(Value);
                if ~strcmp(INTSQUARE,'on') & ~strcmp(INTSQUARE,'off')
                    error('Value of ''intsquare'' must be ''on'' or ''off''.');
                end
            case {'interplimits','headlimits'}
                if ~isstr(Value)
                    error('''interplimits'' value must be a string')
                end
                Value = lower(Value);
                if ~strcmp(Value,'electrodes') & ~strcmp(Value,'head')
                    error('Incorrect value for interplimits')
                end
                INTERPLIMITS = Value;
            case 'verbose'
                VERBOSE = Value;
            case 'nosedir'
                NOSEDIR = Value;
                if isempty(strmatch(lower(NOSEDIR), { '+x', '-x', '+y', '-y' }))
                    error('Invalid nose direction');
                end;
            case 'chaninfo'
                CHANINFO = Value;
                if isfield(CHANINFO, 'nosedir'), NOSEDIR      = CHANINFO.nosedir; end;
                if isfield(CHANINFO, 'shrink' ), shrinkfactor = CHANINFO.shrink;  end;
                if isfield(CHANINFO, 'plotrad') & isempty(plotrad), plotrad = CHANINFO.plotrad; end;
                if isfield(CHANINFO, 'chantype')
                    chantype = CHANINFO.chantype;
                    if ischar(chantype), chantype = cellstr(chantype); end
                    CHOOSECHANTYPE = 1;
                end
            case 'chantype'
                chantype = Value;
                CHOOSECHANTYPE = 1;
                if ischar(chantype), chantype = cellstr(chantype); end
                if ~iscell(chantype), error('chantype must be cell array. e.g. {''EEG'', ''EOG''}'); end
            case 'drawaxis'
                DRAWAXIS = Value;
            case 'maplimits'
                MAPLIMITS = Value;
            case 'masksurf'
                MASKSURF = Value;
            case 'circgrid'
                CIRCGRID = Value;
                if isstr(CIRCGRID) | CIRCGRID<100
                    error('''circgrid'' value must be an int > 100');
                end
            case 'style'
                STYLE = lower(Value);
            case 'numcontour'
                CONTOURNUM = Value;
            case 'electrodes'
                ELECTRODES = lower(Value);
                if strcmpi(ELECTRODES,'pointlabels') | strcmpi(ELECTRODES,'ptslabels') ...
                        | strcmpi(ELECTRODES,'labelspts') | strcmpi(ELECTRODES,'ptlabels') ...
                        | strcmpi(ELECTRODES,'labelpts')
                    ELECTRODES = 'labelpoint'; % backwards compatability
                elseif strcmpi(ELECTRODES,'pointnumbers') | strcmpi(ELECTRODES,'ptsnumbers') ...
                        | strcmpi(ELECTRODES,'numberspts') | strcmpi(ELECTRODES,'ptnumbers') ...
                        | strcmpi(ELECTRODES,'numberpts')  | strcmpi(ELECTRODES,'ptsnums')  ...
                        | strcmpi(ELECTRODES,'numspts')
                    ELECTRODES = 'numpoint'; % backwards compatability
                elseif strcmpi(ELECTRODES,'nums')
                    ELECTRODES = 'numbers'; % backwards compatability
                elseif strcmpi(ELECTRODES,'pts')
                    ELECTRODES = 'on'; % backwards compatability
                elseif ~strcmp(ELECTRODES,'off') ...
                        & ~strcmpi(ELECTRODES,'on') ...
                        & ~strcmp(ELECTRODES,'labels') ...
                        & ~strcmpi(ELECTRODES,'numbers') ...
                        & ~strcmpi(ELECTRODES,'labelpoint') ...
                        & ~strcmpi(ELECTRODES,'numpoint')
                    error('Unknown value for keyword ''electrodes''');
                end
            case 'dipole'
                DIPOLE = Value;
            case 'dipsphere'
                DIPSPHERE = Value;
            case 'dipnorm'
                DIPNORM = Value;
            case 'diplen'
                DIPLEN = Value;
            case 'dipscale'
                DIPSCALE = Value;
            case 'diporient'
                DIPORIENT = Value;
            case 'dipcolor'
                DIPCOLOR = Value;
            case 'emarker'
                if ischar(Value)
                    EMARKER = Value;
                elseif ~iscell(Value) | length(Value) > 4
                    error('''emarker'' argument must be a cell array {marker color size linewidth}')
                else
                    EMARKER = Value{1};
                end
                if length(Value) > 1
                    ECOLOR = Value{2};
                end
                if length(Value) > 2
                    EMARKERSIZE2 = Value{3};
                end
                if length(Value) > 3
                    EMARKERLINEWIDTH = Value{4};
                end
            case 'emarker2'
                if ~iscell(Value) | length(Value) > 5
                    error('''emarker2'' argument must be a cell array {chans marker color size linewidth}')
                end
                EMARKER2CHANS = abs(Value{1}); % ignore channels < 0
                if length(Value) > 1
                    EMARKER2 = Value{2};
                end
                if length(Value) > 2
                    EMARKER2COLOR = Value{3};
                end
                if length(Value) > 3
                    EMARKERSIZE2 = Value{4};
                end
                if length(Value) > 4
                    EMARKER2LINEWIDTH = Value{5};
                end
            case 'shrink'
                shrinkfactor = Value;
            case 'intrad'
                intrad = Value;
                if isstr(intrad) | (intrad < MINPLOTRAD | intrad > 1)
                    error('intrad argument should be a number between 0.15 and 1.0');
                end
            case 'plotrad'
                plotrad = Value;
                if isstr(plotrad) | (plotrad < MINPLOTRAD | plotrad > 1)
                    error('plotrad argument should be a number between 0.15 and 1.0');
                end
            case 'headrad'
                headrad = Value;
                if isstr(headrad) & ( strcmpi(headrad,'off') | strcmpi(headrad,'none') )
                    headrad = 0;       % undocumented 'no head' alternatives
                end
                if isempty(headrad) % [] -> none also
                    headrad = 0;
                end
                if ~isstr(headrad)
                    if ~(headrad==0) & (headrad < MINPLOTRAD | headrad>1)
                        error('bad value for headrad');
                    end
                elseif  ~strcmpi(headrad,'rim')
                    error('bad value for headrad');
                end
            case {'headcolor','hcolor'}
                HEADCOLOR = Value;
            case {'contourcolor','ccolor'}
                CCOLOR = Value;
            case {'electcolor','ecolor'}
                ECOLOR = Value;
            case {'emarkersize','emsize'}
                EMARKERSIZE = Value;
            case {'emarkersize1chan','emarkersizemark'}
                EMARKERSIZE1CHAN= Value;
            case {'efontsize','efsize'}
                EFSIZE = Value;
            case 'shading'
                SHADING = lower(Value);
                if ~any(strcmp(SHADING,{'flat','interp'}))
                    error('Invalid shading parameter')
                end
            case 'noplot'
                noplot = Value;
                if ~isstr(noplot)
                    if length(noplot) ~= 2
                        error('''noplot'' location should be [radius, angle]')
                    else
                        chanrad = noplot(1);
                        chantheta = noplot(2);
                        noplot = 'on';
                    end
                end
            case 'gridscale'
                GRID_SCALE = Value;
                if isstr(GRID_SCALE) | GRID_SCALE ~= round(GRID_SCALE) | GRID_SCALE < 32
                    error('''gridscale'' value must be integer > 32.');
                end
            case {'plotgrid','gridplot'}
                plotgrid = 'on';
                gridchans = Value;
            case 'plotchans'
                plotchans = Value(:);
                if find(plotchans<=0)
                    error('''plotchans'' values must be > 0');
                end
                % if max(abs(plotchans))>max(Values) | max(abs(plotchans))>length(Values) -sm ???
            case {'whitebk','whiteback','forprint'}
                whitebk = Value;
            otherwise
                error(['Unknown input parameter ''' Param ''' ???'])
        end
    end
end
if strcmpi(whitebk, 'on')
    BACKCOLOR = [ 1 1 1 ];
end;

%
%%%%%%%%%%%%%%%%%%%%%%%%%%% test args for plotting an electrode grid %%%%%%%%%%%%%%%%%%%%%%
%
if strcmp(plotgrid,'on')
    STYLE = 'grid';
    gchans = sort(find(abs(gridchans(:))>0));
    
    % if setdiff(gchans,unique(gchans))
    %      fprintf('topoplot() warning: ''plotgrid'' channel matrix has duplicate channels\n');
    % end
    
    if ~isempty(plotchans)
        if intersect(gchans,abs(plotchans))
            fprintf('topoplot() warning: ''plotgrid'' and ''plotchans'' have channels in common\n');
        end
    end
end

%
%%%%%%%%%%%%%%%%%%%%%%%%%%% misc arg tests %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if isempty(ELECTRODES)                     % if electrode labeling not specified
    if length(Values) > MAXDEFAULTSHOWLOCS   % if more channels than default max
        ELECTRODES = 'off';                    % don't show electrodes
    else                                     % else if fewer chans,
        ELECTRODES = 'on';                     % do
    end
end

if isempty(Values)
    STYLE = 'blank';
end
[r,c] = size(Values);
if r>1 & c>1,
    error('input data must be a single vector');
end
Values = Values(:); % make Values a column vector

if ~isempty(intrad) & ~isempty(plotrad) & intrad < plotrad
    error('intrad must be >= plotrad');
end

if ~strcmpi(STYLE,'grid')                     % if not plot grid only
    
    %
    %%%%%%%%%%%%%%%%%%%% Read the channel location information %%%%%%%%%%%%%%%%%%%%%%%%
    %
    if isstr(loc_file)
        [tmpeloc labels Th Rd indices] = readlocs( loc_file,'filetype','loc');
    elseif isstruct(loc_file) % a locs struct
        [tmpeloc labels Th Rd indices] = readlocs( loc_file );
        % Note: Th and Rd correspond to indices channels-with-coordinates only
    else
        error('loc_file must be a EEG.locs struct or locs filename');
    end
    Th = pi/180*Th;                              % convert degrees to radians
    allchansind = 1:length(Th);
    
    %
    %%%%%%%%%% if channels-to-mark-only are given in Values vector %%%%%%%%%%%%%%%%%
    %
    if length(Values) < length(tmpeloc) & strcmpi( STYLE, 'blank') % if Values contains int channel indices to mark
        if isempty(plotchans)
            if Values ~= abs(round(Values)) | min(abs(Values))< 1  % if not positive integer values
                error('Negative channel indices');
            elseif strcmpi(VERBOSE, 'on')
                fprintf('topoplot(): max chan number (%d) in locs > channels in data (%d).\n',...
                    max(indices),length(Values));
                fprintf('            Marking the locations of the %d indicated channels.\n', ...
                    length(Values));
            end
            plotchans = Values;
            STYLE = 'blank'; % plot channels only, marking the indicated channel number
            if strcmpi(ELECTRODES,'off')
                ELECTRODES = 'on';
            end
        else
            error('input ''plotchans'' not allowed when input data are channel numbers');
        end
    end
    
    if ~isempty(plotchans)
        if max(plotchans) > length(Th)
            error('''plotchans'' values must be <= max channel index');
        end
    end
    
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% channels to plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    if ~isempty(plotchans)
        plotchans = intersect(plotchans, indices);
    end;
    if ~isempty(Values) & ~strcmpi( STYLE, 'blank') & isempty(plotchans)
        plotchans = indices;
    end
    if isempty(plotchans) & strcmpi( STYLE, 'blank')
        plotchans = indices;
    end
    
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%% filter for channel type(s), if specified %%%%%%%%%%%%%%%%%%%%%
    %
    
    if CHOOSECHANTYPE,
        newplotchans = eeg_chantype(loc_file,chantype);
        plotchans = intersect(newplotchans, plotchans);
    end
    
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%% filter channels used for components %%%%%%%%%%%%%%%%%%%%%
    %
    if isfield(CHANINFO, 'icachansind') & ~isempty(Values) & length(Values) ~= length(tmpeloc)
        
        % test if ICA component
        % ---------------------
        if length(CHANINFO.icachansind) == length(Values)
            
            % if only a subset of channels are to be plotted
            % and ICA components also use a subject of channel
            % we must find the new indices for these channels
            
            plotchans = intersect(CHANINFO.icachansind, plotchans);
            tmpvals   = zeros(1, length(tmpeloc));
            tmpvals(CHANINFO.icachansind) = Values;
            Values    = tmpvals;
            
        end;
    end;
    
    %
    %%%%%%%%%%%%%%%%%%% last channel is reference? %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    if length(tmpeloc) == length(Values) + 1 % remove last channel if necessary
        % (common reference channel)
        if plotchans(end) == length(tmpeloc)
            plotchans(end) = [];
        end;
        
    end;
    
    %
    %%%%%%%%%%%%%%%%%%% remove infinite and NaN values %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    if length(Values) > 1
        inds          = union(find(isnan(Values)), find(isinf(Values))); % NaN and Inf values
        plotchans     = setdiff(plotchans, inds);
    end;
    if strcmp(plotgrid,'on')
        plotchans = setxor(plotchans,gchans);   % remove grid chans from head plotchans
    end
    
    [x,y]     = pol2cart(Th,Rd);  % transform electrode locations from polar to cartesian coordinates
    plotchans = abs(plotchans);   % reverse indicated channel polarities
    allchansind = allchansind(plotchans);
    Th        = Th(plotchans);
    Rd        = Rd(plotchans);
    x         = x(plotchans);
    y         = y(plotchans);
    labels    = labels(plotchans); % remove labels for electrodes without locations
    labels    = strvcat(labels); % make a label string matrix
    if ~isempty(Values) & length(Values) > 1 & ~strcmpi( STYLE, 'blank')
        Values    = Values(plotchans);
    end;
    
    %
    %%%%%%%%%%%%%%%%%% Read plotting radius from chanlocs  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    if isempty(plotrad) & isfield(tmpeloc, 'plotrad'),
        plotrad = tmpeloc(1).plotrad;
        if isstr(plotrad)                        % plotrad shouldn't be a string
            plotrad = str2num(plotrad)           % just checking
        end
        if plotrad < MINPLOTRAD | plotrad > 1.0
            fprintf('Bad value (%g) for plotrad.\n',plotrad);
            error(' ');
        end
        if strcmpi(VERBOSE,'on') & ~isempty(plotrad)
            fprintf('Plotting radius plotrad (%g) set from EEG.chanlocs.\n',plotrad);
        end
    end;
    if isempty(plotrad)
        plotrad = min(1.0,max(Rd)*1.02);            % default: just outside the outermost electrode location
        plotrad = max(plotrad,0.5);                 % default: plot out to the 0.5 head boundary
    end                                           % don't plot channels with Rd > 1 (below head)
    
    if isempty(intrad)
        default_intrad = 1;     % indicator for (no) specified intrad
        intrad = min(1.0,max(Rd)*1.02);             % default: just outside the outermost electrode location
    else
        default_intrad = 0;                         % indicator for (no) specified intrad
        if plotrad > intrad
            plotrad = intrad;
        end
    end                                           % don't interpolate channels with Rd > 1 (below head)
    if isstr(plotrad) | plotrad < MINPLOTRAD | plotrad > 1.0
        error('plotrad must be between 0.15 and 1.0');
    end
    
    %
    %%%%%%%%%%%%%%%%%%%%%%% Set radius of head cartoon %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    if isempty(headrad)  % never set -> defaults
        if plotrad >= rmax
            headrad = rmax;  % (anatomically correct)
        else % if plotrad < rmax
            headrad = 0;    % don't plot head
            if strcmpi(VERBOSE, 'on')
                fprintf('topoplot(): not plotting cartoon head since plotrad (%5.4g) < 0.5\n',...
                    plotrad);
            end
        end
    elseif strcmpi(headrad,'rim') % force plotting at rim of map
        headrad = plotrad;
    end
    
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Shrink mode %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    if ~isempty(shrinkfactor) | isfield(tmpeloc, 'shrink'),
        if isempty(shrinkfactor) & isfield(tmpeloc, 'shrink'),
            shrinkfactor = tmpeloc(1).shrink;
            if strcmpi(VERBOSE,'on')
                if isstr(shrinkfactor)
                    fprintf('Automatically shrinking coordinates to lie above the head perimter.\n');
                else
                    fprintf('Automatically shrinking coordinates by %3.2f\n', shrinkfactor);
                end;
            end
        end;
        
        if isstr(shrinkfactor)
            if strcmpi(shrinkfactor, 'on') | strcmpi(shrinkfactor, 'force') | strcmpi(shrinkfactor, 'auto')
                if abs(headrad-rmax) > 1e-2
                    fprintf('     NOTE -> the head cartoon will NOT accurately indicate the actual electrode locations\n');
                end
                if strcmpi(VERBOSE,'on')
                    fprintf('     Shrink flag -> plotting cartoon head at plotrad\n');
                end
                headrad = plotrad; % plot head around outer electrodes, no matter if 0.5 or not
            end
        else % apply shrinkfactor
            plotrad = rmax/(1-shrinkfactor);
            headrad = plotrad;  % make deprecated 'shrink' mode plot
            if strcmpi(VERBOSE,'on')
                fprintf('    %g%% shrink  applied.');
                if abs(headrad-rmax) > 1e-2
                    fprintf(' Warning: With this "shrink" setting, the cartoon head will NOT be anatomically correct.\n');
                else
                    fprintf('\n');
                end
            end
        end
    end; % if shrink
    
    %
    %%%%%%%%%%%%%%%%% Issue warning if headrad ~= rmax  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    
    if headrad ~= 0.5 & strcmpi(VERBOSE, 'on')
        fprintf('     NB: Plotting map using ''plotrad'' %-4.3g,',plotrad);
        fprintf(    ' ''headrad'' %-4.3g\n',headrad);
        fprintf('Warning: The plotting radius of the cartoon head is NOT anatomically correct (0.5).\n')
    end
    %
    %%%%%%%%%%%%%%%%%%%%% Find plotting channels  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    
    pltchans = find(Rd <= plotrad); % plot channels inside plotting circle
    
    if strcmpi(INTSQUARE,'on') &  ~strcmpi(STYLE,'blank') % interpolate channels in the radius intrad square
        intchans = find(x <= intrad & y <= intrad); % interpolate and plot channels inside interpolation square
    else
        intchans = find(Rd <= intrad); % interpolate channels in the radius intrad circle only
    end
    
    %
    %%%%%%%%%%%%%%%%%%%%% Eliminate channels not plotted  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    
    allx      = x;
    ally      = y;
    intchans; % interpolate using only the 'intchans' channels
    pltchans; % plot using only indicated 'plotchans' channels
    
    if length(pltchans) < length(Rd) & strcmpi(VERBOSE, 'on')
        fprintf('Interpolating %d and plotting %d of the %d scalp electrodes.\n', ...
            length(intchans),length(pltchans),length(Rd));
    end;
    
    
    % fprintf('topoplot(): plotting %d channels\n',length(pltchans));
    if ~isempty(EMARKER2CHANS)
        if strcmpi(STYLE,'blank')
            error('emarker2 not defined for style ''blank'' - use marking channel numbers in place of data');
        else % mark1chans and mark2chans are subsets of pltchans for markers 1 and 2
            [tmp1 mark1chans tmp2] = setxor(pltchans,EMARKER2CHANS);
            [tmp3 tmp4 mark2chans] = intersect(EMARKER2CHANS,pltchans);
        end
    end
    
    if ~isempty(Values)
        if length(Values) == length(Th)  % if as many map Values as channel locs
            intValues = Values(intchans);
            Values = Values(pltchans);
        else
            if strcmp(STYLE,'blank')    % else if Values holds numbers of channels to mark
                tmpValues=[];
                cc=1;
                for kk=1:length(Values)
                    tmpind = find(pltchans == Values(kk));
                    if ~isempty(tmpind)
                        tmpValues(cc) = tmpind;
                        cc=cc+1;
                    end;
                end
                Values=tmpValues;     % eliminate the channel indices outside plotting area
            end;
        end;
    end;   % now channel parameters and values all refer to plotting channels only
    
    allchansind = allchansind(pltchans);
    intTh = Th(intchans);           % eliminate channels outside the interpolation area
    intRd = Rd(intchans);
    intx  = x(intchans);
    inty  = y(intchans);
    Th    = Th(pltchans);              % eliminate channels outside the plotting area
    Rd    = Rd(pltchans);
    x     = x(pltchans);
    y     = y(pltchans);
    
    labels= labels(pltchans,:);
    %
    %%%%%%%%%%%%%%% Squeeze channel locations to <= rmax %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    
    squeezefac = rmax/plotrad;
    intRd = intRd*squeezefac; % squeeze electrode arc_lengths towards the vertex
    Rd = Rd*squeezefac;       % squeeze electrode arc_lengths towards the vertex
    % to plot all inside the head cartoon
    intx = intx*squeezefac;
    inty = inty*squeezefac;
    x    = x*squeezefac;
    y    = y*squeezefac;
    allx    = allx*squeezefac;
    ally    = ally*squeezefac;
    % Note: Now outermost channel will be plotted just inside rmax
    
else % if strcmpi(STYLE,'grid')
    intx = rmax; inty=rmax;
end % if ~strcmpi(STYLE,'grid')

%
%%%%%%%%%%%%%%%% rotate channels based on chaninfo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if strcmpi(lower(NOSEDIR), '+x')
    rotate = 0;
else
    if strcmpi(lower(NOSEDIR), '+y')
        rotate = 3*pi/2;
    elseif strcmpi(lower(NOSEDIR), '-x')
        rotate = pi;
    else rotate = pi/2;
    end;
    allcoords = (inty + intx*sqrt(-1))*exp(sqrt(-1)*rotate);
    intx = imag(allcoords);
    inty = real(allcoords);
    allcoords = (ally + allx*sqrt(-1))*exp(sqrt(-1)*rotate);
    allx = imag(allcoords);
    ally = real(allcoords);
    allcoords = (y + x*sqrt(-1))*exp(sqrt(-1)*rotate);
    x = imag(allcoords);
    y = real(allcoords);
end;

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Make the plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if ~strcmpi(STYLE,'blank') % if draw interpolated scalp map
    if ~strcmpi(STYLE,'grid') %  not a rectangular channel grid
        %
        %%%%%%%%%%%%%%%% Find limits for interpolation %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        if default_intrad % if no specified intrad
            if strcmpi(INTERPLIMITS,'head') % intrad is 'head'
                xmin = min(-rmax,min(intx)); xmax = max(rmax,max(intx));
                ymin = min(-rmax,min(inty)); ymax = max(rmax,max(inty));
                
            else % INTERPLIMITS = rectangle containing electrodes -- DEPRECATED OPTION!
                xmin = max(-rmax,min(intx)); xmax = min(rmax,max(intx));
                ymin = max(-rmax,min(inty)); ymax = min(rmax,max(inty));
            end
        else % some other intrad specified
            xmin = -intrad*squeezefac; xmax = intrad*squeezefac;   % use the specified intrad value
            ymin = -intrad*squeezefac; ymax = intrad*squeezefac;
        end
        %
        %%%%%%%%%%%%%%%%%%%%%%% Interpolate scalp map data %%%%%%%%%%%%%%%%%%%%%%%%
        %
        xi = linspace(xmin,xmax,GRID_SCALE);   % x-axis description (row vector)
        yi = linspace(ymin,ymax,GRID_SCALE);   % y-axis description (row vector)
        
        [Xi,Yi,Zi] = griddata(inty,intx,intValues,yi',xi,'v4'); % interpolate data
        %
        %%%%%%%%%%%%%%%%%%%%%%% Mask out data outside the head %%%%%%%%%%%%%%%%%%%%%
        %
        mask = (sqrt(Xi.^2 + Yi.^2) <= rmax); % mask outside the plotting circle
        ii = find(mask == 0);
        Zi(ii) = NaN;                         % mask non-plotting voxels with NaNs
        grid = plotrad;                       % unless 'noplot', then 3rd output arg is plotrad
        %
        %%%%%%%%%% Return interpolated value at designated scalp location %%%%%%%%%%
        %
        if exist('chanrad')   % optional first argument to 'noplot'
            chantheta = (chantheta/360)*2*pi;
            chancoords = round(ceil(GRID_SCALE/2)+GRID_SCALE/2*2*chanrad*[cos(-chantheta),...
                -sin(-chantheta)]);
            if chancoords(1)<1 ...
                    | chancoords(1) > GRID_SCALE ...
                    | chancoords(2)<1 ...
                    | chancoords(2)>GRID_SCALE
                error('designated ''noplot'' channel out of bounds')
            else
                chanval = Zi(chancoords(1),chancoords(2));
                grid = Zi;
                Zi = chanval;  % return interpolated value instead of Zi
            end
        end
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%% Return interpolated image only  %%%%%%%%%%%%%%%%%
        %
        if strcmpi(noplot, 'on')
            if strcmpi(VERBOSE,'on')
                fprintf('topoplot(): no plot requested.\n')
            end
            return;
        end
        %
        %%%%%%%%%%%%%%%%%%%%%%% Calculate colormap limits %%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        if isstr(MAPLIMITS)
            if strcmp(MAPLIMITS,'absmax')
                amax = max(max(abs(Zi)));
                amin = -amax;
            elseif strcmp(MAPLIMITS,'maxmin') | strcmp(MAPLIMITS,'minmax')
                amin = min(min(Zi));
                amax = max(max(Zi));
            else
                error('unknown ''maplimits'' value.');
            end
        elseif length(MAPLIMITS) == 2
            amin = MAPLIMITS(1);
            amax = MAPLIMITS(2);
        else
            error('unknown ''maplimits'' value');
        end
        delta = xi(2)-xi(1); % length of grid entry
        
    end % if ~strcmpi(STYLE,'grid')
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%% Scale the axes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    cla  % clear current axis
    hold on
    h = gca; % uses current axes
    
    % instead of default larger AXHEADFAC
    if squeezefac<0.92 & plotrad-headrad > 0.05  % (size of head in axes)
        AXHEADFAC = 1.05;     % do not leave room for external ears if head cartoon
        % shrunk enough by the 'skirt' option
    end
    
    set(gca,'Xlim',[-rmax rmax]*AXHEADFAC,'Ylim',[-rmax rmax]*AXHEADFAC);
    % specify size of head axes in gca
    
    unsh = (GRID_SCALE+1)/GRID_SCALE; % un-shrink the effects of 'interp' SHADING
    
    %
    %%%%%%%%%%%%%%%%%%%%%%%% Plot grid only %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    if strcmpi(STYLE,'grid')                     % plot grid only
        
        %
        % The goal below is to make the grid cells square - not yet achieved in all cases? -sm
        %
        g1 = size(gridchans,1);
        g2 = size(gridchans,2);
        gmax = max([g1 g2]);
        Xi = linspace(-rmax*g2/gmax,rmax*g2/gmax,g1+1);
        Xi = Xi+rmax/g1; Xi = Xi(1:end-1);
        Yi = linspace(-rmax*g1/gmax,rmax*g1/gmax,g2+1);
        Yi = Yi+rmax/g2; Yi = Yi(1:end-1); Yi = Yi(end:-1:1); % by trial and error!
        %
        %%%%%%%%%%% collect the gridchans values %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        gridvalues = zeros(size(gridchans));
        for j=1:size(gridchans,1)
            for k=1:size(gridchans,2)
                gc = gridchans(j,k);
                if gc > 0
                    gridvalues(j,k) = Values(gc);
                elseif gc < 0
                    gridvalues(j,k) = -Values(gc);
                else
                    gridvalues(j,k) = nan; % not-a-number = no value
                end
            end
        end
        %
        %%%%%%%%%%% reset color limits for grid plot %%%%%%%%%%%%%%%%%%%%%%%%%
        %
        if isstr(MAPLIMITS)
            if strcmp(MAPLIMITS,'maxmin') | strcmp(MAPLIMITS,'minmax')
                amin = min(min(gridvalues(~isnan(gridvalues))));
                amax = max(max(gridvalues(~isnan(gridvalues))));
            elseif strcmp(MAPLIMITS,'absmax')
                % 11/21/2005 Toby edit
                % This should now work as specified. Before it only crashed (using
                % "plotgrid" and "maplimits>absmax" options).
                amax = max(max(abs(gridvalues(~isnan(gridvalues)))));
                amin = -amax;
                %amin = -max(max(abs([amin amax])));
                %amax = max(max(abs([amin amax])));
            else
                error('unknown ''maplimits'' value');
            end
        elseif length(MAPLIMITS) == 2
            amin = MAPLIMITS(1);
            amax = MAPLIMITS(2);
        else
            error('unknown ''maplimits'' value');
        end
        %
        %%%%%%%%%% explicitly compute grid colors, allowing BACKCOLOR  %%%%%%
        %
        gridvalues = 1+floor(cmaplen*(gridvalues-amin)/(amax-amin));
        gridvalues(find(gridvalues == cmaplen+1)) = cmaplen;
        gridcolors = zeros([size(gridvalues),3]);
        for j=1:size(gridchans,1)
            for k=1:size(gridchans,2)
                if ~isnan(gridvalues(j,k))
                    gridcolors(j,k,:) = cmap(gridvalues(j,k),:);
                else
                    if strcmpi(whitebk,'off')
                        gridcolors(j,k,:) = BACKCOLOR; % gridchans == 0 -> background color
                        % This allows the plot to show 'space' between separate sub-grids or strips
                    else % 'on'
                        gridcolors(j,k,:) = [1 1 1]; BACKCOLOR; % gridchans == 0 -> white for printing
                    end
                end
            end
        end
        
        %
        %%%%%%%%%% draw the gridplot image %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        handle=imagesc(Xi,Yi,gridcolors); % plot grid with explicit colors
        axis square
        
        %
        %%%%%%%%%%%%%%%%%%%%%%%% Plot map contours only %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
    elseif strcmp(STYLE,'contour')                     % plot surface contours only
        [cls chs] = contour(Xi,Yi,Zi,CONTOURNUM,'k');
        % for h=chs, set(h,'color',CCOLOR); end
        %
        %%%%%%%%%%%%%%%%%%%%%%%% Else plot map and contours %%%%%%%%%%%%%%%%%%%%%%%%%
        %
    elseif strcmp(STYLE,'both')  % plot interpolated surface and surface contours
        if strcmp(SHADING,'interp')
            tmph = surface(Xi*unsh,Yi*unsh,zeros(size(Zi)),Zi,...
                'EdgeColor','none','FaceColor',SHADING);
        else % SHADING == 'flat'
            tmph = surface(Xi-delta/2,Yi-delta/2,zeros(size(Zi)),Zi,...
                'EdgeColor','none','FaceColor',SHADING);
        end
        if strcmpi(MASKSURF, 'on')
            set(tmph, 'visible', 'off');
            handle = tmph;
        end;
        [cls chs] = contour(Xi,Yi,Zi,CONTOURNUM,'k');
        for h=chs, set(h,'color',CCOLOR); end
        %
        %%%%%%%%%%%%%%%%%%%%%%%% Else plot map only %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
    elseif strcmp(STYLE,'straight') | strcmp(STYLE,'map') % 'straight' was former arg
        
        if strcmp(SHADING,'interp') % 'interp' mode is shifted somehow... but how?
            tmph = surface(Xi*unsh,Yi*unsh,zeros(size(Zi)),Zi,'EdgeColor','none',...
                'FaceColor',SHADING);
        else
            tmph = surface(Xi-delta/2,Yi-delta/2,zeros(size(Zi)),Zi,'EdgeColor','none',...
                'FaceColor',SHADING);
        end
        if strcmpi(MASKSURF, 'on')
            set(tmph, 'visible', 'off');
            handle = tmph;
        end;
        %
        %%%%%%%%%%%%%%%%%% Else fill contours with uniform colors  %%%%%%%%%%%%%%%%%%
        %
    elseif strcmp(STYLE,'fill')
        [cls chs] = contourf(Xi,Yi,Zi,CONTOURNUM,'k');
        
        % for h=chs, set(h,'color',CCOLOR); end
        %     <- 'not line objects.' Why does 'both' work above???
        
    else
        error('Invalid style')
    end
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Set color axis  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    caxis([amin amax]) % set coloraxis
    
else % if STYLE 'blank'
    %
    %%%%%%%%%%%%%%%%%%%%%%% Draw blank head %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    if strcmpi(noplot, 'on')
        if strcmpi(VERBOSE,'on')
            fprintf('topoplot(): no plot requested.\n')
        end
        return;
    end
    cla
    hold on
    
    set(gca,'Xlim',[-rmax rmax]*AXHEADFAC,'Ylim',[-rmax rmax]*AXHEADFAC)
    % pos = get(gca,'position');
    % fprintf('Current axes size %g,%g\n',pos(3),pos(4));
    
    if strcmp(ELECTRODES,'labelpoint') |  strcmp(ELECTRODES,'numpoint')
        text(-0.6,-0.6, ...
            [ int2str(length(Rd)) ' of ' int2str(length(tmpeloc)) ' electrode locations shown']);
        text(-0.6,-0.7, [ 'Click on electrodes to toggle name/number']);
        tl = title('Channel locations');
        set(tl, 'fontweight', 'bold');
    end;
end % STYLE 'blank'

if exist('handle') ~= 1
    handle = gca;
end;

if ~strcmpi(STYLE,'grid')                     % if not plot grid only
    
    %
    %%%%%%%%%%%%%%%%%%% Plot filled ring to mask jagged grid boundary %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    hwidth = HEADRINGWIDTH;                   % width of head ring
    hin  = squeezefac*headrad*(1- hwidth/2);  % inner head ring radius
    
    if strcmp(SHADING,'interp')
        rwidth = BLANKINGRINGWIDTH*1.3;             % width of blanking outer ring
    else
        rwidth = BLANKINGRINGWIDTH;         % width of blanking outer ring
    end
    rin    =  rmax*(1-rwidth/2);              % inner ring radius
    if hin>rin
        rin = hin;                              % dont blank inside the head ring
    end
    
    if strcmp(CONVHULL,'on') %%%%%%%%% mask outside the convex hull of the electrodes %%%%%%%%%
        cnv = convhull(allx,ally);
        cnvfac = round(CIRCGRID/length(cnv)); % spline interpolate the convex hull
        if cnvfac < 1, cnvfac=1; end;
        CIRCGRID = cnvfac*length(cnv);
        
        startangle = atan2(allx(cnv(1)),ally(cnv(1)));
        circ = linspace(0+startangle,2*pi+startangle,CIRCGRID);
        rx = sin(circ);
        ry = cos(circ);
        
        allx = allx(:)';  % make x (elec locations; + to nose) a row vector
        ally = ally(:)';  % make y (elec locations, + to r? ear) a row vector
        erad = sqrt(allx(cnv).^2+ally(cnv).^2);  % convert to polar coordinates
        eang = atan2(allx(cnv),ally(cnv));
        eang = unwrap(eang);
        eradi =spline(linspace(0,1,3*length(cnv)), [erad erad erad], ...
            linspace(0,1,3*length(cnv)*cnvfac));
        eangi =spline(linspace(0,1,3*length(cnv)), [eang+2*pi eang eang-2*pi], ...
            linspace(0,1,3*length(cnv)*cnvfac));
        xx = eradi.*sin(eangi);           % convert back to rect coordinates
        yy = eradi.*cos(eangi);
        yy = yy(CIRCGRID+1:2*CIRCGRID);
        xx = xx(CIRCGRID+1:2*CIRCGRID);
        eangi = eangi(CIRCGRID+1:2*CIRCGRID);
        eradi = eradi(CIRCGRID+1:2*CIRCGRID);
        xx = xx*1.02; yy = yy*1.02;           % extend spline outside electrode marks
        
        splrad = sqrt(xx.^2+yy.^2);           % arc radius of spline points (yy,xx)
        oob = find(splrad >= rin);            %  enforce an upper bound on xx,yy
        xx(oob) = rin*xx(oob)./splrad(oob);   % max radius = rin
        yy(oob) = rin*yy(oob)./splrad(oob);   % max radius = rin
        
        splrad = sqrt(xx.^2+yy.^2);           % arc radius of spline points (yy,xx)
        oob = find(splrad < hin);             % don't let splrad be inside the head cartoon
        xx(oob) = hin*xx(oob)./splrad(oob);   % min radius = hin
        yy(oob) = hin*yy(oob)./splrad(oob);   % min radius = hin
        
        ringy = [[ry(:)' ry(1) ]*(rin+rwidth) yy yy(1)];
        ringx = [[rx(:)' rx(1) ]*(rin+rwidth) xx xx(1)];
        
        ringh2= patch(ringy,ringx,ones(size(ringy)),BACKCOLOR,'edgecolor','none'); hold on
        
        % plot(ry*rmax,rx*rmax,'b') % debugging line
        
    else %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% mask the jagged border around rmax %%%%%%%%%%%%%%%5%%%%%%
        
        circ = linspace(0,2*pi,CIRCGRID);
        rx = sin(circ);
        ry = cos(circ);
        ringx = [[rx(:)' rx(1) ]*(rin+rwidth)  [rx(:)' rx(1)]*rin];
        ringy = [[ry(:)' ry(1) ]*(rin+rwidth)  [ry(:)' ry(1)]*rin];
        
        if ~strcmpi(STYLE,'blank')
            ringh= patch(ringx,ringy,0.01*ones(size(ringx)),BACKCOLOR,'edgecolor','none'); hold on
        end
        % plot(ry*rmax,rx*rmax,'b') % debugging line
    end
    
    %f1= fill(rin*[rx rX],rin*[ry rY],BACKCOLOR,'edgecolor',BACKCOLOR); hold on
    %f2= fill(rin*[rx rX*(1+rwidth)],rin*[ry rY*(1+rwidth)],BACKCOLOR,'edgecolor',BACKCOLOR);
    
    % Former line-style border smoothing - width did not scale with plot
    %  brdr=plot(1.015*cos(circ).*rmax,1.015*sin(circ).*rmax,...      % old line-based method
    %      'color',HEADCOLOR,'Linestyle','-','LineWidth',HLINEWIDTH);    % plot skirt outline
    %  set(brdr,'color',BACKCOLOR,'linewidth',HLINEWIDTH + 4);        % hide the disk edge jaggies
    
    %
    %%%%%%%%%%%%%%%%%%%%%%%%% Plot cartoon head, ears, nose %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    if headrad > 0                         % if cartoon head to be plotted
        %
        %%%%%%%%%%%%%%%%%%% Plot head outline %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        headx = [[rx(:)' rx(1) ]*(hin+hwidth)  [rx(:)' rx(1)]*hin];
        heady = [[ry(:)' ry(1) ]*(hin+hwidth)  [ry(:)' ry(1)]*hin];
        
        if ~isstr(HEADCOLOR) | ~strcmpi(HEADCOLOR,'none')
            ringh= patch(headx,heady,ones(size(headx)),HEADCOLOR,'edgecolor',HEADCOLOR); hold on
        end
        
        % rx = sin(circ); rX = rx(end:-1:1);
        % ry = cos(circ); rY = ry(end:-1:1);
        % for k=2:2:CIRCGRID
        %   rx(k) = rx(k)*(1+hwidth);
        %   ry(k) = ry(k)*(1+hwidth);
        % end
        % f3= fill(hin*[rx rX],hin*[ry rY],HEADCOLOR,'edgecolor',HEADCOLOR); hold on
        % f4= fill(hin*[rx rX*(1+hwidth)],hin*[ry rY*(1+hwidth)],HEADCOLOR,'edgecolor',HEADCOLOR);
        
        % Former line-style head
        %  plot(cos(circ).*squeezefac*headrad,sin(circ).*squeezefac*headrad,...
        %      'color',HEADCOLOR,'Linestyle','-','LineWidth',HLINEWIDTH);    % plot head outline
        
        %
        %%%%%%%%%%%%%%%%%%% Plot ears and nose %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        base  = rmax-.0046;
        basex = 0.18*rmax;                   % nose width
        tip   = 1.15*rmax;
        tiphw = .04*rmax;                    % nose tip half width
        tipr  = .01*rmax;                    % nose tip rounding
        q = .04; % ear lengthening
        EarX  = [.497-.005  .510  .518  .5299 .5419  .54    .547   .532   .510   .489-.005]; % rmax = 0.5
        EarY  = [q+.0555 q+.0775 q+.0783 q+.0746 q+.0555 -.0055 -.0932 -.1313 -.1384 -.1199];
        sf    = headrad/plotrad;                                          % squeeze the model ears and nose
        % by this factor
        if ~isstr(HEADCOLOR) | ~strcmpi(HEADCOLOR,'none')
            plot3([basex;tiphw;0;-tiphw;-basex]*sf,[base;tip-tipr;tip;tip-tipr;base]*sf,...
                2*ones(size([basex;tiphw;0;-tiphw;-basex])),...
                'Color',HEADCOLOR,'LineWidth',HLINEWIDTH);                 % plot nose
            plot3(EarX*sf,EarY*sf,2*ones(size(EarX)),'color',HEADCOLOR,'LineWidth',HLINEWIDTH)    % plot left ear
            plot3(-EarX*sf,EarY*sf,2*ones(size(EarY)),'color',HEADCOLOR,'LineWidth',HLINEWIDTH)   % plot right ear
        end
    end
    
    %
    % %%%%%%%%%%%%%%%%%%% Show electrode information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    plotax = gca;
    axis square                                           % make plotax square
    axis off
    
    pos = get(gca,'position');
    xlm = get(gca,'xlim');
    ylm = get(gca,'ylim');
    % textax = axes('position',pos,'xlim',xlm,'ylim',ylm);  % make new axes so clicking numbers <-> labels
    % will work inside head cartoon patch
    % axes(textax);
    axis square                                           % make textax square
    
    pos = get(gca,'position');
    set(plotax,'position',pos);
    
    xlm = get(gca,'xlim');
    set(plotax,'xlim',xlm);
    
    ylm = get(gca,'ylim');
    set(plotax,'ylim',ylm);                               % copy position and axis limits again
    
    %get(textax,'pos')    % test if equal!
    %get(plotax,'pos')
    %get(textax,'xlim')
    %get(plotax,'xlim')
    %get(textax,'ylim')
    %get(plotax,'ylim')
    
    if isempty(EMARKERSIZE)
        EMARKERSIZE = 10;
        if length(y)>=32
            EMARKERSIZE = 8;
        elseif length(y)>=48
            EMARKERSIZE = 6;
        elseif length(y)>=64
            EMARKERSIZE = 5;
        elseif length(y)>=80
            EMARKERSIZE = 4;
        elseif length(y)>=100
            EMARKERSIZE = 3;
        elseif length(y)>=128
            EMARKERSIZE = 3;
        elseif length(y)>=160
            EMARKERSIZE = 3;
        end
    end
    %
    %%%%%%%%%%%%%%%%%%%%%%%% Mark electrode locations only %%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    ELECTRODE_HEIGHT = 2.1;  % z value for plotting electrode information (above the surf)
    
    if strcmp(ELECTRODES,'on')   % plot electrodes as spots
        if isempty(EMARKER2CHANS)
            hp2 = plot3(y,x,ones(size(x))*ELECTRODE_HEIGHT,...
                EMARKER,'Color',ECOLOR,'markersize',EMARKERSIZE,'linewidth',EMARKERLINEWIDTH);
        else % plot markers for normal chans and EMARKER2CHANS separately
            hp2 = plot3(y(mark1chans),x(mark1chans),ones(size((mark1chans)))*ELECTRODE_HEIGHT,...
                EMARKER,'Color',ECOLOR,'markersize',EMARKERSIZE,'linewidth',EMARKERLINEWIDTH);
            hp2b = plot3(y(mark2chans),x(mark2chans),ones(size((mark2chans)))*ELECTRODE_HEIGHT,...
                EMARKER2,'Color',EMARKER2COLOR,'markerfacecolor',EMARKER2COLOR,'linewidth',EMARKER2LINEWIDTH,'markersize',EMARKERSIZE2);
        end
        %
        %%%%%%%%%%%%%%%%%%%%%%%% Print electrode labels only %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
    elseif strcmp(ELECTRODES,'labels')  % print electrode names (labels)
        for i = 1:size(labels,1)
            text(double(y(i)),double(x(i)),...
                ELECTRODE_HEIGHT,labels(i,:),'HorizontalAlignment','center',...
                'VerticalAlignment','middle','Color',ECOLOR,...
                'FontSize',EFSIZE)
        end
        %
        %%%%%%%%%%%%%%%%%%%%%%%% Mark electrode locations plus labels %%%%%%%%%%%%%%%%%%%
        %
    elseif strcmp(ELECTRODES,'labelpoint')
        if isempty(EMARKER2CHANS)
            hp2 = plot3(y,x,ones(size(x))*ELECTRODE_HEIGHT,...
                EMARKER,'Color',ECOLOR,'markersize',EMARKERSIZE,'linewidth',EMARKERLINEWIDTH);
        else
            hp2 = plot3(y(mark1chans),x(mark1chans),ones(size((mark1chans)))*ELECTRODE_HEIGHT,...
                EMARKER,'Color',ECOLOR,'markersize',EMARKERSIZE,'linewidth',EMARKERLINEWIDTH);
            hp2b = plot3(y(mark2chans),x(mark2chans),ones(size((mark2chans)))*ELECTRODE_HEIGHT,...
                EMARKER2,'Color',EMARKER2COLOR,'markerfacecolor',EMARKER2COLOR,'linewidth',EMARKER2LINEWIDTH,'markersize',EMARKERSIZE2);
        end
        for i = 1:size(labels,1)
            hh(i) = text(double(y(i)+0.01),double(x(i)),...
                ELECTRODE_HEIGHT,labels(i,:),'HorizontalAlignment','left',...
                'VerticalAlignment','middle','Color', ECOLOR,'userdata', num2str(allchansind(i)), ...
                'FontSize',EFSIZE, 'buttondownfcn', ...
                ['tmpstr = get(gco, ''userdata'');'...
                'set(gco, ''userdata'', get(gco, ''string''));' ...
                'set(gco, ''string'', tmpstr); clear tmpstr;'] );
        end
        %
        %%%%%%%%%%%%%%%%%%%%%%% Mark electrode locations plus numbers %%%%%%%%%%%%%%%%%%%
        %
    elseif strcmp(ELECTRODES,'numpoint')
        if isempty(EMARKER2CHANS)
            hp2 = plot3(y,x,ones(size(x))*ELECTRODE_HEIGHT,...
                EMARKER,'Color',ECOLOR,'markersize',EMARKERSIZE,'linewidth',EMARKERLINEWIDTH);
        else
            hp2 = plot3(y(mark1chans),x(mark1chans),ones(size((mark1chans)))*ELECTRODE_HEIGHT,...
                EMARKER,'Color',ECOLOR,'markersize',EMARKERSIZE,'linewidth',EMARKERLINEWIDTH);
            hp2b = plot3(y(mark2chans),x(mark2chans),ones(size((mark2chans)))*ELECTRODE_HEIGHT,...
                EMARKER2,'Color',EMARKER2COLOR,'markerfacecolor',EMARKER2COLOR,'linewidth',EMARKER2LINEWIDTH,'markersize',EMARKERSIZE2);
        end
        for i = 1:size(labels,1)
            hh(i) = text(double(y(i)+0.01),double(x(i)),...
                ELECTRODE_HEIGHT,num2str(allchansind(i)),'HorizontalAlignment','left',...
                'VerticalAlignment','middle','Color', ECOLOR,'userdata', labels(i,:) , ...
                'FontSize',EFSIZE, 'buttondownfcn', ...
                ['tmpstr = get(gco, ''userdata'');'...
                'set(gco, ''userdata'', get(gco, ''string''));' ...
                'set(gco, ''string'', tmpstr); clear tmpstr;'] );
        end
        %
        %%%%%%%%%%%%%%%%%%%%%% Print electrode numbers only %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
    elseif strcmp(ELECTRODES,'numbers')
        for i = 1:size(labels,1)
            text(double(y(i)),double(x(i)),...
                ELECTRODE_HEIGHT,int2str(allchansind(i)),'HorizontalAlignment','center',...
                'VerticalAlignment','middle','Color',ECOLOR,...
                'FontSize',EFSIZE)
        end
        %
        %%%%%%%%%%%%%%%%%%%%%% Mark emarker2 electrodes only  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
    elseif strcmp(ELECTRODES,'off') & ~isempty(EMARKER2CHANS)
        hp2b = plot3(y(mark2chans),x(mark2chans),ones(size((mark2chans)))*ELECTRODE_HEIGHT,...
            EMARKER2,'Color',EMARKER2COLOR,'markerfacecolor',EMARKER2COLOR,'linewidth',EMARKER2LINEWIDTH,'markersize',EMARKERSIZE2);
    end
    %
    %%%%%%%% Mark specified electrode locations with red filled disks  %%%%%%%%%%%%%%%%%%%%%%
    %
    if strcmpi(STYLE,'blank') % if mark-selected-channel-locations mode
        if strcmpi(ELECTRODES,'on') | strcmpi(ELECTRODES,'off')
            for kk = 1:length(plotchans)
                if strcmpi(EMARKER,'.')
                    hp2 = plot3(y(kk),x(kk),ELECTRODE_HEIGHT,EMARKER,'Color', EMARKERCOLOR1CHAN, ...
                        'markersize', EMARKERSIZE1CHAN);
                else
                    hp2 = plot3(y(kk),x(kk),ELECTRODE_HEIGHT,EMARKER,'Color', EMARKERCOLOR1CHAN, ...
                        'markersize', EMARKERSIZE1CHAN);
                end
            end
            hold on
        end
    end
    
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%% Plot dipole(s) on the scalp map  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    if ~isempty(DIPOLE)
        hold on;
        tmp = DIPOLE;
        if isstruct(DIPOLE)
            if ~isfield(tmp,'posxyz')
                error('dipole structure is not an EEG.dipfit.model')
            end
            DIPOLE = [];  % Note: invert x and y from dipplot usage
            DIPOLE(:,1) = -tmp.posxyz(:,2)/DIPSPHERE; % -y -> x
            DIPOLE(:,2) =  tmp.posxyz(:,1)/DIPSPHERE; %  x -> y
            DIPOLE(:,3) = -tmp.momxyz(:,2);
            DIPOLE(:,4) =  tmp.momxyz(:,1);
        else
            DIPOLE(:,1) = -tmp(:,2);                    % same for vector input
            DIPOLE(:,2) =  tmp(:,1);
            DIPOLE(:,3) = -tmp(:,4);
            DIPOLE(:,4) =  tmp(:,3);
        end;
        for index = 1:size(DIPOLE,1)
            if ~any(DIPOLE(index,:))
                DIPOLE(index,:) = [];
            end
        end;
        DIPOLE(:,1:4)   = DIPOLE(:,1:4)*rmax*(rmax/plotrad); % scale radius from 1 -> rmax (0.5)
        DIPOLE(:,3:end) = (DIPOLE(:,3:end))*rmax/100000*(rmax/plotrad);
        if strcmpi(DIPNORM, 'on')
            for index = 1:size(DIPOLE,1)
                DIPOLE(index,3:4) = DIPOLE(index,3:4)/norm(DIPOLE(index,3:end))*0.2;
            end;
        end;
        DIPOLE(:, 3:4) =  DIPORIENT*DIPOLE(:, 3:4)*DIPLEN;
        
        PLOT_DIPOLE=1;
        if sum(DIPOLE(1,3:4).^2) <= 0.00001
            if strcmpi(VERBOSE,'on')
                fprintf('Note: dipole is length 0 - not plotted\n')
            end
            PLOT_DIPOLE = 0;
        end
        if 0 % sum(DIPOLE(1,1:2).^2) > plotrad
            if strcmpi(VERBOSE,'on')
                fprintf('Note: dipole is outside plotting area - not plotted\n')
            end
            PLOT_DIPOLE = 0;
        end
        if PLOT_DIPOLE
            for index = 1:size(DIPOLE,1)
                hh = plot( DIPOLE(index, 1), DIPOLE(index, 2), '.');
                set(hh, 'color', DIPCOLOR, 'markersize', DIPSCALE*30);
                hh = line( [DIPOLE(index, 1) DIPOLE(index, 1)+DIPOLE(index, 3)]', ...
                    [DIPOLE(index, 2) DIPOLE(index, 2)+DIPOLE(index, 4)]');
                set(hh, 'color', DIPCOLOR, 'linewidth', DIPSCALE*30/7);
            end;
        end;
    end;
    
end % if ~ 'gridplot'

%
%%%%%%%%%%%%% Plot axis orientation %%%%%%%%%%%%%%%%%%%%
%
if strcmpi(DRAWAXIS, 'on')
    axes('position', [0 0.85 0.08 0.1]);
    axis off;
    coordend1 = sqrt(-1)*3;
    coordend2 = -3;
    coordend1 = coordend1*exp(sqrt(-1)*rotate);
    coordend2 = coordend2*exp(sqrt(-1)*rotate);
    
    line([5 5+round(real(coordend1))]', [5 5+round(imag(coordend1))]', 'color', 'k');
    line([5 5+round(real(coordend2))]', [5 5+round(imag(coordend2))]', 'color', 'k');
    if round(real(coordend2))<0
        text( 5+round(real(coordend2))*1.2, 5+round(imag(coordend2))*1.2-2, '+Y');
    else text( 5+round(real(coordend2))*1.2, 5+round(imag(coordend2))*1.2, '+Y');
    end;
    if round(real(coordend1))<0
        text( 5+round(real(coordend1))*1.2, 5+round(imag(coordend1))*1.2+1.5, '+X');
    else text( 5+round(real(coordend1))*1.2, 5+round(imag(coordend1))*1.2, '+X');
    end;
    set(gca, 'xlim', [0 10], 'ylim', [0 10]);
end;

%
%%%%%%%%%%%%% Set EEGLAB background color to match head border %%%%%%%%%%%%%%%%%%%%%%%%
%
try,
    icadefs;
    set(gcf, 'color', BACKCOLOR);
catch,
end;

hold off
axis off
return

%=========================================================================
%                       readlocs fundtion
%==========================================================================


    function [eloc, labels, theta, radius, indices] = readlocs( filename, varargin );
        
        if nargin < 1
            help readlocs;
            return;
        end;
        
        % NOTE: To add a new channel format:
        % ----------------------------------
        % 1) Add a new element to the structure 'chanformat' (see 'ADD NEW FORMATS HERE' below):
        % 2)  Enter a format 'type' for the new file format,
        % 3)  Enter a (short) 'typestring' description of the format
        % 4)  Enter a longer format 'description' (possibly multiline, see ex. (1) below)
        % 5)  Enter format file column labels in the 'importformat' field (see ex. (2) below)
        % 6)  Enter the number of header lines to skip (if any) in the 'skipline' field
        % 7)  Document the new channel format in the help message above.
        % 8)  After testing, please send the new version of readloca.m to us
        %       at eeglab@sccn.ucsd.edu with a sample locs file.
        % The 'chanformat' structure is also used (automatically) by the writelocs()
        % and pop_readlocs() functions. You do not need to edit these functions.
        
        chanformat(1).type         = 'polhemus';
        chanformat(1).typestring   = 'Polhemus native .elp file';
        chanformat(1).description  = [ 'Polhemus native coordinate file containing scanned electrode positions. ' ...
            'User must select the direction ' ...
            'for the nose after importing the data file.' ];
        chanformat(1).importformat = 'readelp() function';
        % ---------------------------------------------------------------------------------------------------
        chanformat(2).type         = 'besa';
        chanformat(2).typestring   = 'BESA spherical .elp file';
        chanformat(2).description  = [ 'BESA spherical coordinate file. Note that BESA spherical coordinates ' ...
            'are different from Matlab spherical coordinates' ];
        chanformat(2).skipline     = 0; % some BESA files do not have headers
        chanformat(2).importformat = { 'type' 'labels' 'sph_theta_besa' 'sph_phi_besa' 'sph_radius' };
        % ---------------------------------------------------------------------------------------------------
        chanformat(3).type         = 'xyz';
        chanformat(3).typestring   = 'Matlab .xyz file';
        chanformat(3).description  = [ 'Standard 3-D cartesian coordinate files with electrode labels in ' ...
            'the first column and X, Y, and Z coordinates in columns 2, 3, and 4' ];
        chanformat(3).importformat = { 'channum' '-Y' 'X' 'Z' 'labels'};
        % ---------------------------------------------------------------------------------------------------
        chanformat(4).type         = 'sfp';
        chanformat(4).typestring   = 'BESA or EGI 3-D cartesian .sfp file';
        chanformat(4).description  = [ 'Standard BESA 3-D cartesian coordinate files with electrode labels in ' ...
            'the first column and X, Y, and Z coordinates in columns 2, 3, and 4.' ...
            'Coordinates are re-oriented to fit the EEGLAB standard of having the ' ...
            'nose along the +X axis.' ];
        chanformat(4).importformat = { 'labels' '-Y' 'X' 'Z' };
        chanformat(4).skipline     = 0;
        % ---------------------------------------------------------------------------------------------------
        chanformat(5).type         = 'loc';
        chanformat(5).typestring   = 'EEGLAB polar .loc file';
        chanformat(5).description  = [ 'EEGLAB polar .loc file' ];
        chanformat(5).importformat = { 'channum' 'theta' 'radius' 'labels' };
        % ---------------------------------------------------------------------------------------------------
        chanformat(6).type         = 'sph';
        chanformat(6).typestring   = 'Matlab .sph spherical file';
        chanformat(6).description  = [ 'Standard 3-D spherical coordinate files in Matlab format' ];
        chanformat(6).importformat = { 'channum' 'sph_theta' 'sph_phi' 'labels' };
        % ---------------------------------------------------------------------------------------------------
        chanformat(7).type         = 'asc';
        chanformat(7).typestring   = 'Neuroscan polar .asc file';
        chanformat(7).description  = [ 'Neuroscan polar .asc file, automatically recentered to fit EEGLAB standard' ...
            'of having ''Cz'' at (0,0).' ];
        chanformat(7).importformat = 'readneurolocs';
        % ---------------------------------------------------------------------------------------------------
        chanformat(8).type         = 'dat';
        chanformat(8).typestring   = 'Neuroscan 3-D .dat file';
        chanformat(8).description  = [ 'Neuroscan 3-D cartesian .dat file. Coordinates are re-oriented to fit ' ...
            'the EEGLAB standard of having the nose along the +X axis.' ];
        chanformat(8).importformat = 'readneurolocs';
        % ---------------------------------------------------------------------------------------------------
        chanformat(9).type         = 'elc';
        chanformat(9).typestring   = 'ASA .elc 3-D file';
        chanformat(9).description  = [ 'ASA .elc 3-D coordinate file containing scanned electrode positions. ' ...
            'User must select the direction ' ...
            'for the nose after importing the data file.' ];
        chanformat(9).importformat = 'readeetraklocs';
        % ---------------------------------------------------------------------------------------------------
        chanformat(10).type         = 'chanedit';
        chanformat(10).typestring   = 'EEGLAB complete 3-D file';
        chanformat(10).description  = [ 'EEGLAB file containing polar, cartesian 3-D, and spherical 3-D ' ...
            'electrode locations.' ];
        chanformat(10).importformat = { 'channum' 'labels'  'theta' 'radius' 'X' 'Y' 'Z' 'sph_theta' 'sph_phi' ...
            'sph_radius' 'type' };
        chanformat(10).skipline     = 1;
        % ---------------------------------------------------------------------------------------------------
        chanformat(11).type         = 'custom';
        chanformat(11).typestring   = 'Custom file format';
        chanformat(11).description  = 'Custom ASCII file format where user can define content for each file columns.';
        chanformat(11).importformat = '';
        % ---------------------------------------------------------------------------------------------------
        % ----- ADD MORE FORMATS HERE -----------------------------------------------------------------------
        % ---------------------------------------------------------------------------------------------------
        
        listcolformat = { 'labels' 'channum' 'theta' 'radius' 'sph_theta' 'sph_phi' ...
            'sph_radius' 'sph_theta_besa' 'sph_phi_besa' 'gain' 'calib' 'type' ...
            'X' 'Y' 'Z' '-X' '-Y' '-Z' 'custom1' 'custom2' 'custom3' 'custom4' 'ignore' 'not def' };
        
        % ----------------------------------
        % special mode for getting the info
        % ----------------------------------
        if isstr(filename) & strcmp(filename, 'getinfos')
            eloc = chanformat;
            labels = listcolformat;
            return;
        end;
        
        g = finputcheck( varargin, ...
            { 'filetype'	   'string'  {}                 '';
            'importmode'  'string'  { 'eeglab' 'native' } 'eeglab';
            'defaultelp'  'string'  { 'besa'   'polhemus' } 'polhemus';
            'skiplines'   'integer' [0 Inf] 			[];
            'elecind'     'integer' [1 Inf]	    	[];
            'format'	   'cell'	 []					{} }, 'readlocs');
        if isstr(g), error(g); end;
        
        if isstr(filename)
            
            % format auto detection
            % --------------------
            if strcmpi(g.filetype, 'autodetect'), g.filetype = ''; end;
            g.filetype = strtok(g.filetype);
            periods = find(filename == '.');
            fileextension = filename(periods(end)+1:end);
            g.filetype = lower(g.filetype);
            if isempty(g.filetype)
                switch lower(fileextension),
                    case {'loc' 'locs' }, g.filetype = 'loc';
                    case 'xyz', g.filetype = 'xyz';
                        fprintf( [ 'WARNING: Matlab Cartesian coord. file extension (".xyz") detected.\n' ...
                            'If importing EGI Cartesian coords, force type "sfp" instead.\n'] );
                    case 'sph', g.filetype = 'sph';
                    case 'ced', g.filetype = 'chanedit';
                    case 'elp', g.filetype = g.defaultelp;
                    case 'asc', g.filetype = 'asc';
                    case 'dat', g.filetype = 'dat';
                    case 'elc', g.filetype = 'elc';
                    case 'eps', g.filetype = 'besa';
                    case 'sfp', g.filetype = 'sfp';
                    otherwise, g.filetype =  '';
                end;
                fprintf('readlocs(): ''%s'' format assumed from file extension\n', g.filetype);
            else
                if strcmpi(g.filetype, 'locs'),  g.filetype = 'loc'; end
                if strcmpi(g.filetype, 'eloc'),  g.filetype = 'loc'; end
            end;
            
            % assign format from filetype
            % ---------------------------
            if ~isempty(g.filetype) & ~strcmpi(g.filetype, 'custom') ...
                    & ~strcmpi(g.filetype, 'asc') & ~strcmpi(g.filetype, 'elc') & ~strcmpi(g.filetype, 'dat')
                indexformat = strmatch(lower(g.filetype), { chanformat.type }, 'exact');
                g.format = chanformat(indexformat).importformat;
                if isempty(g.skiplines)
                    g.skiplines = chanformat(indexformat).skipline;
                end;
                if isempty(g.filetype)
                    error( ['readlocs() error: The filetype cannot be detected from the \n' ...
                        '                  file extension, and custom format not specified']);
                end;
            end;
            
            % import file
            % -----------
            if strcmp(g.filetype, 'asc') | strcmp(g.filetype, 'dat')
                eloc = readneurolocs( filename );
                eloc = rmfield(eloc, 'sph_theta'); % for the conversion below
                eloc = rmfield(eloc, 'sph_theta_besa'); % for the conversion below
                if isfield(eloc, 'type')
                    for index = 1:length(eloc)
                        type = eloc(index).type;
                        if type == 69,     eloc(index).type = 'EEG';
                        elseif type == 88, eloc(index).type = 'REF';
                        elseif type >= 76 & type <= 82, eloc(index).type = 'FID';
                        else eloc(index).type = num2str(eloc(index).type);
                        end;
                    end;
                end;
            elseif strcmp(g.filetype, 'elc')
                eloc = readeetraklocs( filename );
                %eloc = read_asa_elc( filename ); % from fieldtrip
                %eloc = struct('labels', eloc.label, 'X', mattocell(eloc.pnt(:,1)'), 'Y', ...
                %                        mattocell(eloc.pnt(:,2)'), 'Z', mattocell(eloc.pnt(:,3)'));
                eloc = convertlocs(eloc, 'cart2all');
                eloc = rmfield(eloc, 'sph_theta'); % for the conversion below
                eloc = rmfield(eloc, 'sph_theta_besa'); % for the conversion below
            elseif strcmp(lower(g.filetype(1:end-1)), 'polhemus') | ...
                    strcmp(g.filetype, 'polhemus')
                try,
                    [eloc labels X Y Z]= readelp( filename );
                    if strcmp(g.filetype, 'polhemusy')
                        tmp = X; X = Y; Y = tmp;
                    end;
                    for index = 1:length( eloc )
                        eloc(index).X = X(index);
                        eloc(index).Y = Y(index);
                        eloc(index).Z = Z(index);
                    end;
                catch,
                    disp('readlocs(): Could not read Polhemus coords. Trying to read BESA .elp file.');
                    [eloc, labels, theta, radius, indices] = readlocs( filename, 'defaultelp', 'besa', varargin{:} );
                end;
            else
                % importing file
                % --------------
                if isempty(g.skiplines), g.skiplines = 0; end;
                array = load_file_or_array( filename, g.skiplines);
                if size(array,2) < length(g.format)
                    fprintf(['readlocs() warning: Fewer columns in the input than expected.\n' ...
                        '                    See >> help readlocs\n']);
                elseif size(array,2) > length(g.format)
                    fprintf(['readlocs() warning: More columns in the input than expected.\n' ...
                        '                    See >> help readlocs\n']);
                end;
                
                % removing lines BESA
                % -------------------
                if isempty(array{1,2})
                    disp('BESA header detected, skipping three lines...');
                    array = load_file_or_array( filename, g.skiplines-1);
                    if isempty(array{1,2})
                        array = load_file_or_array( filename, g.skiplines-1);
                    end;
                end;
                
                % removing comments and empty lines
                % ---------------------------------
                indexbeg = 1;
                while isempty(array{indexbeg,1}) | ...
                        (isstr(array{indexbeg,1}) & array{indexbeg,1}(1) == '%' )
                    indexbeg = indexbeg+1;
                end;
                array = array(indexbeg:end,:);
                
                % converting file
                % ---------------
                for indexcol = 1:min(size(array,2), length(g.format))
                    [str mult] = checkformat(g.format{indexcol});
                    for indexrow = 1:size( array, 1)
                        if mult ~= 1
                            eval ( [ 'eloc(indexrow).'  str '= -array{indexrow, indexcol};' ]);
                        else
                            eval ( [ 'eloc(indexrow).'  str '= array{indexrow, indexcol};' ]);
                        end;
                    end;
                end;
            end;
            
            % handling BESA coordinates
            % -------------------------
            if isfield(eloc, 'sph_theta_besa')
                if isfield(eloc, 'type')
                    if isnumeric(eloc(1).type)
                        disp('BESA format detected ( Theta | Phi )');
                        for index = 1:length(eloc)
                            eloc(index).sph_phi_besa   = eloc(index).labels;
                            eloc(index).sph_theta_besa = eloc(index).type;
                            eloc(index).labels         = '';
                            eloc(index).type           = '';
                        end;
                        eloc = rmfield(eloc, 'labels');
                    end;
                end;
                if isfield(eloc, 'labels')
                    if isnumeric(eloc(1).labels)
                        disp('BESA format detected ( Elec | Theta | Phi )');
                        for index = 1:length(eloc)
                            eloc(index).sph_phi_besa   = eloc(index).sph_theta_besa;
                            eloc(index).sph_theta_besa = eloc(index).labels;
                            eloc(index).labels         = eloc(index).type;
                            eloc(index).type           = '';
                            eloc(index).radius         = 1;
                        end;
                    end;
                end;
                
                try
                    eloc = convertlocs(eloc, 'sphbesa2all');
                    eloc = convertlocs(eloc, 'topo2all'); % problem with some EGI files (not BESA files)
                catch, disp('Warning: coordinate conversion failed'); end;
                fprintf('Readlocs: BESA spherical coords. converted, now deleting BESA fields\n');
                fprintf('          to avoid confusion (these fields can be exported, though)\n');
                eloc = rmfield(eloc, 'sph_phi_besa');
                eloc = rmfield(eloc, 'sph_theta_besa');
                
                % converting XYZ coordinates to polar
                % -----------------------------------
            elseif isfield(eloc, 'sph_theta')
                try
                    eloc = convertlocs(eloc, 'sph2all');
                catch, disp('Warning: coordinate conversion failed'); end;
            elseif isfield(eloc, 'X')
                try
                    eloc = convertlocs(eloc, 'cart2all');
                catch, disp('Warning: coordinate conversion failed'); end;
            else
                try
                    eloc = convertlocs(eloc, 'topo2all');
                catch, disp('Warning: coordinate conversion failed'); end;
            end;
            
            % inserting labels if no labels
            % -----------------------------
            if ~isfield(eloc, 'labels')
                fprintf('readlocs(): Inserting electrode labels automatically.\n');
                for index = 1:length(eloc)
                    eloc(index).labels = [ 'E' int2str(index) ];
                end;
            else
                % remove trailing '.'
                for index = 1:length(eloc)
                    if isstr(eloc(index).labels)
                        tmpdots = find( eloc(index).labels == '.' );
                        eloc(index).labels(tmpdots) = [];
                    end;
                end;
            end;
            
            % resorting electrodes if number not-sorted
            % -----------------------------------------
            if isfield(eloc, 'channum')
                if ~isnumeric(eloc(1).channum)
                    error('Channel numbers must be numeric');
                end;
                allchannum = [ eloc.channum ];
                if any( sort(allchannum) ~= allchannum )
                    fprintf('readlocs(): Re-sorting channel numbers based on ''channum'' column indices\n');
                    [tmp newindices] = sort(allchannum);
                    eloc = eloc(newindices);
                end;
                eloc = rmfield(eloc, 'channum');
            end;
        else
            if isstruct(filename)
                eloc = filename;
            else
                disp('readlocs(): input variable must be a string or a structure');
            end;
        end;
        if ~isempty(g.elecind)
            eloc = eloc(g.elecind);
        end;
        if nargout > 2
            tmptheta          = { eloc.theta }; % check which channels have (polar) coordinates set
            indices           = find(~cellfun('isempty', tmptheta));
            tmpx              = { eloc.X }; % check which channels have (polar) coordinates set
            indices           = intersect(find(~cellfun('isempty', tmpx)), indices);
            indices           = sort(indices);
            
            indbad            = setdiff(1:length(eloc), indices);
            tmptheta(indbad)  = { NaN };
            theta             = [ tmptheta{:} ];
        end;
        if nargout > 3
            tmprad            = { eloc.radius };
            tmprad(indbad)    = { NaN };
            radius            = [ tmprad{:} ];
        end;
        %tmpnum = find(~cellfun('isclass', { eloc.labels }, 'char'));
        %disp('Converting channel labels to string');
        for index = 1:length(eloc)
            if ~isstr(eloc(index).labels)
                eloc(index).labels = int2str(eloc(index).labels);
            end;
        end;
        labels = { eloc.labels };
        if isfield(eloc, 'ignore')
            eloc = rmfield(eloc, 'ignore');
        end;
        
        % process fiducials if any
        % ------------------------
        fidnames = { 'nz' 'lpa' 'rpa' };
        for index = 1:length(fidnames)
            ind = strmatch(fidnames{index}, lower(labels), 'exact');
            if ~isempty(ind), eloc(ind).type = 'FID'; end;
        end;
        
        return;
        
        % interpret the variable name
        % ---------------------------
        
        function array = load_file_or_array( varname, skiplines );
            if isempty(skiplines),
                skiplines = 0;
            end;
            if exist( varname ) == 2
                array = loadtxt(varname,'verbose','off','skipline',skiplines);
            else % variable in the global workspace
                % --------------------------
                try, array = evalin('base', varname);
                catch, error('readlocs(): cannot find the named file or variable, check syntax');
                end;
            end;
            return;
            
            
            function array = loadtxt( filename, varargin );
                
                if nargin < 1
                    help loadtxt;
                    return;
                end;
                if ~isempty(varargin)
                    try, g = struct(varargin{:});
                    catch, disp('Wrong syntax in function arguments'); return; end;
                else
                    g = [];
                end;
                
                g = finputcheck( varargin, { 'convert'   'string'   { 'on' 'off' 'force' }   'on';
                    'skipline'  'integer'  [0 Inf]          0;
                    'verbose'   'string'   { 'on' 'off' }   'on';
                    'delim'     { 'integer' 'string' } []               [9 32];
                    'nlines'    'integer'  []               Inf });
                if isstr(g), error(g); end;
                g.convert = lower(g.convert);
                g.verbose = lower(g.verbose);
                g.delim = char(g.delim);
                
                % open the file
                % -------------
                if exist(filename) ~=2, error( ['file ' filename ' not found'] ); end;
                fid=fopen(filename,'r','ieee-le');
                if fid<0, error( ['file ' filename ' found but error while opening file'] ); end;
                
                index = 0;
                while index < abs(g.skipline)
                    tmpline = fgetl(fid);
                    if g.skipline > 0 | ~isempty(tmpline)
                        index = index + 1;
                    end;
                end; % skip lines ---------
                
                inputline = fgetl(fid);
                linenb = 1;
                if strcmp(g.verbose, 'on'), fprintf('Reading file (lines): '); end;
                while isempty(inputline) | inputline~=-1
                    colnb = 1;
                    if ~isempty(inputline)
                        switch g.convert
                            case 'off',
                                while ~isempty(deblank(inputline))
                                    % 07/29/04 Petr Janata added following line to
                                    % mitigate problem of strtok ignoring leading
                                    % delimiters and deblanking residue in the event
                                    % of only space existing between delimiters
                                    inputline = strrep(inputline,[g.delim g.delim],[g.delim ' ' g.delim]);
                                    
                                    [array{linenb, colnb} inputline] = strtok(inputline, g.delim);
                                    colnb = colnb+1;
                                end;
                            case 'on',
                                while ~isempty(deblank(inputline))
                                    [tmp inputline] = mystrtok(inputline, g.delim);
                                    if ~isempty(tmp) & tmp(1) > 43 & tmp(1) < 59, tmp2 = str2num(tmp);
                                    else tmp2 = []; end;
                                    if isempty( tmp2 )  , array{linenb, colnb} = tmp;
                                    else                  array{linenb, colnb} = tmp2;
                                    end;
                                    colnb = colnb+1;
                                end;
                            case 'force',
                                while ~isempty(deblank(inputline))
                                    [tmp inputline] = mystrtok(inputline, g.delim);
                                    array{linenb, colnb} = str2double( tmp );
                                    colnb = colnb+1;
                                end;
                            otherwise, error('Unrecognized conversion option');
                        end;
                        linenb = linenb +1;
                    end;
                    inputline = fgetl(fid);
                    if linenb > g.nlines
                        inputline = -1;
                    end;
                    if ~mod(linenb,10) & strcmp(g.verbose, 'on'), fprintf('%d ', linenb); end;
                end;
                if strcmp(g.verbose, 'on'),  fprintf('%d\n', linenb-1); end;
                if strcmp(g.convert, 'force'), array = [ array{:} ]; end;
                fclose(fid);
                
                % problem strtok do not consider tabulation
                % -----------------------------------------
                function [str, strout] = mystrtok(strin, delim);
                    if delim == 9 % tab
                        if length(strin) > 1 & strin(1) == 9 & strin(2) == 9
                            str = '';
                            strout = strin(2:end);
                        else
                            [str, strout] = strtok(strin, delim);
                        end;
                    else
                        [str, strout] = strtok(strin, delim);
                    end;
                    
                    % check field format
                    % ------------------
                    function [str, mult] = checkformat(str)
                        mult = 1;
                        if strcmpi(str, 'labels'),         str = lower(str); return; end;
                        if strcmpi(str, 'channum'),        str = lower(str); return; end;
                        if strcmpi(str, 'theta'),          str = lower(str); return; end;
                        if strcmpi(str, 'radius'),         str = lower(str); return; end;
                        if strcmpi(str, 'ignore'),         str = lower(str); return; end;
                        if strcmpi(str, 'sph_theta'),      str = lower(str); return; end;
                        if strcmpi(str, 'sph_phi'),        str = lower(str); return; end;
                        if strcmpi(str, 'sph_radius'),     str = lower(str); return; end;
                        if strcmpi(str, 'sph_theta_besa'), str = lower(str); return; end;
                        if strcmpi(str, 'sph_phi_besa'),   str = lower(str); return; end;
                        if strcmpi(str, 'gain'),           str = lower(str); return; end;
                        if strcmpi(str, 'calib'),          str = lower(str); return; end;
                        if strcmpi(str, 'type') ,          str = lower(str); return; end;
                        if strcmpi(str, 'X'),              str = upper(str); return; end;
                        if strcmpi(str, 'Y'),              str = upper(str); return; end;
                        if strcmpi(str, 'Z'),              str = upper(str); return; end;
                        if strcmpi(str, '-X'),             str = upper(str(2:end)); mult = -1; return; end;
                        if strcmpi(str, '-Y'),             str = upper(str(2:end)); mult = -1; return; end;
                        if strcmpi(str, '-Z'),             str = upper(str(2:end)); mult = -1; return; end;
                        if strcmpi(str, 'custom1'), return; end;
                        if strcmpi(str, 'custom2'), return; end;
                        if strcmpi(str, 'custom3'), return; end;
                        if strcmpi(str, 'custom4'), return; end;
                        error(['readlocs(): undefined field ''' str '''']);
                        
                        
                        
                        function chans = convertlocs(chans, command, varargin);
                            
                            if nargin < 1
                                help convertlocs;
                                return;
                            end;
                            
                            if nargin < 2
                                command = 'auto';
                            end;
                            if nargin == 4 & strcmpi(varargin{2}, 'on')
                                verbose = 1;
                            else
                                verbose = 0; % off
                            end;
                            
                            % test if value exists for default
                            % --------------------------------
                            if strcmp(command, 'auto')
                                if isfield(chans, 'X') & ~isempty(chans(1).X)
                                    command = 'cart2all';
                                    if verbose
                                        disp('Make all coordinate frames uniform using Cartesian coords');
                                    end;
                                else
                                    if isfield(chans, 'sph_theta') & ~isempty(chans(1).sph_theta)
                                        command = 'sph2all';
                                        if verbose
                                            disp('Make all coordinate frames uniform using spherical coords');
                                        end;
                                    else
                                        if isfield(chans, 'sph_theta_besa') & ~isempty(chans(1).sph_theta_besa)
                                            command = 'sphbesa2all';
                                            if verbose
                                                disp('Make all coordinate frames uniform using BESA spherical coords');
                                            end;
                                        else
                                            command = 'topo2all';
                                            if verbose
                                                disp('Make all coordinate frames uniform using polar coords');
                                            end;
                                        end;
                                    end;
                                end;
                            end;
                            
                            % convert
                            % -------
                            switch command
                                case 'topo2sph',
                                    theta  = {chans.theta};
                                    radius = {chans.radius};
                                    indices = find(~cellfun('isempty', theta));
                                    [sph_phi sph_theta] = topo2sph( [ [ theta{indices} ]' [ radius{indices}]' ] );
                                    if verbose
                                        disp('Warning: electrodes forced to lie on a sphere for polar to 3-D conversion');
                                    end;
                                    for index = 1:length(indices)
                                        chans(indices(index)).sph_theta  = sph_theta(index);
                                        chans(indices(index)).sph_phi    = sph_phi  (index);
                                    end;
                                    if isfield(chans, 'sph_radius'),
                                        meanrad = mean([ chans(indices).sph_radius ]);
                                        if isempty(meanrad), meanrad = 1; end;
                                    else
                                        meanrad = 1;
                                    end;
                                    sph_radius(1:length(indices)) = {meanrad};
                                case 'topo2sphbesa',
                                    chans = convertlocs(chans, 'topo2sph', varargin{:}); % search for spherical coords
                                    chans = convertlocs(chans, 'sph2sphbesa', varargin{:}); % search for spherical coords
                                case 'topo2cart'
                                    chans = convertlocs(chans, 'topo2sph', varargin{:}); % search for spherical coords
                                    if verbose
                                        disp('Warning: spherical coordinates automatically updated');
                                    end;
                                    chans = convertlocs(chans, 'sph2cart', varargin{:}); % search for spherical coords
                                case 'topo2all',
                                    chans = convertlocs(chans, 'topo2sph', varargin{:}); % search for spherical coords
                                    chans = convertlocs(chans, 'sph2sphbesa', varargin{:}); % search for spherical coords
                                    chans = convertlocs(chans, 'sph2cart', varargin{:}); % search for spherical coords
                                case 'sph2cart',
                                    sph_theta  = {chans.sph_theta};
                                    sph_phi    = {chans.sph_phi};
                                    indices = find(~cellfun('isempty', sph_theta));
                                    if ~isfield(chans, 'sph_radius'), sph_radius(1:length(indices)) = {1};
                                    else                              sph_radius = {chans.sph_radius};
                                    end;
                                    inde = find(cellfun('isempty', sph_radius));
                                    if ~isempty(inde)
                                        meanrad = mean( [ sph_radius{:} ]);
                                        sph_radius(inde) = { meanrad };
                                    end;
                                    [x y z] = sph2cart([ sph_theta{indices} ]'/180*pi, [ sph_phi{indices} ]'/180*pi, [ sph_radius{indices} ]');
                                    for index = 1:length(indices)
                                        chans(indices(index)).X = x(index);
                                        chans(indices(index)).Y = y(index);
                                        chans(indices(index)).Z = z(index);
                                    end;
                                case 'sph2topo',
                                    if verbose
                                        % disp('Warning: all radii constrained to one for spherical to topo transformation');
                                    end;
                                    sph_theta  = {chans.sph_theta};
                                    sph_phi    = {chans.sph_phi};
                                    indices = find(~cellfun('isempty', sph_theta));
                                    [chan_num,angle,radius] = sph2topo([ ones(length(indices),1)  [ sph_phi{indices} ]' [ sph_theta{indices} ]' ], 1, 2); % using method 2
                                    for index = 1:length(indices)
                                        chans(indices(index)).theta  = angle(index);
                                        chans(indices(index)).radius = radius(index);
                                        if ~isfield(chans, 'sph_radius') | isempty(chans(indices(index)).sph_radius)
                                            chans(indices(index)).sph_radius = 1;
                                        end;
                                    end;
                                case 'sph2sphbesa',
                                    % using polar coordinates
                                    sph_theta  = {chans.sph_theta};
                                    sph_phi    = {chans.sph_phi};
                                    indices = find(~cellfun('isempty', sph_theta));
                                    [chan_num,angle,radius] = sph2topo([ones(length(indices),1)  [ sph_phi{indices} ]' [ sph_theta{indices} ]' ], 1, 2);
                                    [sph_theta_besa sph_phi_besa] = topo2sph([angle radius], 1, 1);
                                    for index = 1:length(indices)
                                        chans(indices(index)).sph_theta_besa  = sph_theta_besa(index);
                                        chans(indices(index)).sph_phi_besa    = sph_phi_besa(index);
                                    end;
                                case 'sph2all',
                                    chans = convertlocs(chans, 'sph2topo', varargin{:}); % search for spherical coords
                                    chans = convertlocs(chans, 'sph2sphbesa', varargin{:}); % search for spherical coords
                                    chans = convertlocs(chans, 'sph2cart', varargin{:}); % search for spherical coords
                                case 'sphbesa2sph',
                                    % using polar coordinates
                                    sph_theta_besa  = {chans.sph_theta_besa};
                                    sph_phi_besa    = {chans.sph_phi_besa};
                                    indices = find(~cellfun('isempty', sph_theta_besa));
                                    [chan_num,angle,radius] = sph2topo([ones(length(indices),1)  [ sph_theta_besa{indices} ]' [ sph_phi_besa{indices} ]' ], 1, 1);
                                    %for index = 1:length(chans)
                                    %   chans(indices(index)).theta  = angle(index);
                                    %   chans(indices(index)).radius = radius(index);
                                    %   chans(indices(index)).labels = int2str(index);
                                    %end;
                                    %figure; topoplot([],chans, 'style', 'blank', 'electrodes', 'labelpoint');
                                    
                                    [sph_phi sph_theta] = topo2sph([angle radius], 2);
                                    for index = 1:length(indices)
                                        chans(indices(index)).sph_theta  = sph_theta(index);
                                        chans(indices(index)).sph_phi    = sph_phi  (index);
                                    end;
                                case 'sphbesa2topo',
                                    chans = convertlocs(chans, 'sphbesa2sph', varargin{:}); % search for spherical coords
                                    chans = convertlocs(chans, 'sph2topo', varargin{:}); % search for spherical coords
                                case 'sphbesa2cart',
                                    chans = convertlocs(chans, 'sphbesa2sph', varargin{:}); % search for spherical coords
                                    chans = convertlocs(chans, 'sph2cart', varargin{:}); % search for spherical coords
                                case 'sphbesa2all',
                                    chans = convertlocs(chans, 'sphbesa2sph', varargin{:}); % search for spherical coords
                                    chans = convertlocs(chans, 'sph2all', varargin{:}); % search for spherical coords
                                case 'cart2topo',
                                    chans = convertlocs(chans, 'cart2sph', varargin{:}); % search for spherical coords
                                    chans = convertlocs(chans, 'sph2topo', varargin{:}); % search for spherical coords
                                case 'cart2sphbesa',
                                    chans = convertlocs(chans, 'cart2sph', varargin{:}); % search for spherical coords
                                    chans = convertlocs(chans, 'sph2sphbesa', varargin{:}); % search for spherical coords
                                case 'cart2sph',
                                    if verbose
                                        disp('WARNING: If XYZ center has not been optimized, optimize it using Edit > Channel Locations');
                                    end;
                                    X  = {chans.X};
                                    Y  = {chans.Y};
                                    Z  = {chans.Z};
                                    indices = find(~cellfun('isempty', X));
                                    [th phi radius] = cart2sph( [ X{indices} ], [ Y{indices} ], [ Z{indices} ]);
                                    for index = 1:length(indices)
                                        chans(indices(index)).sph_theta     = th(index)/pi*180;
                                        chans(indices(index)).sph_phi       = phi(index)/pi*180;
                                        chans(indices(index)).sph_radius    = radius(index);
                                    end;
                                case 'cart2all',
                                    chans = convertlocs(chans, 'cart2sph', varargin{:}); % search for spherical coords
                                    chans = convertlocs(chans, 'sph2all', varargin{:}); % search for spherical coords
                            end;
                            
                            
                            
                            function g = fieldtest( fieldname, fieldtype, fieldval, tmpval, callfunc );
                                NAME = 1;
                                TYPE = 2;
                                VALS = 3;
                                DEF  = 4;
                                SIZE = 5;
                                g = [];
                                
                                switch fieldtype
                                    case { 'integer' 'real' 'boolean' 'float' },
                                        if ~isnumeric(tmpval)
                                            g = [ callfunc 'error: argument ''' fieldname ''' must be numeric' ]; return;
                                        end;
                                        if strcmpi(fieldtype, 'boolean')
                                            if tmpval ~=0 & tmpval ~= 1
                                                g = [ callfunc 'error: argument ''' fieldname ''' must be 0 or 1' ]; return;
                                            end;
                                        else
                                            if strcmpi(fieldtype, 'integer')
                                                if ~isempty(fieldval)
                                                    if (isnan(tmpval) & ~any(isnan(fieldval))) ...
                                                            & (~ismember(tmpval, fieldval))
                                                        g = [ callfunc 'error: wrong value for argument ''' fieldname '''' ]; return;
                                                    end;
                                                end;
                                            else % real or float
                                                if ~isempty(fieldval)
                                                    if tmpval < fieldval(1) | tmpval > fieldval(2)
                                                        g = [ callfunc 'error: value out of range for argument ''' fieldname '''' ]; return;
                                                    end;
                                                end;
                                            end;
                                        end;
                                        
                                        
                                    case 'string'
                                        if ~isstr(tmpval)
                                            g = [ callfunc 'error: argument ''' fieldname ''' must be a string' ]; return;
                                        end;
                                        if ~isempty(fieldval)
                                            if isempty(strmatch(lower(tmpval), lower(fieldval), 'exact'))
                                                g = [ callfunc 'error: wrong value for argument ''' fieldname '''' ]; return;
                                            end;
                                        end;
                                        
                                        
                                    case 'cell'
                                        if ~iscell(tmpval)
                                            g = [ callfunc 'error: argument ''' fieldname ''' must be a cell array' ]; return;
                                        end;
                                        
                                        
                                    case 'struct'
                                        if ~isstruct(tmpval)
                                            g = [ callfunc 'error: argument ''' fieldname ''' must be a structure' ]; return;
                                        end;
                                        
                                        
                                    case '';
                                    otherwise, error([ 'finputcheck error: unrecognized type ''' fieldname '''' ]);
                                end;
                                
                                % remove duplicates in the list of parameters
                                % -------------------------------------------
                                function cella = removedup(cella)
                                    % make sure if all the values passed to unique() are strings, if not, exist
                                    %try
                                    [tmp indices] = unique(cella(1:2:end));
                                    if length(tmp) ~= length(cella)/2
                                        fprintf('Note: duplicate ''key'', ''val'' parameter(s), keeping the last one(s)\n');
                                    end;
                                    cella = cella(sort(union(indices*2-1, indices*2)));
                                    
                                    function [c, h] = topo2sph(eloc_locs,eloc_angles, method, unshrink)
                                        
                                        MAXCHANS = 1024;
                                        
                                        if nargin < 1
                                            help topo2sph;
                                            return;
                                        end;
                                        if nargin > 1 & ~isstr(eloc_angles)
                                            if nargin > 2
                                                unshrink = method;
                                            end;
                                            method = eloc_angles;
                                        else
                                            method = 2;
                                        end;
                                        
                                        if isstr(eloc_locs)
                                            fid = fopen(eloc_locs);
                                            if fid<1,
                                                fprintf('topo2sph()^G: cannot open eloc_loc file (%s)\n',eloc_locs)
                                                return
                                            end
                                            E = fscanf(fid,'%d %f %f  %s',[7 MAXCHANS]);
                                            E = E';
                                            fclose(fid);
                                        else
                                            E = eloc_locs;
                                            E = [ ones(size(E,1),1) E ];
                                        end;
                                        
                                        if nargin > 1 & isstr(eloc_angles)
                                            if exist(eloc_angles)==2,
                                                fprintf('topo2sph: eloc_angles file (%s) already exists and will be erased.\n',eloc_angles);
                                            end
                                            
                                            fid = fopen(eloc_angles,'a');
                                            if fid<1,
                                                fprintf('topo2sph()^G: cannot open eloc_angles file (%s)\n',eloc_angles)
                                                return
                                            end
                                        end;
                                        
                                        if method == 2
                                            t = E(:,2); % theta
                                            r = E(:,3); % radius
                                            h = -t;  % horizontal rotation
                                            c = (0.5-r)*180;
                                        else
                                            for e=1:size(E,1)
                                                % (t,r) -> (c,h)
                                                
                                                t = E(e,2); % theta
                                                r = E(e,3); % radius
                                                r = r*unshrink;
                                                if t>=0
                                                    h(e) = 90-t; % horizontal rotation
                                                else
                                                    h(e) = -(90+t);
                                                end
                                                if t~=0
                                                    c(e) = sign(t)*180*r; % coronal rotation
                                                else
                                                    c(e) = 180*r;
                                                end
                                            end;
                                            t = t';
                                            r = r';
                                        end;
                                        
                                        for e=1:size(E,1)
                                            if nargin > 1 & isstr(eloc_angles)
                                                chan = E(e,4:7);
                                                fprintf('%d	%g	%g	%s\n',E(e,1),c(e),h(e),chan);
                                                fprintf(fid,'%d	%g	%g	%s\n',E(e,1),c(e),h(e),chan);
                                            end;
                                        end
                                        
                                        
                                        function [g, varargnew] = finputcheck( vararg, fieldlist, callfunc, mode )
                                            
                                            if nargin < 2
                                                help finputcheck;
                                                return;
                                            end;
                                            if nargin < 3
                                                callfunc = '';
                                            else
                                                callfunc = [callfunc ' ' ];
                                            end;
                                            if nargin < 4
                                                mode = 'do not ignore';
                                            end;
                                            NAME = 1;
                                            TYPE = 2;
                                            VALS = 3;
                                            DEF  = 4;
                                            SIZE = 5;
                                            
                                            varargnew = {};
                                            % create structure
                                            % ----------------
                                            if ~isempty(vararg)
                                                for index=1:length(vararg)
                                                    if iscell(vararg{index})
                                                        vararg{index} = {vararg{index}};
                                                    end;
                                                end;
                                                try
                                                    g = struct(vararg{:});
                                                catch
                                                    vararg = removedup(vararg);
                                                    try,
                                                        g = struct(vararg{:});
                                                    catch
                                                        g = [ callfunc 'error: bad ''key'', ''val'' sequence' ]; return;
                                                    end;
                                                end;
                                            else
                                                g = [];
                                            end;
                                            
                                            for index = 1:size(fieldlist,NAME)
                                                % check if present
                                                % ----------------
                                                if ~isfield(g, fieldlist{index, NAME})
                                                    g = setfield( g, fieldlist{index, NAME}, fieldlist{index, DEF});
                                                end;
                                                tmpval = getfield( g, {1}, fieldlist{index, NAME});
                                                
                                                % check type
                                                % ----------
                                                if ~iscell( fieldlist{index, TYPE} )
                                                    res = fieldtest( fieldlist{index, NAME},  fieldlist{index, TYPE}, ...
                                                        fieldlist{index, VALS}, tmpval, callfunc );
                                                    if isstr(res), g = res; return; end;
                                                else
                                                    testres = 0;
                                                    tmplist = fieldlist;
                                                    for it = 1:length( fieldlist{index, TYPE} )
                                                        if ~iscell(fieldlist{index, VALS})
                                                            res{it} = fieldtest(  fieldlist{index, NAME},  fieldlist{index, TYPE}{it}, ...
                                                                fieldlist{index, VALS}, tmpval, callfunc );
                                                        else res{it} = fieldtest(  fieldlist{index, NAME},  fieldlist{index, TYPE}{it}, ...
                                                                fieldlist{index, VALS}{it}, tmpval, callfunc );
                                                        end;
                                                        if ~isstr(res{it}), testres = 1; end;
                                                    end;
                                                    if testres == 0,
                                                        g = res{1};
                                                        for tmpi = 2:length(res)
                                                            g = [ g 10 'or ' res{tmpi} ];
                                                        end;
                                                        return;
                                                    end;
                                                end;
                                            end;
                                            
                                            % check if fields are defined
                                            % ---------------------------
                                            allfields = fieldnames(g);
                                            for index=1:length(allfields)
                                                if isempty(strmatch(allfields{index}, fieldlist(:, 1)', 'exact'))
                                                    if ~strcmpi(mode, 'ignore')
                                                        g = [ callfunc 'error: undefined argument ''' allfields{index} '''']; return;
                                                    end;
                                                    varargnew{end+1} = allfields{index};
                                                    varargnew{end+1} = getfield(g, {1}, allfields{index});
                                                end;
                                            end;
                                            
                                            
                                            
                                            function [channo,angle,radius] = sph2topo(input,factor, method)
                                                
                                                chans = size(input,1);
                                                angle = zeros(chans,1);
                                                radius = zeros(chans,1);
                                                
                                                if nargin < 1
                                                    help sph2topo
                                                    return
                                                end
                                                
                                                if nargin< 2
                                                    factor = 0;
                                                end
                                                if factor==0
                                                    factor = 1;
                                                end
                                                if factor < 1
                                                    help sph2topo
                                                    return
                                                end
                                                
                                                if size(input,2) ~= 3
                                                    help sph2topo
                                                    return
                                                end
                                                
                                                channo = input(:,1);
                                                az = input(:,2);
                                                horiz = input(:,3);
                                                
                                                if exist('method')== 1 & method == 1
                                                    radius = abs(az/180)/factor;
                                                    i = find(az>=0);
                                                    angle(i) = 90-horiz(i);
                                                    i = find(az<0);
                                                    angle(i) = -90-horiz(i);
                                                else
                                                    angle  = -horiz;
                                                    radius = 0.5 - az/180;
                                                end;
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

end



function [g, varargnew] = finputcheck( vararg, fieldlist, callfunc, mode, verbose )

if nargin < 2
    help finputcheck;
    return;
end;
if nargin < 3
    callfunc = '';
else
    callfunc = [callfunc ' ' ];
end;
if nargin < 4
    mode = 'do not ignore';
end;
if nargin < 5
    verbose = 'verbose';
end;
NAME = 1;
TYPE = 2;
VALS = 3;
DEF  = 4;
SIZE = 5;

varargnew = {};
% create structure
% ----------------
if ~isempty(vararg)
    for index=1:length(vararg)
        if iscell(vararg{index})
            vararg{index} = {vararg{index}};
        end;
    end;
    try
        g = struct(vararg{:});
    catch
        vararg = removedup(vararg, verbose);
        try
            g = struct(vararg{:});
        catch
            g = [ callfunc 'error: bad ''key'', ''val'' sequence' ]; return;
        end;
    end;
else
    g = [];
end;

for index = 1:size(fieldlist,NAME)
    % check if present
    % ----------------
    if ~isfield(g, fieldlist{index, NAME})
        g = setfield( g, fieldlist{index, NAME}, fieldlist{index, DEF});
    end;
    tmpval = getfield( g, {1}, fieldlist{index, NAME});
    
    % check type
    % ----------
    if ~iscell( fieldlist{index, TYPE} )
        res = fieldtest( fieldlist{index, NAME},  fieldlist{index, TYPE}, ...
            fieldlist{index, VALS}, tmpval, callfunc );
        if isstr(res), g = res; return; end;
    else
        testres = 0;
        tmplist = fieldlist;
        for it = 1:length( fieldlist{index, TYPE} )
            if ~iscell(fieldlist{index, VALS})
                res{it} = fieldtest(  fieldlist{index, NAME},  fieldlist{index, TYPE}{it}, ...
                    fieldlist{index, VALS}, tmpval, callfunc );
            else res{it} = fieldtest(  fieldlist{index, NAME},  fieldlist{index, TYPE}{it}, ...
                    fieldlist{index, VALS}{it}, tmpval, callfunc );
            end;
            if ~isstr(res{it}), testres = 1; end;
        end;
        if testres == 0,
            g = res{1};
            for tmpi = 2:length(res)
                g = [ g 10 'or ' res{tmpi} ];
            end;
            return;
        end;
    end;
end;

% check if fields are defined
% ---------------------------
allfields = fieldnames(g);
for index=1:length(allfields)
    if isempty(strmatch(allfields{index}, fieldlist(:, 1)', 'exact'))
        if ~strcmpi(mode, 'ignore')
            g = [ callfunc 'error: undefined argument ''' allfields{index} '''']; return;
        end;
        varargnew{end+1} = allfields{index};
        varargnew{end+1} = getfield(g, {1}, allfields{index});
    end;
end;


    function g = fieldtest( fieldname, fieldtype, fieldval, tmpval, callfunc );
        NAME = 1;
        TYPE = 2;
        VALS = 3;
        DEF  = 4;
        SIZE = 5;
        g = [];
        
        switch fieldtype
            case { 'integer' 'real' 'boolean' 'float' },
                if ~isnumeric(tmpval) && ~islogical(tmpval)
                    g = [ callfunc 'error: argument ''' fieldname ''' must be numeric' ]; return;
                end;
                if strcmpi(fieldtype, 'boolean')
                    if tmpval ~=0 && tmpval ~= 1
                        g = [ callfunc 'error: argument ''' fieldname ''' must be 0 or 1' ]; return;
                    end;
                else
                    if strcmpi(fieldtype, 'integer')
                        if ~isempty(fieldval)
                            if (any(isnan(tmpval(:))) && ~any(isnan(fieldval))) ...
                                    && (~ismember(tmpval, fieldval))
                                g = [ callfunc 'error: wrong value for argument ''' fieldname '''' ]; return;
                            end;
                        end;
                    else % real or float
                        if ~isempty(fieldval) && ~isempty(tmpval)
                            if any(tmpval < fieldval(1)) || any(tmpval > fieldval(2))
                                g = [ callfunc 'error: value out of range for argument ''' fieldname '''' ]; return;
                            end;
                        end;
                    end;
                end;
                
                
            case 'string'
                if ~isstr(tmpval)
                    g = [ callfunc 'error: argument ''' fieldname ''' must be a string' ]; return;
                end;
                if ~isempty(fieldval)
                    if isempty(strmatch(lower(tmpval), lower(fieldval), 'exact'))
                        g = [ callfunc 'error: wrong value for argument ''' fieldname '''' ]; return;
                    end;
                end;
                
                
            case 'cell'
                if ~iscell(tmpval)
                    g = [ callfunc 'error: argument ''' fieldname ''' must be a cell array' ]; return;
                end;
                
                
            case 'struct'
                if ~isstruct(tmpval)
                    g = [ callfunc 'error: argument ''' fieldname ''' must be a structure' ]; return;
                end;
                
                
            case '';
            otherwise, error([ 'finputcheck error: unrecognized type ''' fieldname '''' ]);
        end
    end

% remove duplicates in the list of parameters
% -------------------------------------------
    function cella = removedup(cella, verbose)
        % make sure if all the values passed to unique() are strings, if not, exist
        %try
        [tmp indices] = unique(cella(1:2:end));
        if length(tmp) ~= length(cella)/2
            myfprintf(verbose,'Note: duplicate ''key'', ''val'' parameter(s), keeping the last one(s)\n');
        end;
        cella = cella(sort(union(indices*2-1, indices*2)));
    end
%catch
% some elements of cella were not string
%    error('some ''key'' values are not string.');
%end;

    function myfprintf(verbose, varargin)
        
        if strcmpi(verbose, 'verbose')
            fprintf(varargin{:});
        end;
    end

            
            
end