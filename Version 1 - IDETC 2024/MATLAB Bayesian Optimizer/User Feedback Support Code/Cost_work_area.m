%work area for calculating "cost" based on design variables
%minute = step (unless I switch the fidelity)
rng(1)
format compact

sp = [400, 1900, 250]; %meter/minute
iat = [5,17,2]; %in air time, minutes
rt = [15,3,-2]; %reset time, minutes 
pd = [150,510,60]; %reducing time? (increase this bigly. let's test burning stuff


dv = [sp;iat;rt;pd];

X = exhaustive_search_sampler(dv(:,1)', dv(:,2)', dv(:,3)');
Xf = flip(X);

%% this part is just to help evaluate choices, which make end up being an easier way to fit the model
C = [1,7,1;1,7,1;1,7,1;1,7,1];

Y = exhaustive_search_sampler(C(:,1)',C(:,2)', C(:,3)');

Yf = flip(Y);


nd = ones(height(Y),1);

%{
n = 1;
ns = 2;
c = 1;

for i = 1:height(Y)
    nd(i) = n;
    n = n+1;
    c = c+1;
    if c == 7
        n = ns;
        ns = ns+1;
        c = 1;
    end


end
%}
magnifier = 5;
h = 1;
for i = C(1,1):C(1,3):C(1,2)
    for j = C(2,1):C(2,3):C(2,2)
        for k = C(3,1):C(3,3):C(3,2)
            for q = C(4,1):C(4,3):C(4,2)
                nd(h)= magnifier*(i+j+k+q);
                h = h+1;
            end
        end
    end

end


%%need to include something where I can enter in the design solution to
%%find the resulting N

test = [Yf,nd];
design_and_fleet= [Xf,nd];


spi = 400:250:1900;
iati = 5:2:17;
rti = 15:-2:3;
pdi = 150:60:510;
in_s = 14;
initial = Adjusted_LHS(in_s, spi,iati,rti,pdi);
designs = [initial, zeros(in_s,1)];
for i = 1:in_s
   [q, indx] = ismember(initial(i,:),Xf,'rows');
    designs(i,end) = design_and_fleet(indx,end);
end

designs;

%% find the extremes

sp = [400, 1900, 1500]; %meter/minute
iat = [5,17,12]; %in air time, minutes
rt = [3,15,12]; %reset time, minutes 
pd = [150,510,360]; %reducing time? (increase this bigly. let's test burning stuff


dv = [sp;iat;rt;pd];

extremes = exhaustive_search_sampler(dv(:,1)', dv(:,2)', dv(:,3)');
ex_designs = [extremes, zeros(16,1)];

for i = 1:16
   [q, indx] = ismember(extremes(i,:),Xf,'rows');
    ex_designs(i,end) = design_and_fleet(indx,end);
end

ex_designs;


%% helping me find the actual answers....

x_next = [1400    17    15   330];

[q, indx] = ismember(x_next,Xf,'rows');
design_and_fleet(indx,end)
