%% Example of GCP and VIZ

diary('basic_gcp_run.log')
diary ON

%% Load the chicago data (assumes that the location is in the path)
load chicago_crime.mat

%% Run or Load Result
if 1
    rng('default')
    M = gcp_opt(X,10,'type','count','fsamp',25000,'gsamp',6377);
    save("gcp_decomp.mat",'M');
else
    load("gcp_decomp.mat");
end

%% Viz results
chicago_viz(M,modeinfo,1)
exportgraphics(gcf,'chicago_gcp.png','Resolution',300);

%% Viz individual components
for i = 1:10
    chicago_component_viz(M,modeinfo,i,2);
    exportgraphics(gcf,sprintf('chicago_gcp_%d.png',i),'Resolution',300);
end

%%
diary OFF