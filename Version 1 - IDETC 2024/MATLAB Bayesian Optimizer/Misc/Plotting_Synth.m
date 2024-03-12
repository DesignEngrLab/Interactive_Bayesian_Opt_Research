
%data  = Load_Data('Synth_Iterations.xlsx');

data = Load_Data('Synth_Iteration_21.xlsx'); %THIS IS THE CORRECT ONE 21st iteration, 
%data = Load_Data('Box_Synth_Iteration_4.xlsx');
data2 = data;
data.obj = log(data.obj);

search_bnds = [3 31 .1;195 285 1];

%add in:
%feasibility 



[ax1, ax2]  = Synthetic_Results_Plotting_Detail([12,230],data.xs,data.obj,[data.xs;data.x_add],[data.cnst;data.cnst_add],search_bnds,10);

%%
fig = gcf;
fig.Units = 'inches';
