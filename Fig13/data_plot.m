p1raw=csvread('11Ni.csv',2,2);
p2raw=csvread('33Ni.csv',2,2);
p3raw=csvread('1.csv',2,2);

p1=[];
p2=[];
p3=[];


for i=1:41;
    p1(i)=p1raw(1+15*(i-1));
    p2(i)=p2raw(1+15*(i-1));
    p3(i)=p3raw(1+15*(i-1));

end

fre=800:5:1000;


plot(fre,p1);
hold on;
plot(fre,p2);
hold on;
plot(fre,p3);

legend('Open air','Under flesh','In Nitinol');
xlabel('frequency(MHz)');
ylabel('power gain(dB)');