%% Show some statistics on the Crime data

%% Load data (assumes this is in path)
load chicago_crime_2019.mat

%% Set up image save location
savedir = pwd;

%% Distribution of counts
cnts = X.vals;
sz = size(X);
nz = nnz(X);
fprintf('Total entries in tensor:  %d\n', prod(sz));
fprintf('Total nonzeros in tensor: %d\n', nz)
fprintf('Proporition of nonzeros: %g\n', nz/prod(sz));

tsz = prod(sz);
bins = 0:(max(cnts)+2);
hcnts = histcounts(cnts,bins);
hcnts(1) = tsz - nz;

fprintf('|Value|   Count   |  Percent   |\n');
fprintf('|-----|-----------|------------|\n')
for i = 1:(length(bins)-1)
    if (hcnts(i) ~= 0)
        fprintf('| %3d | %9d | %10.7f |\n', ...
            bins(i), hcnts(i), 100*hcnts(i)/tsz);
    end
end

%% Crime by date
crime_by_day = collapse(X,-1);
figure(1); clf;
plot(datetime(modeinfo.labels{1}),crime_by_day);
title(sprintf('Crime Counts by Day from %s to %s',...
    modeinfo.labels{1}{1},modeinfo.labels{1}{end}));
xlabel('Day');
ylabel('Count')

width = 560/100;     % Width in inches
height = 300/100;    % Height in inches
pos = get(gcf, 'Position');
delta_y = max(0, height*100 - pos(4));
set(gcf, 'Position', [pos(1) (pos(2)-delta_y) width*100, height*100]);
grid on
set(gca,'YMinorTick','on')
set(gca,'YMinorGrid','on')
%%
exportgraphics(gcf,fullfile(savedir,'crime_per_day.png'),'Resolution','300')

%% Crime by hour
crime_by_hour = collapse(X,-2);
figure(2); clf;
bar(0:23,crime_by_hour,'FaceColor','#D95319');
set(gca,'XTick',0:23);
title(sprintf('Crime Counts by Hour from %s to %s',...
    modeinfo.labels{1}{1},modeinfo.labels{1}{end}));
xlabel('Hour');
ylabel('Count')


width = 560/100;     % Width in inches
height = 220/100;    % Height in inches
pos = get(gcf, 'Position');
delta_y = max(0, height*100 - pos(4));
set(gcf, 'Position', [pos(1) (pos(2)-delta_y) width*100, height*100]);
grid on
set(gca,'YMinorGrid','on')
set(gca,'XMinorGrid','off')

%%
exportgraphics(gcf,fullfile(savedir,'crime_per_hour.png'),'Resolution','300')

%% Breakdown by neighborhood 
figure(3); clf;
cnt_nbhd = collapse(X,-3);
chicago_heatmap(cnt_nbhd, 0, max(cnt_nbhd));
width = 560/100;     % Width in inches
height = 420/100;    % Height in inches
pos = get(gcf, 'Position');
delta_y = max(0, height*100 - pos(4));
set(gcf, 'Position', [pos(1) (pos(2)-delta_y) width*100, height*100]);
title(sprintf('Crime Counts by Community\nfrom %s to %s',...
    modeinfo.labels{1}{1},modeinfo.labels{1}{end}));

%%
exportgraphics(gcf,fullfile(savedir,'crime_per_nbhd.png'),'Resolution','300')


%% Breakdown by crime
cc = collapse(X,-4);
%[cc,ii] = sort(crime_counts,1,'ascend');
ctotal = sum(cc);
fprintf('| %33s | %7s | %7s |\n','Crime','Count','Percent');
fprintf('|-----------------------------------|---------|---------|\n')
for i = 1:length(cc)
    fprintf('| %33s | %7d | %7.4f |\n', ...
        lower(modeinfo.labels{4}{i}), ...
        cc(i), 100*cc(i)/ctotal);
end

%% Version 1 - xbar
% blah = lower(modeinfo.labels{4});
% foo = categorical(blah,blah,blah);
% figure(4); clf;
% bar(foo,cc);
% ylabel('Count');
% title(sprintf('Crime Counts by Type from %s to %s',modeinfo.labels{1}{1},modeinfo.labels{1}{end}));
% width = 6;     % Width in inches
% height = 4;    % Height in inches
% pos = get(gcf, 'Position');
% delta_y = max(0, height*100 - pos(4));
% set(gcf, 'Position', [pos(1) (pos(2)-delta_y) width*100, height*100]);
% grid on
% set(gca,'YMinorTick','on')
% set(gca,'YMinorGrid','on')

%% Version 2 - ybar
figure(5); clf;
tmp = lower(modeinfo.labels{4});
idx=find(cellfun(@(x) strcmp(x,'interference with public officer'), tmp));
if ~isempty(idx)
    tmp{idx}='interfere with officer';
end
foo = categorical(tmp,tmp,tmp);
barh(foo,cc,'FaceColor','#77AC30')
ytickangle(gca,30)
%set(gca,'YTick',1:22)
%set(gca,'YtickLabel',tmp)
width = 4;     % Width in inches
height = 4;    % Height in inches
pos = get(gcf, 'Position');
delta_y = max(0, height*100 - pos(4));
set(gcf, 'Position', [pos(1) (pos(2)-delta_y) width*100, height*100]);
set(gca,'YDir','reverse')
set(gca,'XMinorTick','on')
set(gca,'XMinorGrid','on')
title(sprintf('Crime Counts by Type\n from %s to %s',modeinfo.labels{1}{1},modeinfo.labels{1}{end}));


%%
exportgraphics(gcf,fullfile(savedir,'crime_per_type.png'),'Resolution','300')

%% Breakdown by crime/year
cc = collapse(X,-4);
crime_per_day = double(collapse(X,[2 3],@sum));
year = cellfun(@(x) str2num(x(1:4)), modeinfo.labels{1});
year_idx = year -  min(year) + 1;

% Collapse all beyond the first 6 crimes into one 'other' sum
crime_per_day_new = zeros(size(crime_per_day,1),7);
crime_per_day_new(:,1:6) = crime_per_day(:,1:6);
crime_per_day_new(:,7) = sum(crime_per_day(:,7:end),2);

figure(6);
bar(datetime(modeinfo.labels{1}),crime_per_day_new,1,'stacked','LineStyle','none')
tmp = cellfun(@lower,modeinfo.labels{4},'UniformOutput',false);
legend({tmp{1:6},'everything else'},'Location','northeastoutside')

width = 9;     % Width in inches
height = 3;    % Height in inches
pos = get(gcf, 'Position');
delta_y = max(0, height*100 - pos(4));
set(gcf, 'Position', [pos(1) (pos(2)-delta_y) width*100, height*100]);
title(sprintf('Crime Counts by Day & Type from %s to %s',modeinfo.labels{1}{1},modeinfo.labels{1}{end}));

%%
exportgraphics(gcf,fullfile(savedir,'crime_per_year_per_type.png'),'Resolution','300')




