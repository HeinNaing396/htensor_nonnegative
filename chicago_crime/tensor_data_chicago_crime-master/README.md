# Chicago Crime Data, Version 3.0

## How to Cite

* T. G. Kolda, New Chicago Crime Tensor Dataset (Version 3.0), https://gitlab.com/tensors/tensor_data_chicago_crime, Nov. 2024

## Description

The **Chicago Crime** tensor dataset `chicago_crime.mat` comprises 7,005,683 crime reports from the US city of Chicago during the period Apr 4, 2002 through Oct 17, 2022. 

This tensor is formatted as a 4-way sparse tensor of integer counts with

* 7484 days
* 24 hours
* 77 communities
* 22 (crime) types

There are 6,377,326 (2.1%) nonzeros in the sparse tensor in the range {1,...,101}. Of those, 92% are 1, 7% are 2, 1% are 3, and a tiny proportion are in the remainder of the range.

## Repository Organization

- `chicago_crime.mat` - Main data file, described below.
- `chicago_crime_2019.mat` - Smaller data file containing only data from 2019, described below.
- `chicago_viz.m` - MATLAB function for visualizing CP decomposition of Chicago Crime dataset. 
- `chicago_component_viz.m` - MATLAB function for visualizing a single CP component of Chicago Crime dataset, including geographic heatmap.
- `chicago_heatmap.m` - MATLAB function for producing geographic heatmap of Chicago.
- `chicago_subtensor.m` - Extract only a portion of the full dataset.
- `README.md` - This file. 
- `geodata` - Directory containing geographic data on Chicago city regions.
- `images` - Directory of images and example code using the full dataset.
- `images_2019` - Directory of images and example code using only the 2019 dataset.

## Full Data File

