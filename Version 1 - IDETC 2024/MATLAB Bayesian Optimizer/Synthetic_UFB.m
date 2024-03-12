%% Load in the data

clear data
data = Load_Data('Synth_Data_2.xlsx');
%data = Load_Data('Synth_Iteration_20.xlsx');
data = Load_Data('Box_Synth_Iteration_3.xlsx');

data_log_transform = true;


search_bnds = [4 30 2;200 280 10];

%% Prompt user on if they want to add more design points 

[x_add, g_add] = User_Feedback(data.xs);

%one day I'll streamline this. One day..... 
data.x_add = [data.x_add;x_add];
data.cnst_add = [data.cnst_add;g_add];


%% NOTE: Using Log transform on the input data
if data_log_transform == true
    data.obj = log(data.obj);
end

%% Apply bayesian optimization to give a next point
x_next = Bayesian_Optimizer(data.xs,data.obj,[data.xs;data.x_add],[data.cnst;data.cnst_add],search_bnds,10);

%% Prompt user on that design point
next_data = Next_Point(x_next);

data.xs = [data.xs; x_next];
data.x_add = [data.x_add; next_data.x_add_new];
data.cnst = [data.cnst; next_data.g_new];
data.cnst_add = [data.cnst_add; next_data.g_add_new];

if data_log_transform == true
    data.obj = round(exp(data.obj));
end


data.obj = [data.obj; next_data.y_new];



%% Save that data back to the spreadsheets, user can then run the file again



Save_Data(data, 'Box_Synth_Iteration_4.xlsx')