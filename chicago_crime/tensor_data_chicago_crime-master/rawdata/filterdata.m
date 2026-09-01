%% Load data
load("Chicago_Crime_2022-10-25_Table.mat");

%% Remove early dates which have too little data 
s = summary(T);
idx = find(s.Date.Counts > 500,1,'first');
baddates = 1:idx-1;
badrows = ismember(T.Date,s.Date.Categories(baddates));
T(badrows,:) = [];
T.Date = removecats(T.Date);

%% Check that dates are contiguous
dates = categories(T.Date);
d1=datetime(dates{1})
d2=datetime(dates{end})
fprintf('Days in Range: %d\n',days(d2-d1)+1);
fprintf('Days in Categories: %d\n',size(dates,1));

% %% Helper variables for dates
% dates = categories(T.Date);
% yearstart = find(cellfun(@(x) isequal(x(6:10),'01-01'), dates));
% monthstart = find(cellfun(@(x) isequal(x(9:10),'01'), dates));
% 


%% Keep only the most prevalent crimes
summary(T(:,1)) % Before
s = summary(T);
cutoff = round(500 * length(s.Date.Counts)/365); %avg of 500x per year
fprintf('Removing the crimes with less than %d incidents\n',cutoff);
tf = s.Type.Counts > cutoff;
sum(~tf)
badcrimes = s.Type.Categories(~tf);
badrows = ismember(T.Type,badcrimes);
T(badrows,:) = [];
T.Type = removecats(T.Type);
summary(T(:,1)) % After

%% Reorder the categories by prevalence
s = summary(T);
[scnt,sidx] = sort(s.Type.Counts,'descend');
T.Type = categorical(T.Type,s.Type.Categories(sidx));
summary(T(:,1)) % After

%%
s = summary(T);
figure(1); clf;
plot(datetime(s.Date.Categories),s.Date.Counts,'-*');
set(gca,'XTick',datetime(2002:2022,1,1))
set(gca,'XMinorTick','on')
ylabel('Count')
title(sprintf('Crime Counts by Day from %s to %s',s.Date.Categories{1},s.Date.Categories{end}));

%% Crimes by Type
s = summary(T);
foo = categorical(s.Type.Categories,s.Type.Categories,s.Type.Categories);
figure(2); clf;
bar(foo,s.Type.Counts);
ylabel('Count');
title(sprintf('Crime Counts by Type from %s to %s',s.Date.Categories{1},s.Date.Categories{end}));

%% Summary by Region
s = summary(T);
foo = s.Community.Counts;
cd ..
figure(3); clf
chicago_heatmap(foo,min(foo),max(foo));
cd rawdata
title(sprintf('Crime Counts by Community from %s to %s',s.Date.Categories{1},s.Date.Categories{end}));

%% Crime by Hour
s = summary(T);
figure(4); clf;
bar(0:23, s.Hour.Counts);
set(gca,'XTick',0:23)
title(sprintf('Crime Counts by Hour from %s to %s',s.Date.Categories{1},s.Date.Categories{end}));
xlabel('Hour')
ylabel('Count')

%% Save out tensor, various summaries, etc.
nentries = size(T,1);
subs = zeros(nentries,4);
vals = ones(nentries,1);
s = summary(T);
modeinfo = struct;
modeinfo.name{1} = "Day";
modeinfo.labels{1} = categories(T.Date);
modeinfo.counts{1} = s.Date.Counts;
subs(:,1) = grp2idx(T.Date);
modeinfo.name{2} = "Hour";
modeinfo.labels{2} = categories(T.Hour);
modeinfo.counts{2} = s.Hour.Counts;
subs(:,2) = grp2idx(T.Hour);
modeinfo.name{3} = "Community";
modeinfo.labels{3} = categories(T.Community);
modeinfo.counts{3} = s.Community.Counts;
subs(:,3) = T.Community;
modeinfo.name{4} = "Crime";
modeinfo.labels{4} = categories(T.Type);
modeinfo.counts{4} = s.Type.Counts;
subs(:,4) = grp2idx(T.Type);
%%
X = sptensor(subs,vals);
size(X)
nnz(X)

%%
save('../chicago_crime.mat','X','modeinfo')


