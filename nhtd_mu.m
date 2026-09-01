function X = nhtd_mu(A_ht,varargin)
%NHTD_MU Nonnegative Hierarchical Tucker Decomposition Multiplicative Update
%   X = NHTD_MU(A_HT) computes a nonnegative hierarchical tucker
%   decomposition of htensor A_HT with the default parameters
%
%   X = NHTD_MU(A_HT,VARARGIN) takes in additional arguments:
%       'rank' - the HT ranks of X, an array of size 1 x (2*ndims(A_HT)-1). 
%       The default is 7*ones(1,2*ndims(A_HT)-1)). 
%       'max_it' - the maximum number of iterations. The default is 5000. 
%       'print' - If true, prints out the minimum of the elementwise
%       ratio each leaf/transfer tensor is scaled by to access convergence.
%       If false, this information is omitted. The default is true. 
%
%   See also HTENSOR

    rng(1); % Fixed rng

    p = inputParser; 
    addOptional(p,'rank',7*ones(1,2*ndims(A_ht)-1)); 
    addOptional(p,'max_it',5000); 
    addOptional(p,'print',true)
    parse(p, varargin{:});
    r = p.Results.rank;
    max_it= p.Results.max_it; 
    print = p.Results.print; 
    
    % Properties of htensor A_ht
    is_leaf = A_ht.is_leaf;
    children = A_ht.children;
    parent = A_ht.parent;
    sibling = A_ht.sibling;
    is_left = A_ht.is_left;
    
    % helper function
    rho = 1e-6; 
    function y = pf(x, rho)
        y = x;
        y(x < 0) = rho;
    end
    
    % Initialize X with strictly positive entries
    S = size(A_ht); 
    X = htenrandn(S,'',r); 
    N = X.nr_nodes;  
    for t = 1:N
        if ~is_leaf(t) 
            X.B{t} = pf(X.B{t},rho); 
        else 
            X.U{t} = pf(X.U{t},rho); 
        end
    end 
    
    % Transfer tensors and frames of A_ht and X
    Btilde = A_ht.B;
    Utilde = A_ht.U;
    B = X.B; 
    U = X.U;
    
    % Initialize M and Mtilde
    M = cell(1, N); 
    Mtilde = cell(1,N); 
    % Traverse tree from leaf nodes upwards
    for t = N:-1:1
      M{t} = gramianU(t, is_leaf,children, B,B, U,U, M); 
      Mtilde{t} = gramianU(t, is_leaf,children, B,Btilde, U,Utilde, Mtilde); 
    end
    
    % Initialize G and Gtilde
    G = cell(1, N); G{1} = 1;
    Gtilde = cell(1, N); Gtilde{1} = 1;
    % Traverse tree from root node downwards
    for t=find(is_leaf == false)
        % Child nodes
        t_left  = children(t, 1);
        t_right = children(t, 2);
        % Update G
        G{t_left } = gramianV(t_left, is_left,sibling,parent, ...
            B,B, M,G); 
        G{t_right} = gramianV(t_right, is_left,sibling,parent, ...
            B,B, M,G); 
        % Update Gtilde
        Gtilde{t_left } = gramianV(t_left, is_left,sibling,parent, ...
        B,Btilde, Mtilde,Gtilde);
        Gtilde{t_right} = gramianV(t_right, is_left,sibling,parent, ...
        B,Btilde, Mtilde,Gtilde);
    end
    
    Xprev = X; 
    % From root to leaf
    for it = 1:max_it
        for t = 1:N
            if  ~is_leaf(t)
                % Multiplicative update for transfer tensor
                t1 = children(t,1);
                t2 = children(t,2); 
                % Numerator O(r^4) complexity
                num = ttm(Btilde{t}, Mtilde{t1}, 1);  % mode-1 product
                num = ttm(num, Mtilde{t2}, 2);  % mode-2 product
                num = ttm(num, Gtilde{t}, 3);  % mode-3 product
                % Denominator
                denom = ttm(B{t}, M{t1}, 1);  
                denom = ttm(denom, M{t2}, 2);  
                denom = ttm(denom, G{t}, 3); 
                ratio = pf(num,rho)./denom;
                % Update 
                B{t} = B{t}.*ratio; 
                if t ~= 1
                    % Normalize columns of Ut (nt x rt) by column 2-norm
                    p = parent(t); 
                    gramU = gramianU(t, is_leaf,children, B,B, U,U, M);   
                    D = diag(sqrt(diag(gramU)));
                    % diag(D)
                    invD = diag(diag(D).^(-1)); 
                    B{t} = ttm(B{t},invD,3); 
                    if is_left(t)
                        B{p} = ttm(B{p},D,1); 
                    else
                        B{p} = ttm(B{p},D,2);   
                    end
                    % Update M and Mtilde at node t
                    M{t} = gramianU(t, is_leaf,children, B,B, U,U, M); 
                    Mtilde{t} = gramianU(t, is_leaf,children, ...
                        B,Btilde, U,Utilde, Mtilde); 
                end 
                % Update G and Gtilde at children of t
                % Update G, dependent on M{t}
                G{t1} = gramianV(t1, is_left,sibling,parent, ...
                    B,B, M,G);
                G{t2} = gramianV(t2, is_left,sibling,parent, ...
                    B,B, M,G);
                % Update Gtilde, dependent on Mtilde{t}
                Gtilde{t1} = gramianV(t1, is_left,sibling,parent, ...
                    B,Btilde, Mtilde,Gtilde);
                Gtilde{t2} = gramianV(t2, is_left,sibling,parent, ...
                    B,Btilde, Mtilde,Gtilde);
            else % t is a leaf
                % Multiplicative update for leaves
                ratio = pf(Utilde{t}*Gtilde{t}',rho)./(U{t}*G{t}); 
                U{t} = U{t}.*ratio;
                % Normalize columns of Ut (nt x rt) by column 2-norm
                p = parent(t); 
                U{t} = U{t}./vecnorm(U{t}); 
                D = diag(vecnorm(U{t})); 
                if is_left(t)
                    B{p} = ttm(B{p},D,1); 
                else
                    B{p} = ttm(B{p},D,2);   
                end
                % Update M and Mtilde at node t
                M{t} = U{t}'*U{t}; 
                Mtilde{t} = U{t}'*Utilde{t}; 
            end 
            if t ~= 1
                % Update G and Gtilde at sibling of node t
                % G{sibling(t)} <- B{parent}, G{parent}, M{t}
                % Gtilde{sibling(t)} <- B{parent}, Gtilde{parent}, Mtilde{t}, Btilde{parent}
                s = sibling(t); 
                G{s} = gramianV(s, is_left,sibling,parent, ...
                    B,B, M,G);
                Gtilde{s} = gramianV(s, is_left,sibling,parent, ...
                    B,Btilde, Mtilde,Gtilde);
            end
            if print 
                if mod(it,1000) == 0
                    fprintf('it = %d, t = %d',it,t); 
                    min(ratio(:))
                end
            end
        end 

        % stopping criteria, check every 500 iterations
        if mod(it,500) == 0
            Xprev = X; 
        end

        if mod(it,500) == 1
            % Update X
            for node = 1:N
                if is_leaf(node)
                    X.U{node} = U{node};
                else 
                    X.B{node} = B{node}; 
                end 
            end 
            rel_err = norm(X - Xprev)/norm(Xprev); 
            % Check relative error between approximations
            if rel_err < 1e-6
                return; 
            end 
        end

    end
    % Reassign transfer tensors and leaves of X.
    for t = 1:N
        if is_leaf(t)
            X.U{t} = U{t};
        else 
            X.B{t} = B{t}; 
        end 
    end 

end 