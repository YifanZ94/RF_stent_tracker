p1raw=csvread('air.csv',2,2);
p2raw=csvread('flesh.csv',2,2);
p3raw=csvread('Nit.csv',2,2);

p1=[];
p2=[];
p3=[];


for i=1:41;
    p1(i)=p1raw(1+15*(i-1));
    p2(i)=p2raw(1+15*(i-1));
    p3(i)=p3raw(1+15*(i-1));

end

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

legend('Open air','Under flesh','In Nitinol');
xlabel('frequency(MHz)');
ylabel('power gain(dB)');
ax = gca;
ax.FontSize = 16;
yticklabels(arrayfun(@(x) sprintf('$%d$', x), yticks, 'UniformOutput', false))