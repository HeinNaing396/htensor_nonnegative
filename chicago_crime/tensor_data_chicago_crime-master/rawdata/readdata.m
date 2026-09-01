%% Import data from text file
diary on
echo on
fprintf('\n*** Data Import: Converting from CVS to MATLAB Table***\n')

%% Read file
fname = "Chicago_Crime_2022-10-25.csv";
fprintf('Reading file: %s\n',fname)
tic
% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 22);

% Specify range and delimiter
opts.DataLines = [1, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["Var1", "Var2", "Date", "Var4", "Var5", "PrimaryType", "Var7", "LocationDescription", "Var9", "Var10", "Var11", "Var12", "Var13", "CommunityArea", "Var15", "Var16", "Var17", "Var18", "Var19", "Var20", "Var21", "Var22"];
opts.SelectedVariableNames = ["Date", "PrimaryType", "CommunityArea"];
opts.VariableTypes = ["string", "string", "datetime", "string", "string", "categorical", "string", "categorical", "string", "string", "string", "string", "string", "double", "string", "string", "string", "string", "string", "string", "string", "string"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, ["Var1", "Var2", "Var4", "Var5", "Var7", "Var9", "Var10", "Var11", "Var12", "Var13", "Var15", "Var16", "Var17", "Var18", "Var19", "Var20", "Var21", "Var22"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Var1", "Var2", "Var4", "Var5", "PrimaryType", "Var7", "LocationDescription", "Var9", "Var10", "Var11", "Var12", "Var13", "Var15", "Var16", "Var17", "Var18", "Var19", "Var20", "Var21", "Var22"], "EmptyFieldRule", "auto");
opts = setvaropts(opts, "Date", "InputFormat", "MM/dd/yyyy hh:mm:ss aa");

% Import the data
T = readtable(fname, opts);

% Clean up
clear opts;
toc
%% Summarize
fprintf('Created table T with %d rows and %d columns\n', size(T));
summary(T)
%% Cleaning up initial table

% Remove invalid dates
badrows = isnat(T.Date);
T(badrows,:) = [];
fprintf('Removed %d bad dates\n', sum(badrows));

% Remove invalid community areas
badrows = isnan(T.CommunityArea);
T(badrows,:) = [];
fprintf('Removed %d bad community areas (missing)\n', sum(badrows));

% Removing more invalid community areas
badrows = (T.CommunityArea == 0);
T(badrows,:) = [];
fprintf('Removed %d bad community areas (invalid)\n', sum(badrows));

fprintf('Updated table T now has %d rows and %d columns\n', size(T));
summary(T)
%% Create 'hourcat' column
fprintf('Extracting hours...\n')
tic
hour = datestr(T.Date,'HH');
toc
fprintf('Converting to categorical...\n')
tic
hourcat = categorical(cellstr(hour(1:end,:)));
toc
summary(hourcat)
T = [T, table(hourcat)];
clear hourcat hour
fprintf('Updated table T now has %d rows and %d columns\n', size(T));
summary(T)
%% Create 'datecat' column
fprintf('Extracting dates...\n')
tic
date = datestr(T.Date,'yyyy-mm-dd');
toc
fprintf('Converting to categorical and adding to table...\n')
tic 
datearray = cellstr(date(1:end,:));
toc
datecat = categorical(datearray);
T = [T, table(datecat)];
clear datearray datecat date
fprintf('Updated table T now has %d rows and %d columns\n', size(T));

%% Remove original Date column
fprintf('Removing original date column')
T = removevars(T,'Date');
fprintf('Updated table T now has %d rows and %d columns\n', size(T));
%% Rename new columns
T = renamevars(T, ["hourcat","datecat"],["Hour","Date"]);

%% Change CommunityArea to categorical
T.CommunityArea = categorical(T.CommunityArea);

%% Changing more names
T = renamevars(T,"PrimaryType","Type");
T = renamevars(T,"CommunityArea","Community");

%% Summary after renaming some variables
fprintf('Summary of first three tables (last omitted because too big!')
summary(T(:,1:3))

%% 
save("Chicago_Crime_2022-10-25_Table.mat",'T');
diary off
echo off
