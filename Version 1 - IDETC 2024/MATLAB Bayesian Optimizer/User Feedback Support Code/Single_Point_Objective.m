function y_n = Single_Point_Objective(X)
%prompting the user what the value of the objective function is


while true
    %prompt user and collect value
    prompt = ['What is the value of the objective function at design point' ...
        ,num2str(X),'?'];
    y_n = input(prompt);
    
    %double check with user that the value is what they meant to enter
    prompt_check = ['The Design point ', num2str(X),'leads to an objective' ...
        'of value ', num2str(y_n),' ? [Y/N]'];
    response_check = input(prompt_check,"s");
   
    if strcmp(response_check,"y")
        break
    end

end


end