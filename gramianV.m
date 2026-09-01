function Gt = gramianV(t, is_left, sibling, parent, ...
    B, Btilde, Mtilde, Gtilde)
%GRAMIANV Helper function for NHTD_MU.
%   Gt = GRAMIANV(t, IS_LEFT, SIBLING, PARENT, B, BTILDE, MTILDE, GTILDE) 
%   computes the gramian V_t'\tilde{V}_t where:
%       t - The tree node t from tree T of the htensor X. 
%       IS_LEFT - A logical array indicating which nodes of T are left
%       nodes. 
%       SIBLING - X.sibling. An array where each row contains the indices 
%       of the siblings for node t corresponding to the row index, 
%       PARENT - X.parent. An array where each row contains the indices of
%       the parents for node t corresponding to the row index. 
%       B - X.B, an array of transfer tensors of X. 
%       BTILDE - A_ht.B, an array of transfer tensors of A_HT. 
%       MTILDE - An array of gramians U_t' \tilde{U}_t for each t in T.
%       GTILDE - An array of gramians V_t'\tilde{V}_t for each t in T.
%
%   See also HTENSOR 

    p = parent(t); 
    s = sibling(t);

    B_mod = ttm(Btilde{p}, Gtilde{p}, 3); 
    if is_left(t)
        B_mod_left = ttm(B_mod, Mtilde{s}, 2);
        Gt = ttt(B{p}, B_mod_left, [2 3], [2 3], 1, 1);
    else 
        B_mod_right = ttm(B_mod, Mtilde{s} , 1);
        Gt = ttt(B{p}, B_mod_right, [1 3], [1 3], 2, 2);
    end 
end