p1raw=csvread('0.csv',2,2);
p2raw=csvread('90.csv',2,2);
p3raw=csvread('180.csv',2,2);

p1=[];
p2=[];
p3=[];

for i=1:41;
    p1(i)=p1raw(1+15*(i-1));
    p2(i)=p2raw(1+15*(i-1));
    p3(i)=p3raw(1+15*(i-1));


end

P1=p1';
P2=p2';
P3=p3';

fre=800:5:1000;

set(groot, 'defaultAxesTickLabelInterpreter', 'latex');
set(groot, 'defaultTextInterpreter', 'latex');
set(groot, 'defaultLegendInterpreter', 'latex');
set(groot, 'defaultAxesTickLabelInterpreter', 'latex');

plot(fre,p1);
hold on;
plot(fre,p2);
hold on;
plot(fre,p3);

xlabel('Frequency(MHz)');
ylabel('Power (dBm)');
legend('0','90','180');
ax = gca;
ax.FontSize = 16;
yticklabels(arrayfun(@(x) sprintf('$%d$', x), yticks, 'UniformOutput', false))