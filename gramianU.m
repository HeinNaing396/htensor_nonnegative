function Mt = gramianU(t, is_leaf, children, B, Btilde, U, Utilde, Mtilde)
%GRAMIANU  Helper function for NHTD_MU.
%   Mt = GRAMIANU(t, IS_LEFT, CHILDREN, B, BTILDE, U, UTILDE, MTILDE) computes 
%   the gramian U_t'\tilde{U}_t where: 
%       t - The tree node t from tree T of the htensor X. 
%       IS_LEFT - A logical array indicating which nodes of T are left
%       nodes. 
%       CHILDREN - X.children. An array where each row contains the indices 
%       of the children for node t corresponding to the row index. 
%       B - X.B, an array of transfer tensors of X. 
%       BTILDE - A_ht.B, an array of transfer tensors of A_HT. 
%       U - X.U, an array of leaves of X.
%       UTILDE - A_ht.U, an array of leaves of A_HT. 
%       MTILDE - An array of gramians U_t' \tilde{U}_t for each t in T.
%
%   See also HTENSOR

    if is_leaf(t)
        Mt = full(U{t}'*Utilde{t});
    else
        t_left  = children(t, 1);
        t_right = children(t, 2);
        % M_t = Bx_t' * (M_tx kron M_ty) * By_t
        B_ = ttm(Btilde{t}, {Mtilde{t_left}, Mtilde{t_right}}, [1 2]);
        Mt = ttt(B{t}, B_, [1 2], [1 2], 3, 3);
    end
end 