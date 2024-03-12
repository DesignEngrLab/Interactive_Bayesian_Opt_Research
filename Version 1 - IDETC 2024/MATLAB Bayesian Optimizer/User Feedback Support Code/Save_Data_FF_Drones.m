function Save_Data_FF_Drones(data, filename)
%this is the function that is able to save the data at the end of the round
%basically, this is easier than the other way I did it
%f**k I can be so stupid sometimes

%rearrange the shape of the data and such so it can be stored
data = rmfield(data,'f_min_feas'); %idk if this is even needed?




sheet_names = {'Shared_X','Obj_Values','Cnst_Contain','Cnst_UFB','Cnst_Additional_X','Cnst_Additional_G'};


writematrix(data.xs,filename,'Sheet',sheet_names{1})
writematrix(data.obj_orig,filename,'Sheet',sheet_names{2})
writematrix(data.cnst_c_orig,filename,'Sheet',sheet_names{3})
writematrix(data.cnst_u,filename,'Sheet',sheet_names{4})
writematrix(data.x_add,filename,'Sheet',sheet_names{5})
writematrix(data.cnst_add,filename,'Sheet',sheet_names{6})





end