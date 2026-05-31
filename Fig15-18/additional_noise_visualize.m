clear; clc
load('RF_data_for_NN_oneLoop.mat');

%% Gaussian noise
a = 0.75;
W = a*randn(41, 750);
x_N = normalize(x);

x_White = x_N + W;

%%  Gaussian plot
[X, Y] = meshgrid(1:150, 800:5:1000);
figure
loc_ind = 3;
surface(Y, X, x_White(:,loc_ind:5:end), 'FaceColor', 'flat')
title('Gaussian \sigma=0.75')
ylabel('trials')
xlabel('frequency(MHz)')
% clim([-2 2]);
colorbar

%%
% load('distb1.mat')
% distb_N = normalize(disturb);
% b = 0.25;
% x_d = x_N + b*distb_N';

%% sinusoidal noise
N = 41;
c = 1;
n = 0:40; 

for i = 1:750
    sin_distb = c*rand()*sin(2 * pi *(n / N + rand())); 
    x_sin2pi(:,i) = x_N(:,i) + sin_distb';

    sin_distb = c*rand()*sin(4 * pi *(n / N + rand())); 
    x_sin4pi(:,i) = x_N(:,i) + sin_distb';

    sin_distb = c*rand()*sin(1 * pi *(n / N + rand())); 
    x_sin1pi(:,i) = x_N(:,i) + sin_distb';

    sin_distb = c*rand()*sin(3 * pi *(n / N + rand())); 
    x_sin3pi(:,i) = x_N(:,i) + sin_distb';

    sin_distb = 2*c*rand()*sin(5 * pi *(n / N + rand())); 
    x_sin5pi(:,i) = x_N(:,i) + sin_distb';

end

x_all = [x_sin1pi, x_sin3pi, x_sin4pi, x_sin5pi];
t_all = [t,t,t,t];

%% Sin plot
% [X, Y] = meshgrid(1:150, 800:5:1000);
figure
loc_ind = 3;
% subplot(131)
% surface(X, Y, x_N(:,loc_ind:5:end), 'FaceColor', 'flat')
% title('undisturbed')
% xlabel('trials')
% ylabel('frequency(MHz)')
% clim([-2 2]);
% colorbar

subplot(121)
surface(Y,X, x_sin1pi(:,loc_ind:5:end), 'FaceColor', 'flat')
title('disturbed c1=1 c2=1')
ylabel('trials')
xlabel('frequency(MHz)')
clim([-2 2]);
colorbar

subplot(122)
surface(Y,X, x_sin5pi(:,loc_ind:5:end), 'FaceColor', 'flat')
title('disturbed c1=2 c2=5')
ylabel('trials')
xlabel('frequency(MHz)')
clim([-2 2]);
colorbar
