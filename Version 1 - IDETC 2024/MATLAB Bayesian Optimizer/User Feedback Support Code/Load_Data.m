function data = Load_Data(filename)
%loads in and parses data

obj = readmatrix(filename, 'Sheet','Obj_Values');
cnst = readmatrix(filename, 'Sheet','Cnst_Values');
cnst_add = readmatrix(filename, 'Sheet','Additional_Points');

dims = width(obj)-1;
n_points = height(obj);

%pull out the data into array form for manipulation
x_obj = obj(:,1:dims);
x_cnst= cnst(:,1:dims);
x_cnst_add = cnst_add(:,1:dims);

%perform a summation check to warn user 
check_same = sum(sum(x_obj == x_cnst));

if check_same ~= numel(x_obj)
    disp('ERROR: Check that feasibility inputs are the same length and values as the objective function (first two sheets)')
    disp('This ensures that you can check for minimum feasible design points')
end


f_obj = obj(:, dims+1);
g_cnst = cnst(:, dims+1);
g_cnst_add = cnst_add(:, dims+1);

%if there is not data in the additional constraints, just allow that to be
%an empty vector. This makes it easier for later

[row_nan, col_nan] = find(isnan(g_cnst_add));
x_cnst_add(row_nan,:) = [];
g_cnst_add(row_nan,:) = [];

%store the data in a structure for elsewhere
    %since x_cnst should be equal to x_obj, no need to add that twice!
data = struct('xs',x_obj, 'x_add',x_cnst_add, 'obj',f_obj,'cnst',g_cnst,'cnst_add',g_cnst_add);


end