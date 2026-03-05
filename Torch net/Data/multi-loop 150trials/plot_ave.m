clear; clc
load('Data.mat');
ave = mean(data, 1);
f = 800:5:1000;

for i = 1:5
    plot(f, ave(1,:,i))
    hold on
end

xlabel('frequency (MHz)')
ylabel('power (dBm)')
legend('x=-5', 'x=-2.5','x=0','x=+2.5','x=+5')


%%
x = reshape(data, [41,750]);
