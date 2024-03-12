function data = Load_Data_FF_Drones(filename)
%loads in and parses data
%attempting to generalizing things better in this version
%eventually, a easy to use Bayesian Optimization Code will be on the DEL
%Gitrepo
%but for now: it's designed for the version at hand, with a simple set of
%two constraints (user and containment) 
%it also has to take the data and for certain things and reorganize it
%since, for both the constraint and the objective, a single x leads to
%multiple outputs (why did I do this to myself)

sheet_names = {'Shared_X','Obj_Values','Cnst_Contain','Cnst_UFB','Cnst_Additional_X','Cnst_Additional_G'};
struct_names = {'xs', 'obj', 'cnst_c', 'cnst_u', 'x_add', 'cnst_add'};

sheet = cell(1,length(sheet_names));

for i = 1:length(sheet_names)
    readmatrix(filename, 'Sheet',sheet_names{i});

    sheet{i} = readmatrix(filename, 'Sheet',sheet_names{i});
end

data = cell2struct(sheet,struct_names,2);

%first, find the minimum feasible point based on overlap and percentage of
%successful containments
data.obj_orig = data.obj;
data.cnst_c_orig = data.cnst_c;
data.obj = mean(data.obj,2);
g_mu = mean(data.cnst_c, 2);
index_feasible = intersect(find(g_mu>=0),find(data.cnst_u==1));
[f_min_feas, index_min_feas] = min(data.obj(index_feasible))
index_min_feas = index_feasible(index_min_feas);
data.f_min_feas = f_min_feas;
data.f_min_std = std(data.obj(index_min_feas,:));
data.f_min_med = median(data.obj(index_min_feas,:));
data.f_min_design = data.xs(index_min_feas,:);

g_fire = zeros(height(data.xs),1);

for i = 1:height(data.xs)
    if g_mu(i) >= 0
        g_fire(i) = 1;
    else
        g_fire(i) = -1;
    end
end

data.cnst_c = g_fire;



end