%% Create tensor with only 2019 data
load("chicago_crime.mat");

%% Reduce the tensor, overwriting X and modeinfo
[X,modeinfo] = chicago_subtensor(X,modeinfo,'startdate','2019-01-01',...
    'enddate','2019-12-31','crimetopk',12);

%% Save to mat file
save('../chicago_crime_2019.mat','X','modeinfo');