The representation of the sparse tensor requires the [Tensor Toolbox for MATLAB](https://www.tensortoolbox.org).

The file `chicago_crime.mat` is the main data file containing the Chicago Crime tensor and related information. The variables are as follows.

* `X` - A 7484 x 24 x 77 x 22 `sptensor` (Tensor Toolbox sparse tensor) with 6,377,326 nonzeros. Entry `X(i,j,k,l)` is the number of crimes on data `i`, hour `j`, in area `k`, of type `l`.
* `modeinfo` - Cell array of length 4 with information about each mode:
  - `modeinfo.names{k}` is the one-word description of mode k
  - `modeinfo.labels{k}` is an array of descriptors for each index in that mode
  - `modeinfo.counts{k}` is an array of counts that gives the number of occurences of each even in that mode

The `Community` mode has indices from 1 to 77 corresponding to the [geographic regions of Chicago](https://en.wikipedia.org/wiki/Community_areas_in_Chicago).

## Data Breakdowns of the Full Chicago Crime Tensor

<img src="images/crime_per_day.png" width=400px>

<img src="images/crime_per_hour.png" width=400px>

<img src="images/crime_per_nbhd.png" width=300px>

<img src="images/crime_per_type.png" width=300px>

<img src="images/crime_per_year_per_type.png" width=400px>

## GCP Computing and Visualization on Full Tensor

### Computing GCP Tensor Decomposition

Here is an example of using `gcp_opt` from the Tensor Toolbox to compute a rank-10 GCP factorization.
We specify GCP type as 'count' since this is a count tensor.
Because this is a sparse tensor, the 'adam' stochatic optimization is used by default. 
We specify the number of function samples and gradient samples.

``` 
rng('default');
M = gcp_opt(X,10,'type','count','fsamp',25000,'gsamp',6377);
```

Here is the output:

```
GCP-OPT-ADAM (Generalized CP Tensor Decomposition)

Tensor size: 7484 x 24 x 77 x 22 (304269504 total entries)
Sparse tensor: 6377326 (2.1%) Nonzeros and 297892178 (97.90%) Zeros
GCP rank: 10
Generalized function Type: count
Objective function: @(x,m)m-x.*log(m+1e-10)
Gradient function: @(x,m)1-x./(m+1e-10)
Lower bound of factor matrices: 0
Optimization method: adam
Max iterations (epochs): 1000
Iterations per epoch: 1000
Learning rate / decay / maxfails: 0.001 0.1 1
Function Sampler: stratified with 25000 nonzero and 25000 zero samples
Gradient Sampler: stratified with 6377 nonzero and 6377 zero samples

Begin Main loop
Initial f-est: 6.134733e+07
Epoch  1: f-est = 2.634182e+07, step = 0.001
Epoch  2: f-est = 2.580401e+07, step = 0.001
Epoch  3: f-est = 2.563328e+07, step = 0.001
Epoch  4: f-est = 2.539133e+07, step = 0.001
Epoch  5: f-est = 2.507775e+07, step = 0.001
Epoch  6: f-est = 2.495352e+07, step = 0.001
Epoch  7: f-est = 2.489074e+07, step = 0.001
Epoch  8: f-est = 2.485196e+07, step = 0.001
Epoch  9: f-est = 2.485826e+07, step = 0.001, nfails = 1 (resetting to solution from last epoch)
Epoch 10: f-est = 2.481147e+07, step = 0.0001
Epoch 11: f-est = 2.479003e+07, step = 0.0001
Epoch 12: f-est = 2.478405e+07, step = 0.0001
Epoch 13: f-est = 2.477400e+07, step = 0.0001
Epoch 14: f-est = 2.476071e+07, step = 0.0001
Epoch 15: f-est = 2.475143e+07, step = 0.0001
Epoch 16: f-est = 2.474807e+07, step = 0.0001
Epoch 17: f-est = 2.475029e+07, step = 0.0001, nfails = 2 (resetting to solution from last epoch)
End Main Loop

Final f-est: 2.4748e+07
Setup time: 0.37 seconds
Main loop time: 133.36 seconds
Total iterations: 17000
```


### Visualizing Factors

We provide some tools to help visualize the factors.
The command

```
chicago_viz(M,modeinfo,1)
```

produces

<img src="images/chicago_gcp.png" width=780px>

Each row corresponds to a component in the rank-10 GCP factorization.
The factors for hour, community, and crime are normalized to sum to one,
and the factor for the data shows the magnitude of the component. 
The components are orders by weight, from greatest to least.

The main problem with this visual is that we cannot easily tell the mapping of the neighborhoods numbers to the map.

### Visualizing Individual Factors with Heatmaps

We can visualize a heat map for component `j` as follows:

```
chicago_component_viz(M,modefinfo,j,2);
```

Here are a the components...

**Component 1**
<img src="images/chicago_gcp_1.png" width=500px>

**Component 2**
<img src="images/chicago_gcp_2.png" width=500px>

**Component 3**
<img src="images/chicago_gcp_3.png" width=500px>

**Component 4**
<img src="images/chicago_gcp_4.png" width=500px>

**Component 5**
<img src="images/chicago_gcp_5.png" width=500px>

**Component 6**
<img src="images/chicago_gcp_6.png" width=500px>

**Component 7**
<img src="images/chicago_gcp_7.png" width=500px>

**Component 8**
<img src="images/chicago_gcp_8.png" width=500px>

**Component 9**
<img src="images/chicago_gcp_9.png" width=500px>

**Component 10**
<img src="images/chicago_gcp_10.png" width=500px>

## Using Subsets of the Data and the 2019 Data File

The file `chicago_crime_2019.mat` is a smaller dataset that contains only data from 2019
and only the top-12 crimes during that period. The variables are as follows.

* `X` - A 365 x 24 x 77 x 12 `sptensor` (Tensor Toolbox sparse tensor) with 230,591 nonzeros. Entry `X(i,j,k,l)` is the number of crimes on data `i`, hour `j`, in area `k`, of type `l`.
* `modeinfo` - Cell array of length 4 with information about each mode:
  - `modeinfo.names{k}` is the one-word description of mode k
  - `modeinfo.labels{k}` is an array of descriptors for each index in that mode
  - `modeinfo.counts{k}` is an array of counts that gives the number of occurences of each even in that mode
  
This tensor was created using the `chicago_subtensor` function that is included in this repository and the following command:
``` 
[X,modeinfo] = chicago_subtensor(X,modeinfo,'startdate','2019-01-01','enddate','2019-12-31','crimetopk',12);
```
(Note that this overwrites the values of `X` and `modeinfo`. The outputs can be named something else to avoid this.)

## Data Breakdowns of the 2019 Chicago Crime Tensor

<img src="images-2019/crime_per_day.png" width=400px>

<img src="images-2019/crime_per_hour.png" width=400px>

<img src="images-2019/crime_per_nbhd.png" width=300px>

<img src="images-2019/crime_per_type.png" width=300px>

<img src="images-2019/crime_per_year_per_type.png" width=600px>

## GCP Computing and Visualization on 2019 Tensor



### Computing GCP Tensor Decomposition for Dense 2019 Data

Since this dataset is smaller, we can treat it as a dense tensor.
We can moreover perform multiple runs across several different ranks, as follows.

```
X = full(X); % Convert to dense tensor
rng('default');  % Reproducibility
nranks = 12;
nruns = 3;
seed = zeros(nranks,nruns);
fval = zeros(nranks,nruns);
M = cell(nranks,nruns);
for j = 1:nruns
    for rk = 1:nranks
        seed(rk,j) = randi(intmax,1,1);
        rng(seed(rk,j)); % Individual run reproducibility
        fprintf('\n*** Rank=%d, Run=%d, Seed=%d ***\n\n',rk,j,seed(rk,j));
        [M{rk,j},~,info] = gcp_opt(X,rk,'type','count','pgtol',1e-7*prod(size(X)), 'maxiters',500,'printitn',25);
        fval(rk,j) = info.finalf;
    end
end
```

The results are shown below:

<img src="images-2019/func-vs-rank.png" width=400px>

As the rank increases, the function value decreases since there is more freedom in the model.
There is not necessarily a clear "best" in this case. 
We show best solutions from four different ranks.
Each row corresponds to a component in the rank-r GCP factorization.
The factors for hour, community, and crime are normalized to sum to one,
and the factor for the data shows the magnitude of the component. 
The components are orders by weight, from greatest to least.

**r=6**
<img src="images-2019/rank-6.png" width=500px>

**r=7**
<img src="images-2019/rank-7.png" width=500px>

**r=8**
<img src="images-2019/rank-8.png" width=500px>

**r=9**
<img src="images-2019/rank-9.png" width=500px>

### Visualizing 2019 Factors for Rank 7

We visualize the individual components for the rank-7 factorization. We mark the weekends in grey in the date mode so that we can see weekend-versus-weekday trends more clearly.

**Component 1**<img src="images-2019/rank-7-comp-1.png" width=500px>

**Component 2**<img src="images-2019/rank-7-comp-2.png" width=500px>

**Component 3**<img src="images-2019/rank-7-comp-3.png" width=500px>

**Component 4**<img src="images-2019/rank-7-comp-4.png" width=500px>

**Component 5**<img src="images-2019/rank-7-comp-5.png" width=500px>

**Component 6**<img src="images-2019/rank-7-comp-6.png" width=500px>

**Component 7**<img src="images-2019/rank-7-comp-7.png" width=500px>


## Source and Preprocessing

### Source

This data was compiled by Tamara Kolda in October 2022 using data from the Chicago Data Portal:
https://data.cityofchicago.org/Public-Safety/Crimes-2001-to-Present/ijzp-q8t2.

- The data was downloaded as a CSV file from the Chicago Data Portal with 7,655,983 rows (including header).
- The data was imported to MATLAB as a table, extracting the columns corresponding to `Date`, `PrimaryType`, and `CommunityArea`. 
- Eliminated 613,476 rows with missing CommunityArea
- Eliminated 76 rows with with CommunityArea = 0 (invalid)
- Removed dates before Apr 22, 2002 because these dates had anomonously few crimes (i.e., less than 500)
- Removed 15 crimes types that occured less than 500 times per year on average
- Reordered the crime types by prevalence, so that the first is the most prevalent and the last is the least prevalent
- Created a sparse tensor from the 7,005,683 remaining rows and also saved off information for each mode (title, descriptors, and counts)

### Mapping

The shape files for neighborhoods of Chicago used in the script chicago_component_viz.m were downloaded from here:
https://data.cityofchicago.org/Facilities-Geographic-Boundaries/Boundaries-Community-Areas-current-/cauq-8yn6

<img src="images/Chicago_Community_Areas.svg.png" alt="Map of Numbered Chicago Regions" width=220>

## Acknowledgments

This dataset was inspired by the FROSTT Chicago crime dataset published in [1] and used in [2].

  1. S. Smith, J. W. Choi, J. Li, R. Vuduc, J. Park, X. Liu, and G. Karypis, FROSTT: The Formidable Repository of Open Sparse Tensors and Tools, http://frostt.io/, 2017

  2. T. G. Kolda, D. Hong, Stochastic Gradients for Large-Scale Tensor Decomposition, SIAM Journal on Mathematics of Data Science, 2 (4), 1066-1095, 2020, https://doi.org/10.1137/19M1266265

## Change Log

### Changes in Version 3.0 as compared to Verson 2.0

- Renamed `crime_tensor` to `X` and reorganized the variable `modeinfo` (in `chicago_crime.mat`) to be a struct of cell arrays rather than a cell array of structs.
- Changed calling sequence for `chicago_viz` function and added options to handle subtensors better, like having tickmarks for months as well as years.
- Added function `chicago_subtensor.m` that can extract a portion of the full dataset.
- Added `chicago_crime_2019.mat` that contains only data for 2019 and so is much smaller than the tensor with 20 years of data. 
- Updated `README.md` to describe 2019 dataset and added new figures for both the old and new dataset; added output from GCP-OPT.
