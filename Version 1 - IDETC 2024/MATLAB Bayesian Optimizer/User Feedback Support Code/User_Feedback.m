function [x_out, g_out] = User_Feedback(X,varargin)
%support function for adding in additional regions or design points of
%feasibility or infeasibility.
%I need to add in things to make it easier to catch input issues on the
%user side of things... :(
%I can do that when i get to the point of testing with people later on
%only purpose of X is for dimensionality checks

while true
    prompt = 'Would you like to add feasibility info? [Y/N] ';
    response = input(prompt,"s");

    if strcmpi(response,"y")
        add_points = true;
        break
    elseif strcmpi(response,"n")
        add_points = false;
        break
    else
        fprintf("please type Y or N, not case sensitive.\n")
    end

end

x_out = [];
g_out = [];

if add_points == true %yes I know this isn't needed, but adds clarity to code
    
    %first, go through and collect single set of design points
    while true
        prompt_i = 'Would you like add an a single design target? [Y/N] ';
        response_i = input(prompt_i,"s");
        if strcmpi(response_i,"y")
            prompt_i_n = 'What should that value be? ';
            x_i = input(prompt_i_n); %fix something later to check it's a number or a vector...
           [x_o_i, g_x_i] = Single_Point_Feasibility(x_i);
           x_out = [x_out;x_o_i];
           g_out = [g_out;g_x_i]
        elseif strcmpi(response_i,"n")
            break
        else
            fprintf("please type Y or N, not case sensitive.\n")
        end
    end


    while true
        [x_o_b, g_o_b] = Bounding_Box(X,varargin);
        
        x_out = [x_out;x_o_b];
        g_out = [g_out;g_o_b];
        if isempty(x_o_b)
            break
        end
    end
    

end



end