function Synthetic_Results_Plotting(x_obj, y_obj, x_cnst, y_cnst, bnds,varargin)

%uses a standard GP regression model to represent the objective function
%uses a expectation propagation as the user-feedback constraint
%note: future versions will (hopefully) include options for addtional
%regression constraints and changes to the 
%
%key: d is dimensions, N & M are training sample length for obj and cnst
%
%inputs: 
%x_obj: training x values for objective function                (N x d)
%y_obj: training y/f(x) values for objective function           (N x d)
%x_cnst: training x values for user-feedback constraint         (M x d)
%y_cnst: training y values for user-feedback constraint         (M x d)
%bnds: [lower bound; upper bound; spacing] for each dimension   (d x 3) 

%check vargin to see if user specifies changing the covariance matrix size
if length(varargin)>0
    SN = varargin{1};
else
    SN = 5;
end

%let's flip this around for plotting since

%perform a data verificaiton process with potential NaN values (if no
%additional values are given yet
[row_rem, c] = find(isnan(x_cnst));
x_cnst(row_rem,:) = [];
y_cnst(row_rem,:) = [];

%pulling out some constants

d = width(x_obj);

if d ~= width(y_obj) || ( d~=width(x_cnst) || (d~=width(y_cnst) || d~=height(bnds) ))
    disp('dimensions do not agree, error about to be thrown')
end


%making hyperparameters for the objective function
obj_fns = {@meanConst, @covSEard, @likGauss, @infGaussLik};
obj_hyp = struct('mean', 0, 'cov', ones(d + 1, 1),'lik', -1);



%create a sparse covariance matrix for the expectation propagation
%this allows you to handle significantly larger datasets for
%classification, such as the necessary boxing point datapoints
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

%making hyperparameters for the classification constraint
cnst_fns= {@meanConst, {@apxSparse,{@covSEard},spcov}, @likErf, @infEP};
cnst_obj = struct('mean', 0, 'cov', ones(d + 1, 1));


%fit the models
obj_hyp = minimize_noprint(obj_hyp, @gp, -100, obj_fns{4}, obj_fns{1}, obj_fns{2}, obj_fns{3}, x_obj, y_obj);
fprintf("fit objective GP, moving on to fitting constraint GP \n")
cnst_hyp= minimize_noprint(cnst_obj, @gp, -100, cnst_fns{4}, cnst_fns{1}, cnst_fns{2}, cnst_fns{3}, x_cnst, y_cnst);
fprintf("fit constraint GP, moving on to minizing probability of feasibility \n")




%using an exhaustive search to find the next point vs minimizing PF*EI

% -- pull out desired points from the models for next point selection
if d > 1
    X = exhaustive_search_sampler(bnds(:,1), bnds(:,2), bnds(:,3));
else
    X = (bnds(:,1):bnds(:,3):bnds(:,2))';
end

% -- finding best known feasible design
index_feasible = find(y_cnst == 1);
index_overlap = ismember(x_obj, x_cnst(index_feasible,:),"rows");
min_feasible = min(y_obj(index_overlap));

% -- prepping data for PF*EI search
[fmu, fs2] = gp(obj_hyp, obj_fns{4}, obj_fns{1}, obj_fns{2}, obj_fns{3}, x_obj, y_obj, X, ones(length(X),1));
[gmu, gs2, gmu_latent, gs2_latent] = gp(cnst_hyp, cnst_fns{4}, cnst_fns{1}, cnst_fns{2}, cnst_fns{3}, x_cnst, y_cnst, X, ones(length(X),1));

fs = sqrt(fs2);
gs_latent = sqrt(gs2_latent);
gmu_latent = -gmu_latent; %taking the negative so PF works since that's designs for negative == feasible

%Plotting the results

figure()
x_p = reshape(X(:,1),[length(bnds(1,1):bnds(1,3):bnds(1,2)),length(bnds(2,1):bnds(2,3):bnds(2,2))]);
y_p = reshape(X(:,2),[length(bnds(1,1):bnds(1,3):bnds(1,2)),length(bnds(2,1):bnds(2,3):bnds(2,2))]);
ax1 = axes;
surf(ax1,x_p,y_p,reshape(log(fmu),size(x_p)),EdgeColor="none")
xlim([4 30])
colormap(ax1, "parula")
%view(-90,-90)
view(2)
hold on

ax2 = axes;
%surf(ax2,x_p,y_p,reshape(-gmu_latent,size(x_p)),'FaceAlpha',0.25,EdgeColor="none");
surf(ax2,x_p,y_p,reshape(gmu,size(x_p)),'FaceAlpha',0.25,EdgeColor="none")
hold on
[M,c] = contour3(ax2,x_p,y_p,reshape(gmu,size(x_p)),60);
%[M,c] = contour3(ax2,x_p,y_p,reshape(-gmu_latent,size(x_p)),60);
plot3(ax2,x_cnst(:,1), x_cnst(:,2),y_cnst,'.r','MarkerSize',20)

c.LineWidth = 0.5;
colormap(ax2,"gray")
%view(-90,-90)
view(2)
xlim([4 30])
ax2.Visible='off';
ax2.XTick=[];
ax2.YTick=[];
linkaxes([ax1,ax2])



end