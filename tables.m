function tables(G, labels, mode, idx_set)
%TABLES Tables of clusters
%   TABLES(G, LABELS, MODE, IDX_SET) outputs tables of clusters for joint 
%   rate index matrices JR_IDX(G, [i MODE]) where i is in array idx_set. 
%   'labels' is a cell array of the labels of the modes of A_HT. G is assumed 
%   to be in the htensor or numeric class. 
%
%   See also CLUSTER, JR_IDX

    loc = ismember(idx_set,mode); 
    for i = find(~loc)
        [clusters, groups] = cluster(G,[idx_set(i),mode]);
        groups = string(cellfun(@(x) strjoin(string(x), ','), groups, 'UniformOutput', false)); 
        T = table(clusters,groups,'VariableNames',{labels{idx_set(i)},labels{mode}}); 
        fig = uifigure('Visible','on');
        uit = uitable(fig, 'Data', T); 
        drawnow;
        frame = getframe(fig);
        filename = ['table_' labels{idx_set(i)} '_' labels{mode} '.png'];
        imwrite(frame.cdata, filename);
    end
end