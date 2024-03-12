close all

X = 0:1:25;
Y = [ones(1,8)*324.5, ones(1,10)*291.4, ones(1,8)*167];

x_inf = [1,2,3,5,7,9,10,11,15,16,20];
y_inf = [ones(1,5)*324.5,ones(1,5)*291.4,167];

x_feas = [0 4 8 12 13 14 17 18 19 21 22 23 24 25];
y_feas = [324.5,324.5,ones(1,5)*291.4,ones(1,7)*167];

x_same = [18 23 24 25];
y_same = ones(1,4)*167;

fig = figure();

pi = plot(X,Y,'k-','LineWidth',1.45);
hold on

m = 7;
p1 = plot(x_inf,y_inf,'x','Color',[232, 46, 39]/255,'MarkerSize',1.5*m,'LineWidth',2);
p2 = plot(x_feas,y_feas,'o','MarkerFaceColor',[55, 214, 49]/255,'MarkerEdgeColor',[29, 102, 27]/255,'MarkerSize',m);
p3 = plot(x_same,y_same,'^','MarkerEdgeColor',[177, 50, 184]/255,'MarkerSize',1.1*m,'LineWidth',1.5);

ylim([0 450])
xlabel('Iterations')
ylabel('Burnt Trees Remaining')
ax = gca;
ax.Units = 'inches';
ax.Position(3) = ax.Position(1) +3.5;
ax.Position(4) = ax.Position(2) +2;

ax.FontSize = 12;
ax.FontName = 'Times';

legend([p1 p2 p3], 'Infeasible Suggestions', 'Feasible Suggestions', 'Repeat Fleet Effectiveness')