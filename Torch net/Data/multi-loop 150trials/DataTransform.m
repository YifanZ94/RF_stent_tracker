clear
clc
load('data.mat');
m=size(data,1);
power=zeros(m*5,41);

for i=1:m
    for j=1:5
        power((i-1)*5+j,:)= data(i,:,j);
    end
end

position=repmat(eye(5),m,1);
result_2d=[power,position];

save('2d_result.mat','result_2d');
x = power';
t = position';
save('RF_data_for_NN.mat','x','t');
