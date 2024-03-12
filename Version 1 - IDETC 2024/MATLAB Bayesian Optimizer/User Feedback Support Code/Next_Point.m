function out_data = Next_Point(X)
%function that immediately asks the user about the next point, in terms of
%both feasibility and value
%only needs 

[x_a, g_x]  = Single_Point_Feasibility(X);
y_x = Single_Point_Objective(X);

%what this part of the code does is check to see if the point was selected
%to be a maybe. If that is the case, the main g_data MUST BE CONSIDERED
%INFEASIBLE. This is because we do not want the code to believe that the
%point is feasible. Therefore it needs to be split
if height(g_x) > 1
    x_a = x_a(1,:);
    g_x = -1;
    g_a = 1;
else
    x_a = [];
    g_a = [];
end

out_data = struct('y_new',y_x,'g_new',g_x,'x_add_new',x_a,'g_add_new',g_a);


end