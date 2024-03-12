function x_next = Bayesian_Optimizer_FF(x_obj_cnst, y_obj, y_cnst,x_UFB, y_UFB, bnds, min_feasible, varargin)
%uses a standard GP regression model to represent the objective function
%uses a expectation propagation as the user-feedback constraint
%note: future versions will (hopefully) include options for addtional
%regression constraints and changes to the 
%this is specifically designed for the firefighting case study
%should I have generalized it even more for this case at the beginning?
%yes
%but at this point, it's too late and I need to get it out in time
%keep a lookout for the super best bayesian optimizer ever!
%
%key: d is dimensions, N & M are training sample length for obj and cnst
%
%inputs: 
%x_obj: training x values for objective function                (N x d)
%y_obj: training y/f(x) values for objective function           (N x d)
%x_cnst: training x values for user-feedback constraint         (M x d)
%y_cnst: training y values for user-feedback constraint         (M x d)
%x_UFB: training x values for user-feedback constraint          (M x d)
%y_UFB: training y values for user-feedback constraint          (M x d)
%bnds: [lower bound, upper bound, spacing;_] for each dimension (d x 3) 

%check vargin to see if user specifies changing the covariance matrix size
if length(varargin)>0
    SN = varargin{1};
else
    SN = 5;
end


%pulling out some constants (there's some issue with this check, FIX LATER)

d = width(x_obj_cnst);
%{
if d ~= width(y_obj) || ( d~=width(x_cnst) || (d~=width(y_cnst) || d~=height(bnds) ))
    disp('dimensions do not agree, error about to be thrown')
end
%}



%create a sparse covariance matrix for the expectation propagation
%this allows you to handle significantly larger datasets
%use vargins to control if this save covar is used for regression datasets
%IE, turn u_quant == true
%modifies the bounds and uses a subdivision of SN points (not to the edge)
%scale sparse covar based on number dimensions
scd = (bnds(:,2) - bnds(:,1)) / (SN + 1);
sclb = bnds(:,1) + scd/2;
scub = bnds(:,2) - scd/2;

if d > 1
    spcov = exhaustive_search_sampler(sclb, scub, scd);
else
    spcov = (sclb:scd:scub)';
end

%making hyperparameters for the objective function


obj_fns = {@meanConst, @covSEard, @likGauss, @infGaussLik};
obj_hyp = struct('mean', 0, 'cov', ones(d + 1, 1),'lik', -1);


%making hyperparameters for the classification constraint
cnst_fns= {@meanConst, {@apxSparse,{@covSEard},spcov}, @likErf, @infEP};
cnst_obj = struct('mean', 0, 'cov', ones(d + 1, 1));


%fit the regression/objective function model
obj_hyp = minimize_noprint(obj_hyp, @gp, -100, obj_fns{4}, obj_fns{1}, obj_fns{2}, obj_fns{3}, x_obj_cnst, y_obj);
fprintf("fit objective GP, moving on to fitting constraint GP \n")

%fit the classification constraint captured from the model
cnst_hyp_cnst = minimize_noprint(cnst_obj, @gp, -100, cnst_fns{4}, cnst_fns{1}, cnst_fns{2}, cnst_fns{3}, x_obj_cnst, y_cnst);
fprintf("fit secondary fire constraint, moving on to fiting UFB constraint \n")

%fit the classification constraint captured from user feedback
cnst_hyp_UFB= minimize_noprint(cnst_obj, @gp, -100, cnst_fns{4}, cnst_fns{1}, cnst_fns{2}, cnst_fns{3}, x_UFB, y_UFB);
fprintf("fit UFB constraint GP, moving on to minizing probability of feasibility \n")




%using an exhaustive search to find the next point vs minimizing PF*EI

% -- pull out desired points from the models for next point selection
if d > 1
    X = exhaustive_search_sampler(bnds(:,1), bnds(:,2), bnds(:,3));
else
    X = (bnds(:,1):bnds(:,3):bnds(:,2))';
end

%remove X values that are in the input values (prevent optimizer from
%selecting previous points)

%rewrite this later...
index_overlap_remove = ismember(X, x_obj_cnst,'rows');
X = X(~index_overlap_remove,:);





% -- prepping data for PF*EI search
%objective
%escape constraint
%UFB constraint
[fmu, fs2] = gp(obj_hyp, obj_fns{4}, obj_fns{1}, obj_fns{2}, obj_fns{3}, x_obj_cnst, y_obj, X, ones(length(X),1));
[gmu_cnst, gs2_cnst, gmu_latent_cnst, gs2_latent_cnst] = gp(cnst_hyp_cnst, cnst_fns{4}, cnst_fns{1}, cnst_fns{2}, cnst_fns{3}, x_obj_cnst, y_cnst, X, ones(length(X),1));
[gmu_UFB, gs2_UFB, gmu_latent_UFB, gs2_latent_UFB] = gp(cnst_hyp_UFB, cnst_fns{4}, cnst_fns{1}, cnst_fns{2}, cnst_fns{3}, x_UFB, y_UFB, X, ones(length(X),1));

fs = sqrt(fs2);
gs_latent_cnst = sqrt(gs2_latent_cnst);
gmu_latent_cnst = -gmu_latent_cnst;

gs_latent_UFB = sqrt(gs2_latent_UFB);
gmu_latent_UFB = -gmu_latent_UFB; %taking the negative so PF works since that's designs for negative == feasible

%{
mean(fmu)
mean(gmu_latent_UFB)
mean(gmu_latent_cnst)
mean(fs)
mean(gs_latent_UFB)
mean(gs_latent_cnst)
%}


% -- PF*EI search
PFEI = zeros(length(X),1);

for i = 1:length(X)
    if fs(i) > 0
        z = (min_feasible - fmu(i))/fs(i);
        EI = (min_feasible - fmu(i))*normcdf(z) + fs(i)*normpdf(z); %expected improvement
        POF_1 = normcdf( - gmu_latent_cnst(i) /gs_latent_cnst(i));%probability of feasibility for contained constraint
        POF_2 = normcdf( - gmu_latent_UFB(i) /gs_latent_UFB(i));%probability of feasibility for UFB
        PFEI(i) = EI*POF_1*POF_2; %multiplication for finding points of higher EI and POF
    else
        PFEI(i) = 0;
    end

end

%find the point that should maximize PFEI. Then return the next X value for
%the user to test and provide feedback on
[eipof_max, index_max] = max(PFEI);


x_next = X(index_max,:);


end

