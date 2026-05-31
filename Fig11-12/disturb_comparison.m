clear; clc
load('one_loop.mat')
load('multi_loop.mat')
clearvars -except data

set(groot, 'defaultAxesTickLabelInterpreter', 'latex');
set(groot, 'defaultTextInterpreter', 'latex');
set(groot, 'defaultLegendInterpreter', 'latex');
set(groot, 'defaultAxesTickLabelInterpreter', 'latex');

%% between locations
data_2D = squeeze(mean(data,1));

for i = 1:size(data,3)-1
    RMSE_positiosn(i) = rmse(data_2D(:,i), data_2D(:,i+1));
end

RMSE_all_position = mean(RMSE_positiosn);

x = 800:5:1000;
plot(x, data_2D)
xlabel('Frequency (MHz)', 'Interpreter', 'latex')
ylabel('Power (dbm)', 'Interpreter', 'latex')
legend('x=-5','x=-2.5', 'x=0','x=2.5','x=5')

yticklabels(arrayfun(@(x) sprintf('$%d$', x), -65:5:-45, 'UniformOutput', false))
ax = gca;
ax.FontSize = 16;

%% between trials

RMSE_trials = mean(abs(disturb));
figure
% plot(x, data_2D(:,3), x, data_2D(:,3)+disturb')
plot(x, data_2D(:,3),'r')
xlabel('frequency (MHz)', 'FontSize', 16,  'Interpreter', 'latex')
ylabel('power (dbm)', 'FontSize', 16, 'Interpreter', 'latex')
legend('dB(Gmax)')
ax = gca;
ax.FontSize = 18;                % tick labels
ax.XLabel.FontSize = 18;        % x-axis label
ax.YLabel.FontSize = 18;        % y-axis label
ax.TickLabelInterpreter = 'latex';

%% between trials
RMSE_trials = mean(abs(disturb));
figure
plot(x, data_2D(:,3), x, data_2D(:,3)+disturb')
xlabel('Frequency (MHz)', 'FontSize', 16, 'Interpreter', 'latex')
ylabel('Power (dbm)', 'FontSize', 16, 'Interpreter', 'latex')
legend('No disturb', 'Disturbed')

yticklabels(arrayfun(@(x) sprintf('$%d$', x), -60:5:-20, 'UniformOutput', false))
ax = gca;
ax.FontSize = 16;