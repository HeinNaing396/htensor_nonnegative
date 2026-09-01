function G = core_ten(X)
%CORE_TEN Core tensor
%   G = CORE_TEN(X) computes the core tensor G as a htensor given htensor X. 
%
%   See also HTENSOR
    
    N = X.nr_nodes; 
    is_leaf = X.is_leaf; 
    U = cell(1,N); 
    
    for t = 1:N
        if is_leaf(t)
           U{t} = eye(size(X.U{t},2)); 
        end 
    end 
    G = htensor(X.children, X.dim2ind, U, X.B); 
end 