function Ut = frameU(t,X)
%FRAMEU Frame/matrix U_t
%   Ut = FRAMEU(t,X) computes the matrix U_t such that X^{(t)} = U_t V_t' 
%   given node t and htensor X. 

    B = X.B; 
    U = X.U; 
    children = X.children;
    is_leaf = X.is_leaf;
    if is_leaf(t)
        Ut = U{t}; 
        return; 
    end
    t_left = children(t,1); 
    t_right = children(t,2); 
    Ut_right = frameU(t_right,X); 
    Ut_left = frameU(t_left,X);
    Bt = reshape(B{t},[],size(B{t},3)); 
    Ut = kron(Ut_right,Ut_left)*Bt; 
end 