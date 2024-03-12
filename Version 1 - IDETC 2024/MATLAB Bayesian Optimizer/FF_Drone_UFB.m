%Fire Fighting Drones User-Feedback Code
%text interface is cruder at this time and at this time requires more
%manual additions from copying in data from agents.jl

%% Load in data, establish the design bounds and discrete design decision


data = Load_Data_FF_Drones("FF_Iteration_25.xlsx");

bnds = [400 5 3 150;1900 17 15 510;250 2 2 60]';

%this is here in case there's a need to utilize log transformation on the
%data. This is only done if there are issues with the range, but we will
%see
data_log_transform = true;

%% Prompt the user if they want to add more design points 

[x_add, g_add] = User_Feedback(data.xs,3);


%one day I'll streamline this. One day..... 
data.x_add = [data.x_add;x_add];
data.cnst_add = [data.cnst_add;g_add];

%% Note: if you're using log transformation on the data to make it easier


if data_log_transform == true
    data.obj = log(data.obj);
end

%% Find the next desired sample point via bayesian optimization
%
tic
x_next = Bayesian_Optimizer_FF(data.xs, data.obj,data.cnst_c,[data.xs;data.x_add],[data.cnst_u;data.cnst_add], bnds, data.f_min_feas, 4)
toc
%}

%% prompt user on next design point.

next_data = Next_Point(x_next);

data.xs = [data.xs; x_next];
data.x_add = [data.x_add; next_data.x_add_new];
data.cnst_u = [data.cnst_u; next_data.g_new];
data.cnst_add = [data.cnst_add; next_data.g_add_new];

if data_log_transform == true
    data.obj = round(exp(data.obj));
end
%% due to time constraint issues, this one will just save the file now and
%then you can just copy in the additional information from the ABM
%simulation

Save_Data_FF_Drones(data,'FF_Iteration_26.xlsx')

