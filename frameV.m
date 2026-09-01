function Vt = frameV(t,X)
%FRAMEV Frame/matrix V_t
%   Vt = FRAMEV(t,X) computes the matrix V_t such that X^{(t)} = U_t V_t' 
%   given node t and htensor X. 

    B = X.B;
    is_left = X.is_left;
    parent = X.parent;
    sibling = X.sibling;
    if t == 1
        Vt = 1; 
        return; 
    end 
    p = parent(t);
    s = sibling(t); 
    if is_left(t)
        Bp = permute(B{p},[2,3,1]); 
    else 
        Bp = permute(B{p},[1,3,2]);
    end
    Bp = reshape(Bp,[],size(Bp,3)); 
    Vt = kron(frameV(p,X),frameU(s,X))*Bp; 
end 