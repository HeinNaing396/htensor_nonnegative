function [Xnew,minew] = chicago_subtensor(X,mi,varargin)
%CHICAGO_SUBTENSOR Select a subtensor of the Chicago tensor.
%
%   [X,MODEINFO] = CHICAGO_SUBTENSOR(X,MODEINFO,'param','value',...)
%   computes a subtensor of X and updates the modeinfo, using the following
%   criteria:
%
%   o 'startdate' - New start date in range '2002-04-22' to '2022-10-17'.
%   o 'enddate' - New end date in range '2002-04-22' to '2022-10-17'.
%   o 'crimetopk' - Specify how many crimes to keep, in the range 1 to 22. 
%
%   If 'crimetopk' is not specified, the crimes will *not* be reordered by
%   frequency. Otherwise, the crimes are reindexed by frequency and only
%   the most revalent crimes are used.
%

%%
params = inputParser;
params.addParameter('startdate',[]);
params.addParameter('enddate',[]);
params.addParameter('crimetopk',[]);
params.parse(varargin{:});
startdate = params.Results.startdate;
enddate = params.Results.enddate;
crimetopk = params.Results.crimetopk;

%% Redo date range
dt = datetime(mi.labels{1});
if isempty(startdate) 
    startidx = 1;
else
    startidx = find(dt==datetime(startdate));
end
if isempty(enddate) 
    endidx = size(X,1);
else
    endidx = find(dt==datetime(enddate));
end
fprintf('Startdate: %s (idx=%d)\n', dt(startidx), startidx);
fprintf('Enddate  : %s (idx=%d)\n', dt(endidx), endidx);

%% Crime range
if isempty(crimetopk)
    crimerange = 1:size(X,4);
else
    Xtmp = X(startidx:endidx,:,:,:);
    cnts = collapse(Xtmp,-4);
    fprintf('Crime counts for date range...\n')
    [scnts,sidx] = sort(cnts,'descend');
    for i = 1:size(Xtmp,4)
        fprintf('%6d %s\n', scnts(i), mi.labels{4}{sidx(i)})
    end
    [~,crimerange] = maxk(cnts,crimetopk);
end


%% Subselect tensor
Xnew = X(startidx:endidx,:,:,crimerange);
minew=mi;
minew.labels{1} = mi.labels{1}(startidx:endidx);
minew.labels{4} = mi.labels{4}(crimerange);

%% Redo counts
for i = 1:4
    minew.counts{i} = collapse(Xnew,-i);
end

fprintf('Reordered and reduced crime counts for date range...\n')
for i = 1:size(Xnew,4)
    fprintf('%6d %s\n', minew.counts{4}(i), minew.labels{4}{i})
end

