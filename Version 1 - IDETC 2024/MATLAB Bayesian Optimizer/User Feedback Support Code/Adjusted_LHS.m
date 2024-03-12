function samps = Adjusted_LHS(n_samps, varargin)
% Since the lhdesign() function goes between 0 and 1, and the design
% options are a set design values, it's 
%
%
%
%


n_vars = length(varargin);

samps = lhsdesign(n_samps, n_vars, 'criterion','maximin');


for i = 1:n_vars
    samps(:,i) = varargin{i}(ceil(length(varargin{i})*samps(:,i)));
end


end