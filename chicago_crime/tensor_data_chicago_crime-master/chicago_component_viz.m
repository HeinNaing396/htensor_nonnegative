function chicago_component_viz(M, modeinfo, j, figid, varargin)
%CHICAGO_COMPONENT_VIZ View single ktensor component for Chicago Crime.
%
%   CHICAGO_COMPONENT_VIZ(M,MODEINFO,J,FIGID) plots the Jth component of
%   the ktensor M in figure FIGID.
%
%   CHICAGO_COMPONENT_VIZ(...,'PARAM',VALUE) also takes the following
%   optional arguments:
%     o 'width' - Width of output figure in pixels (default 1300)
%     o 'height' - Height of output figure in pixels (default 550)
%     o 'dateticks' - Choices are 'yearly' (default) or 'monthly'.
%     o 'weekends' - Hightlight weekends, true or false (default).
%
%   See also CHICAGO_VIZ.

params = inputParser;
params.addParameter('width',1300);
params.addParameter('height',550);
params.addParameter('dateticks','yearly');
params.addParameter('weekends',false)
params.addParameter('dots',false) % experimental
params.parse(varargin{:});
dateticktype = params.Results.dateticks;
weekends = params.Results.weekends;    
dots = params.Results.dots;
%% Read in chicago shape file
fullpath = fileparts(mfilename('fullpath'));
fname = sprintf('%s/geodata/chicago_geo_data.shp',fullpath);
S = shaperead(fname, 'UseGeoCoords', true);

%% Sort out the model tensor
M = normalize(arrange(M),1);
U1 = M{1};
U2 = M{2};
U3 = M{3};
U4 = M{4};

%% Init figure
figure(figid); clf;

%% Relative spacings
xx = [1 20 1 20 1 30 1];
xx = xx / sum(xx);
yy = [1 20 3 15 3 ];
yy = yy / sum(yy);

% Create the global axis
GlobalAxis = axes('Position',[0 0 1 1]); % Global Axes
axis off;

% Resize 
wpx = 1300;
hpx = 550;
% Resize (keeping position of upper left corner the same)
width = wpx/100;     % Width in inches
height = hpx/100;    % Height in inches
pos = get(gcf, 'Position');
delta_y = max(0, height*100 - pos(4));
set(gcf, 'Position', [pos(1) (pos(2)-delta_y) width*100, height*100]); 

%%
% Create and plot dates in upper left 
dateaxes = axesarea(xx(1), sum(yy(1:3)), sum(xx(2:4)), yy(4), 0.05, 0.3);
if dots
    pattern = '.-';
else
    pattern = '-';
end
plot(datetime(modeinfo.labels{1}),U1(:,j),pattern,'Color', '#0072BD','MarkerSize',4);
xdata = datetime(modeinfo.labels{1});
if strcmpi(dateticktype,'monthly')
    ticks = xdata(day(xdata) == 1);
else % yearly
    ticks = xdata(day(xdata) == 1 & month(xdata) == 1);
end
set(gca,'XTick',ticks)
xlim([ datetime(xdata(1)) datetime(xdata(end)) ]);
set(gca,'XGrid','on')
set(dateaxes,'FontSize',12);
title('Date (Weighted)')
if weekends
    weekendidx = find(isweekend(xdata));
    yl = ylim;
    for i = weekendidx'
    patch([(i-0.5) (i-0.5) (i+0.5) (i+0.5)],[yl(1) yl(2) yl(2) yl(1)],'k',...
    'facecolor',[.4 .6 .4],'edgecolor',[.4 .6 .4],...
    'facealpha',0.1,'edgealpha',0);
    end
end

%%
% Create and plot hour of the day in the middle left
houraxes = axesarea(xx(1), yy(1), xx(2), yy(2), 0.2, 0.2);
bar(0:23,U2(:,j),'FaceColor','#D95319');
set(houraxes,'FontSize',12);
set(houraxes,'XTick',0:3:23);
set(houraxes,'XMinorTick','on');
ylim([0, max(U2(:))]);
title('Hour of Day')
set(gca,'XGrid','on')
%%
% Create and plot top crimes in lower right
crimeaxes = axesarea(sum(xx(1:3)), yy(1), xx(4), yy(2), 0.4, 0.2);
nn = 5;
[srt, sidx] = sort(U4(:,j),'ascend');
barh(srt(end-nn:end),'FaceColor','#77AC30');
set(crimeaxes,'YTick',1:nn+1);
set(crimeaxes,'YTickLabel',lower(modeinfo.labels{4}(sidx(end-nn:end))));
set(crimeaxes,'FontSize',12);
xlim([0 1]);
title('Top Crimes');

%% 
% Create and plot heatmap on entire right side
mapaxes = axesarea(sum(xx(1:5)), yy(1), xx(6),sum(yy(2:4)),0,0);
axes(mapaxes);
set(mapaxes,'FontSize',12);
chicago_heatmap(U3(:,j), min(U3(:)), max(U3(:)), S);
title('Areas')

%%

%%

function ax = axesarea(x,y,dx,dy,xop,yop)

xo = xop * dx;
yo = yop * dy;
ax = axes('Position',[x + xo, y + yo, dx - xo, dy - yo]);