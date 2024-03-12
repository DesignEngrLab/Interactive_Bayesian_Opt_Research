function [x_o, g_x] = Single_Point_Feasibility(X)
%prompting the user to answer if new design point is feasible
%future versions should include ways to display 
%
%outputs:
%x_o: indpendent points for the surrogate (this helps with handling "maybes")
%g_x: values for the feasibility surrogate



g_x = 0;
while true
    %prompt and collect feasibility feedback
    prompt = ['Is the following design point feasible [Y], infeasible [N],' ...
        ' or unknown [M]?  ', num2str(X), '  :'];
    response = input(prompt, 's');

    if strcmpi(response,"y")
        g_x = 1;
        x_o = X;
        check = 'feasible';

    elseif strcmpi(response,"n")
        g_x = -1;
        x_o = X;
        check = 'infeasible';

    elseif strcmpi(response,"m")
        g_x = [1;-1];
        x_o = [X;X];
        check = 'unknown/unsure feasible';

    %help the user or allow the loop to continue until they've properly
    %entered things
    elseif strcmpi(response,"help")
        fprintf("Y means that point is feasibile (adding a 1 to that point in the surrogate), \nN means the point is infeasible (adding a -1 to the surrogate), \nand M means the point has an unknown response (adding both a 1 and a -1 to that, \nmaking it 50%% feasible). \n \n")
    else
        fprintf("Please type Y, N, or M (not case sensitive). Type HELP for more details. ")
    end


    %double check response from the user.
    if g_x ~= 0
        prompt2 = ['The design point ',num2str(X), ' is considered ',check, ' ? [Y/N]'];
        response2 = input(prompt2,"s");
        if strcmpi(response2, "Y")
            break
        end

    end

end





end