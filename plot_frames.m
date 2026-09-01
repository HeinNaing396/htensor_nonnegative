function plot_frames(frame, type, varargin)
%PLOT_FRAMES Plot frames which form the columns of Ut
%   PLOT_FRAMES(FRAME, TYPE) displays subplots of FRAME based on the 
%   specified TYPE. TYPE can be:
%       'bar' - bar graph, bar()
%       'line' - line graph, plot()
%       '2d' - image, imagesc()
% 
%   PLOT_FRAMES(FRAME, TYPE, VARARGIN) takes in additional arguments:
%       'sp_sz' - Layout subplots in a sp_sz(1) x sp_sz(2) grid. 
%       'x' - Horizontal axis values if TYPE is 'bar' or 'line'. 
%       'cols' - Horizontal axis values of the columns if TYPE is '2d'. 
%       'rows' - Vertical axis values of the columns if TYPE is '2d'. 
%       'xlim' - Range of x-axis. 
%       'ylim' - Range of y-axis. 
%       'xticks'- Tick mark positions along x-axis. 
%       'yticks'- Tick mark positions along y-axis.  
%       'xticklabels' - Tick mark labels along x-axis. 
%       'yticklabels' - Tick mark labels along y-axis. 
%       'xlabel' - Label of x-axis. 
%       'ylabel' - Label of y-axis. 
%       'subtitles' - Array of strings; titles for each subplot. 
%       'ratio' - The aspect ratio of the image. 
%       'width' - Width of the image. 
%       'fixed' - If true, set size of image as determined by 'ratio' and    
%       'width' parameters. Else, ignore these parameters. The default is
%       true. 
%       'yes_colorbar' - If true, each subplot is displayed with a
%       colorbar. Else, no colorbar is displayed. The default is true. 
%
%   See also FRAMEU 

    sz = size(frame);
    p = inputParser; 
    p.KeepUnmatched = true;

    addParameter(p, 'sp_sz', [sz(end), 1]); 
    
    addParameter(p, 'x', 1:sz(1));
    addParameter(p, 'cols', 1:sz(2));
    addParameter(p, 'rows', 1:sz(1)); 
    addParameter(p, 'xlim', []);
    addParameter(p, 'ylim', []);
    addParameter(p, 'xticks',[]);
    addParameter(p, 'yticks',[]);
    addParameter(p, 'xticklabels',[]);
    addParameter(p, 'yticklabels',[]);
    addParameter(p, 'xlabel',[]);
    addParameter(p, 'ylabel',[]); 
    addParameter(p, 'subtitles',[]); 
    addParameter(p, 'ratio',16/9); %W/H
    addParameter(p, 'width',12); 
    addParameter(p, 'fixed', true); 
    addParameter(p, 'yes_colorbar',true);

    parse(p, varargin{:});

    sp_sz = p.Results.sp_sz;
    x = p.Results.x;
    cols = p.Results.cols;
    rows = p.Results.rows;
    x_limits = p.Results.xlim;
    y_limits = p.Results.ylim;
    xtick = p.Results.xticks; 
    ytick = p.Results.yticks; 
    xticklabel = p.Results.xticklabels;
    yticklabel = p.Results.yticklabels; 
    xlab = p.Results.xlabel;
    ylab = p.Results.ylabel; 
    subtitles = p.Results.subtitles; 
    ratio = p.Results.ratio;
    width = p.Results.width; 
    fixed = p.Results.fixed; 
    yes_colorbar = p.Results.yes_colorbar; 
    
    % Remaining args go to plot functions
    plotArgs = p.Unmatched;
    plotArgs = [fieldnames(plotArgs), struct2cell(plotArgs)]';
    plotArgs = plotArgs(:)';

    figure; 
    for i = 1:sz(end)
        subplot(sp_sz(1), sp_sz(2), i); 

        if strcmp(type, 'bar')
            bar(x, frame(:,i), plotArgs{:})
        elseif strcmp(type, 'line')
            plot(x, frame(:,i), plotArgs{:})
        elseif strcmp(type, '2d')
            imagesc(cols, rows, frame(:,:,i), plotArgs{:})
            if yes_colorbar
                colorbar;
            end
        else
            error('Invalid type'); 
        end 

        % Adjustments after plotting
        if ~isempty(x_limits)
            xlim(x_limits);
        end
        if ~isempty(y_limits)
            ylim(y_limits);
        end

        if ~isempty(xtick)
            xticks(xtick); 
        end 
        if ~isempty(ytick)
            yticks(ytick); 
        end 

        if ~isempty(xticklabel)
            xticklabels(xticklabel); 
        end 
        if ~isempty(yticklabel)
            yticklabels(yticklabel); 
        end 

        if ~isempty(xlab)
            xlabel(xlab); 
        end 
        if ~isempty(ylab)
            ylabel(ylab); 
        end 

        if ~isempty(subtitles)
            if isscalar(subtitles)
                titles(subtitles); 
            else 
                title(subtitles(i)); 
            end 
        end 
    end
    
    if fixed
        height = width / ratio;
        set(gcf, 'Units', 'Inches', 'Position', [1 1 width height]);
    end 
end