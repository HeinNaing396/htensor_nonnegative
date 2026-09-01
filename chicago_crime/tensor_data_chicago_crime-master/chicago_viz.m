function chicago_viz(M,modeinfo,figid,varargin)
%CHICAGO_VIZ View ktensor of Chicago Crime tensor.
%
%   CHICAGO_VIZ(M,MODEINFO,FIGID) plots the CP decomposition of the Chicago
%   Crime tensor in the figure FIGID. 
%
%   CHICAGO_VIZ(M,MODEINFO,FIGID,'Param',Value,...) also can take the
%   following:
%
%    o 'width' - Width in pixels, defaults to 1300
%    o 'height' - Height in pixels, defaults to 550
%    o 'lastidx4' - Max number of crimes to plot in bar chart, default 13,
%    o 'dateticks' - 'yearly' (default) or 'monthly'

%% Set algorithm parameters from input or by using defaults
sz = size(M);
params = inputParser;
params.addParameter('relmodewidth',[]);
params.addParameter('width',1300);
params.addParameter('height',550);
params.addParameter('lastidx4',min(13,sz(4)));
params.addParameter('dateticks','yearly');
params.parse(varargin{:});

lastidx4 = params.Results.lastidx4;
rmw = params.Results.relmodewidth;
if isempty(rmw)
    rmw = [2 0.5 0.5 1];
    rmw(1) = max(2 * sz(1)/7484,1);
    rmw(4) = min(0.5, lastidx4/13);
end
dateticktype = params.Results.dateticks;


%%
r = ncomponents(M);

%% Visuzalize results
pltcmd = {@(x,y) plot(x,y),...
    @(x,y) bar(x,y,'r'),...
    @(x,y) bar(x,y,'k'),...
    @(x,y) bar(x,y,'g')};

vh = viz(M, 'Figure',figid,...
    'PlotCommands',pltcmd,...
    'ModeTitles',{'Date (Weighted)','Hour','Community','Crime'},...
    'RelModeWidth',rmw,...
    'Normalize',@(X) normalize(arrange(X),1),...
    'FactorTitles','number',...
    'LeftSpace',0.025,'BottomSpace',0.2);

%% Good size for Powerpoint slide
wpx = params.Results.width;
hpx = params.Results.height;
% Resize (keeping position of upper left corner the same)
width = wpx/100;     % Width in inches
height = hpx/100;    % Height in inches
pos = get(gcf, 'Position');
delta_y = max(0, height*100 - pos(4));
set(gcf, 'Position', [pos(1) (pos(2)-delta_y) width*100, height*100]); 

%% Fix up Mode 1 - show year markings
xdata = datetime(modeinfo.labels{1});
if strcmpi(dateticktype,'monthly')
    dateticks = find( day(xdata) == 1 );
    datelabels = string(xdata(dateticks),'yyyy-MM');
elseif strcmpi(dateticktype,'quarterly')
    dateticks = find( day(xdata) == 1 & ismember(month(xdata),[1 4 7 10]) );
    datelabels = string(xdata(dateticks),'yyyy-MM');
else % yearly
    dateticks = find( day(xdata) == 1 & month(xdata) == 1 );
    datelabels = year(xdata(dateticks));
end
for i = 1:r
        set(vh.FactorAxes(1,i),'XTick',dateticks);
        set(vh.FactorAxes(1,i),'XGrid','on');        
end

set(vh.FactorAxes(1,r),'XTickLabel',datelabels);
set(vh.FactorAxes(1,r),'XTickLabelRotation',-90);


%% Fix up Mode 2 - show 6-hour markings and lengthen
yl = get(vh.FactorAxes(2,1),'YLim');
for i = 1:r
    set(vh.FactorAxes(2,i),'TickLength',[0.0500 0.20]);
    set(vh.FactorAxes(2,i),'XTick',(1:6:25)-0.5);
    set(vh.FactorAxes(2,i),'XGrid','on');
end
set(vh.FactorAxes(2,r),'XTickLabel',(1:6:25)-1);
set(vh.FactorAxes(2,r),'XTickLabelRotation',-90);

%% Fix up Mode 3
for i = 1:r
    set(vh.FactorAxes(3,i),'XTick',11:11:77);
end
set(vh.FactorAxes(3,r),'XTickLabelRotation',-90);

%% Fix up Mode 4 - show crime type labels
for i = 1:r
    set(vh.FactorAxes(4,i),'XTick',1:lastidx4);
    set(vh.FactorAxes(4,i),'XLim',[0.5 lastidx4+0.5]);
end
set(vh.FactorAxes(4,r),'XTickLabel',lower(modeinfo.labels{4}(1:lastidx4)));
set(vh.FactorAxes(4,r),'XTickLabelRotation',-90);
