%% Example of GCP and VIZ

%% Set up image save location
savedir = pwd;

%% Load the chicago data (assumes that the location is in the path)
load chicago_crime_2019.mat

%% Convert to *dense* tensor since it's relatively small
X = full(X);

%% Run a bunch of ranks
diary('multi_runs.log')
diary ON
rng('default'); 
nranks = 12;
nruns = 3;
seed = zeros(nranks,nruns);
fval = zeros(nranks,nruns);
M = cell(nranks,nruns);
for j = 1:nruns
    for rk = 1:nranks
        seed(rk,j) = randi(intmax,1,1);
        rng(seed(rk,j));
        fprintf('\n*** Rank=%d, Run=%d, Seed=%d ***\n\n',rk,j,seed(rk,j));
        [M{rk,j},~,info] = gcp_opt(X,rk,'type','count','pgtol',1e-7*prod(size(X)), 'maxiters',500,'printitn',25);
        fval(rk,j) = info.finalf;
    end
end
diary OFF

%% Save everything
save('multi_runs.mat','seed','fval','M');

%% Print out some info (can be used with PGFPLOTS, for instance)
minf = min(fval');
maxf = max(fval');
fprintf('f1 f2 f3 fmin fmax\n')
for rk = 1:nranks
    fprintf('%.6g ', fval(rk,:));
    fprintf('%.6g ',minf(rk));
    fprintf('%.6g ',maxf(rk));
    fprintf('\n');
end

%% Plot different fit values
figure(1); clf
h=plot(minf,'-','LineWidth',0.1);
hold on
plot(fval,'*','MarkerSize',8);
xlim([0.5,12.5])
legend('min','run 1', 'run 2', 'run 3')
xlabel('rank')
ylabel('function value')
title('Chicago Crime 2019 Rank Comparison (3 runs)')
width = 560/100;     % Width in inches
height = 300/100;    % Height in inches
pos = get(gcf, 'Position');
delta_y = max(0, height*100 - pos(4));
set(gcf, 'Position', [pos(1) (pos(2)-delta_y) width*100, height*100]);
%%
exportgraphics(gcf,fullfile(savedir,'func-vs-rank.png'),'Resolution','300');

%% Find the best for a given rank, viz the decomp
for r=6:9
    [~,idx] = min(fval(r,:));
    chicago_viz(M{r,idx},modeinfo,2,'dateticks','monthly')
    exportgraphics(gcf,sprintf('%s/rank-%d.png',savedir,r),'Resolution','300');
end
%% View and export the components
r = 7;
[~,idx] = min(fval(r,:));
for i = 1:r
    chicago_component_viz(M{r,idx},modeinfo,i,3,'dateticks','monthly','weekends',true,'dots',true)
    exportgraphics(gcf,sprintf('%s/rank-%d-comp-%d.png',savedir,r,i),'Resolution','300');
end