function X_out = Exhaustive_Search_Sampler(lb, ub, sz)
%this function takes in the bounds and steps for an n_dimensional set of
%independent variables to create the sample points necessary for the
%exhaustive search of the bayesian optimization algorithm
%essentially a modular version of combvec, without manually entering them
%
%lb: 1 x N vector of variable lower bounds [a1, b1 .... x1]
%ub: 1 x N vector of variable upper bounds [a2, b2 .... x2]
%sz: 1 x N vector of variables steps       [sa, sb .... sx]
%
%outputs:
%X_out: sample points needed 


N_var = length(lb); 
rngcntrl = cell(1,N_var);

for i = 1:N_var
    rngcntrl{i} = lb(i):sz(i):ub(i);
end

%create the samples by either combvec (if 2D) or referering back if more
samps = combvec(rngcntrl{1},rngcntrl{2});

if N_var > 2
    for i = 3:N_var
        samps = combvec(samps, rngcntrl{i});
    end
end

X_out = samps';


end