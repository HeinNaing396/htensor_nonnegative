function JRmat = jr_idx(G, dims)
%JR_IDX Joint rate index
%   JRmat = JR_IDX(G, [i j]) computes the joint rate index matrix
%   [JR(u^{(i)}_k, u^{(j)}_l)]_{k,l} where i and j denote the i-th and j-th 
%   modes of core tensor G respectively. G is assumed to be in the htensor 
%   or numeric class. 
%
%   See also CORE_TEN, HTENSOR

    d = ndims(G); 
    sz = size(G);

    i = dims(1);
    j = dims(2);

    n1 = sz(i);
    n2 = sz(j);

    JRmat = zeros(n1, n2);
    if ~isnumeric(G)
         dim2ind = G.dim2ind; 
        for l = 1:n2
            for k = 1:n1
                % numerator
                U = G.U; 
                Ui = U{dim2ind(i)}; 
                Uj = U{dim2ind(j)}; 
                U{dim2ind(i)} = Ui(k,:); 
                U{dim2ind(j)} = Uj(l,:); 
                Gij = htensor(G.children, G.dim2ind, U, G.B); 
    
                % denominator (fix j only)
                U = G.U; 
                Uj = U{dim2ind(j)}; 
                U{dim2ind(j)} = Uj(l,:); 
                Gj = htensor(G.children, G.dim2ind, U, G.B); 
    
                JRmat(k,l) = (norm(Gij) / norm(Gj))^2;
            end
        end
    else 
        for l = 1:n2
            for k = 1:n1
                % numerator
                idx = repmat({':'}, 1, d);
                idx{i} = k;
                idx{j} = l;
                num = norm(G(idx{:}), 'fro');
    
                % denominator (fix j only) 
                idx = repmat({':'}, 1, d);
                idx{j} = l;
                denom = norm(G(idx{:}), 'fro');
    
                JRmat(k,l) = (num / denom)^2;
            end
        end
    end 
end