function [x_o, g_o] = Bounding_Box(X,varargin)
%allows the user to add in bounding boxes of feasible and infeasible areas
%input:
%X, previous design variable (only purpose to establish the dimensionality)

if ~isempty(varargin{1})
    divs = varargin{1}{1} - 1;
else
    divs = 4; %5 divisions, means 4 necessary for linspace
end



%see if the user wants to input
while true
    prompt = 'Would you like to add in a bounding box of feasibility info? [Y/N] ';
    response = input(prompt,"s");

    if strcmpi(response,"y")
        allow_bounding = true;
        break

    elseif strcmpi(response,"n")
        x_o=[];
        g_o=[];
        allow_bounding = false;
        break

    elseif strcmpi(response,"help")
        disp("This allows you to input minimum and maximum values for each variable to create a hypercube of points in the feasibility surrogate")
    
    else
        disp("Please type Y or N (not case sensitive). Type HELP for more details. ")
    end

    %i may add a check in here for double checking, not doing that yet.

end

%if user selects "yes" then let the bounding begin!
if allow_bounding 
    while true %while look to double check inputs from user

        %check with the user wants it to be feasible
       while true
        prompt = 'Will the box represent feasible [Y], infeasible [N], or unknown [M] design space?  ';
        response = input(prompt, 's');
    
            if strcmpi(response,"y")
                check1 = 'feasible'; 
                f = 1; break
        
            elseif strcmpi(response,"n")
                check1 = 'infeasible'; 
                f = -1;break
        
            elseif strcmpi(response,"m")
                check1 = 'unknown/unsure feasible'; 
                f = [-1, 1]; break
         
            %help the user or allow the loop to continue until they've properly
            %entered things
            elseif strcmpi(response,"help")
                fprintf("Y means that point is feasibile (adding a 1 to that point in the surrogate), \nN means the point is infeasible (adding a -1 to the surrogate), \nand M means the point has an unknown response (adding both a 1 and a -1 to that, \nmaking it 50%% feasible). \n \n")
            else
                fprintf("Please type Y, N, or M (not case sensitive). Type HELP for more details. ")
            end
    
        end
        d = width(X); %number of dimensions
        bnds = ones(d,2);

        %prompt user to input bounds
        for i = 1:d
            prompti = ['For design variable #', num2str(i)];
            bnds(i,1) = input([prompti, ' the minimum is: ']);
            bnds(i,2) = input([prompti, ' the maximum is: ']);
        end

        %prompt user to double check that they entered things correctly
        disp(['Please verify that the bounds are correct for space you consider ', check1])
        for i = 1:d
            disp(['Design var #', num2str(i),': min = ',num2str(bnds(i,1)), ' and max = ',num2str(bnds(i,2))])
        end
        check2 = input('Were all the previous ones correct? [Y/N] ','s');
        if strcmpi(check2, "Y")
            break
        end

    end
    
    %creating the bounding boxes (single variable check 
    if d == 1
        x_o = [bnds(1):((bnds(2)-bnds(1))/divs):bnds(2)]';

    else
        x_o = exhaustive_search_sampler(bnds(:,1)', bnds(:,2)', (bnds(:,2)'- bnds(:,1)')/divs);

    end

    if length(f)>1
        g_o = [ones(height(x_o),1); -ones(height(x_o),1)];
        x_o = [x_o;x_o];
    else
        g_o = f*ones(height(x_o),1);
    end

end

end