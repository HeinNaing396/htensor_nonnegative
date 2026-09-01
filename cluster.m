function [clusters, groups] = cluster(G,dims)
%CLUSTER Helper function for tables.m
%   [CLUSTERS, GROUPS] = CLUSTER(G, [i j]) computes the clusters based on
%   which features associated to the i-th mode of core tensor G are the most
%   dominant for the features associated to the j-th mode of G. G is assumed 
%   to be in the htensor or numeric class. 
% 
%   Outputs: 
%       CLUSTERS - An array where CLUSTERS(k) is the label of the dominant 
%       feature for features in GROUPS{k}. 
%       GROUPS - A cell array where GROUPS{k} are the features for which the
%       feature labelled CLUSTERS(k) is dominant. 
%
%   See also TABLES, JR_IDX, HTENSOR

    i = dims(1);
    j = dims(2);
    [~, labels] = max(jr_idx(G,[i,j]), [], 1);
    [clusters, ~, idx] = unique(labels', 'rows', 'stable');
    idx = idx(:);
    groups = accumarray(idx, (1:numel(idx))', [], @(x){x});
end