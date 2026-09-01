function c = contributions(G)
%CONTRIBUTIONS Contributions of the features
%   C = CONTRIBUTIONS(G) computes the contributions of the features given 
%   core tensor G. G is assumed to be in the htensor or numeric class. 
%
%   See also CORE_TEN, HTENSOR

    d = ndims(G);
    c = cell(d,1); 
   
    if ~isnumeric(G)
        dim2ind = G.dim2ind; 
        normG = norm(G); 
        for i = 1:d
            ci = zeros(size(G.U{dim2ind(i)},2),1); 
            for k = 1:size(G.U{dim2ind(i)},2)
                U = G.U;               
                Ui = U{dim2ind(i)}; 
                U{dim2ind(i)} = Ui(k,:); 
                Gi = htensor(G.children, G.dim2ind, U, G.B); 
                ci(k) = (norm(Gi)/normG)^2;
            end
            c{i} = ci; 
        end 
    else 
        for i = 1:d
            normG = norm(G, 'fro');
            c{i} = sum(G.^2, setdiff(1:d, i));
            c{i} = c{i}(:)./normG.^2;
        end
    end
end 