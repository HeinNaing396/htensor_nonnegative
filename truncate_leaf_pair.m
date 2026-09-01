function Y = truncate_leaf_pair(X, t_left, t_right)
%TRUNCATE_LEAF_PAIR Truncate leaf pair
%   Y = TRUNCATE_LEAF_PAIR(X, T_LEFT, T_RIGHT) truncates the leaves t_left
%   and t_right, which are the left and right child nodes respectively of the 
%   same parent node t from tree T associated to htensor X. Returns htensor
%   Y associated to the truncated tree. 

    %Update children
    remove = [t_left t_right];
    keep = setdiff(1:size(X.children,1), remove);
    newIndex = zeros(1, size(X.children,1));
    newIndex(keep) = 1:numel(keep); 
    y.children = X.children(keep, :); 
    mask = y.children ~= 0;
    y.children(mask) = newIndex(y.children(mask));
    
    %Update dim2ind
    parent = find(ismember(X.children,[t_left t_right],'rows')); 
    y.dim2ind = newIndex(X.dim2ind);
    y.dim2ind(y.dim2ind == 0) = []; 
    y.dim2ind = sort([newIndex(parent),y.dim2ind],'ascend'); 
    
    %Update U
    y.U = X.U(keep);
    Bp = reshape(X.B{parent},[],size(X.B{parent},3));
    y.U{newIndex(parent)} = kron(X.U{t_right}, X.U{t_left})*Bp; % add frame
    
    %Update B
    y.B = X.B(keep); 
    y.B{newIndex(parent)} = []; %remove transfer tensor
    
    %Construct htensor
    Y = htensor(y.children,y.dim2ind,y.U,y.B); 
end