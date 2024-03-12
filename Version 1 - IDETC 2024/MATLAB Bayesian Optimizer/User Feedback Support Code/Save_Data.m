function Save_Data(data, filename)
%this is the function that is able to save the data at the end of the round
%user inputs the data (which is a struct) which is then separated and
%stored into the excel sheet. The trick with this is that the formatting
%requires create x1,x2,...,xn column names, which is a bit tricky 

% Pull out the data
x_obj = data.xs;
x_cnst_add = data.x_add;
f_obj = data.obj;
g_cnst = data.cnst;
g_cnst_add = data.cnst_add;

%take it and turn it into sheets 
obj = [x_obj, f_obj];
cnst = [x_obj,g_cnst];
cnst_add = [x_cnst_add,g_cnst_add];

%create the headers for the tables
x_label = cell(1,width(x_obj));
for i =1:width(x_obj)
    x_label{i} = strcat('x',num2str(i));   
end

%turn into tables
obj_table = array2table(obj, "VariableNames",[x_label,{'f'}]);
cnst_table = array2table(cnst, "VariableNames",[x_label,{'g'}]);
cnst_add_table =array2table(cnst_add, "VariableNames",[x_label,{'g'}]);

%save the file 
writetable(obj_table,filename,'Sheet','Obj_Values')
writetable(cnst_table,filename,'Sheet','Cnst_Values')
writetable(cnst_add_table,filename,'Sheet','Additional_Points')

end