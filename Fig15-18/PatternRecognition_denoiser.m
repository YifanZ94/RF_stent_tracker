%% PatternRecognition_denoiser.m
%  Denoising steps:
%    1. Range-normalise raw features  (replaces z-score from Python)
%    2. Add selectable noise          (matches Python noise injection)
%    3. Mask-based denoising:         randomly zero-out 15 % of each
%       sample's features and replace them with the column-mean of the
%       *unmasked* neighbours — a simplified analogue of the
%       Noise2Self / mask-denoiser pass.
%    4. Train patternnet classifier   (5 hidden units, SGD, 500 epochs)
%    5. Evaluate train / test accuracy and confusion matrices.

clear; clc; close all;

%% ── USER SETTINGS ────────────────────────────────────────────────────────

NOISE_TYPE  = 'gaussian';      % 'gaussian'  |  'sinusoidal'

% Amplitude sweep values
%   gaussian   → sig  (std-dev of white noise, e.g. 0.05 – 0.40)
%   sinusoidal → c    (amplitude multiplier,   e.g. 0.25 – 2.00)
NOISE_VALUES = [0, 0.25, 0.50, 0.75, 1.0];

MASK_RATIO  = 0.15;   % fraction of features masked per sample (Noise2Self)
TRAIN_RATIO = 0.80;   % 80/20 train-test split
HIDDEN_NODES = 5;     % patternnet hidden layer size

%% ── LOAD & NORMALISE DATA ────────────────────────────────────────────────

load('RF_data_for_NN.mat');   % provides x (41×750) and t (K×750)

[n_feat, n_samples] = size(x);
x = normalize(x, 1, 'range');        % column-wise [0,1] normalisation

% Fixed shuffle so every noise level sees the same split
rng(42);
idx_shuffle = randperm(n_samples);
n_train     = round(n_samples * TRAIN_RATIO);

train_idx = idx_shuffle(1 : n_train);
test_idx  = idx_shuffle(n_train+1 : end);

x_train_clean = x(:, train_idx);
y_train       = t(:, train_idx);
x_test_clean  = x(:, test_idx);
y_test        = t(:, test_idx);

%% ── SWEEP LOOP ───────────────────────────────────────────────────────────

n_levels = numel(NOISE_VALUES);
results  = zeros(n_levels, 3);   % [noise_val, train_acc, test_acc]

% Pre-allocate label containers for confusion matrices of last level
last_train_true = []; last_train_pred = [];
last_test_true  = []; last_test_pred  = [];

fprintf('\n%-10s  %-10s  %-12s  %-10s\n', ...
        'Noise', 'Value', 'Train Acc(%)', 'Test Acc(%)');
fprintf('%s\n', repmat('-', 1, 48));

for lv = 1 : n_levels

    noise_val = NOISE_VALUES(lv);

    %% 1. Inject noise
    switch lower(NOISE_TYPE)
        case 'gaussian'
            x_train_noisy = add_gaussian(x_train_clean, noise_val);
            x_test_noisy  = add_gaussian(x_test_clean,  noise_val);
        case 'sinusoidal'
            x_train_noisy = add_sinusoidal(x_train_clean, noise_val, n_feat);
            x_test_noisy  = add_sinusoidal(x_test_clean,  noise_val, n_feat);
        otherwise
            error('NOISE_TYPE must be ''gaussian'' or ''sinusoidal''.');
    end

    %% 2. Mask-based denoising (Noise2Self analogue)
    x_train_den = mask_denoise(x_train_noisy, MASK_RATIO);
    x_test_den  = mask_denoise(x_test_noisy,  MASK_RATIO);

    %% 3. Train patternnet
    net = patternnet(HIDDEN_NODES, 'traingd');
    net.trainParam.epochs   = 500;
    net.trainParam.show     = Inf;     
    net.trainParam.max_fail = 4;
    net.divideParam.trainRatio = 0.70;
    net.divideParam.valRatio   = 0.15;
    net.divideParam.testRatio  = 0.15;

    [net, ~] = train(net, x_train_den, y_train);

    %% 4. Evaluate
    [~, tr_pred] = max(net(x_train_den));
    [~, tr_true] = max(y_train);
    train_acc = 100 * mean(tr_pred == tr_true);

    [~, te_pred] = max(net(x_test_den));
    [~, te_true] = max(y_test);
    test_acc  = 100 * mean(te_pred == te_true);

    results(lv, :) = [noise_val, train_acc, test_acc];

    fprintf('%-10s  %-10.3f  %-12.2f  %-10.2f\n', ...
            NOISE_TYPE, noise_val, train_acc, test_acc);

    %% Keep predictions for the last noise level (confusion matrices)
    if lv == n_levels
        last_train_true = tr_true;  last_train_pred = tr_pred;
        last_test_true  = te_true;  last_test_pred  = te_pred;
    end
end

%% ── SUMMARY TABLE ────────────────────────────────────────────────────────

fprintf('\n=== SUMMARY ===\n');
fprintf('%-10s  %-12s  %-10s\n', 'Noise val', 'Train Acc(%)', 'Test Acc(%)');
fprintf('%s\n', repmat('-', 1, 36));
for lv = 1 : n_levels
    fprintf('%-10.3f  %-12.2f  %-10.2f\n', results(lv,:));
end

%% ── ACCURACY vs NOISE LEVEL PLOT ─────────────────────────────────────────

figure('Name', 'Accuracy vs Noise Level', 'NumberTitle', 'off');
plot(results(:,1), results(:,2), 'b-o', 'LineWidth', 1.5, 'MarkerSize', 7); hold on;
plot(results(:,1), results(:,3), 'r-s', 'LineWidth', 1.5, 'MarkerSize', 7);
xlabel(['Noise amplitude (' NOISE_TYPE ')'], 'FontSize', 12);
ylabel('Accuracy (%)', 'FontSize', 12);
title(['Classification Accuracy vs ' NOISE_TYPE ' noise amplitude'], 'FontSize', 13);
legend('Train', 'Test', 'Location', 'southwest');
grid on;
ylim([0 105]);

%% ── CONFUSION MATRICES (last noise level) ────────────────────────────────

figure('Name', 'Confusion Matrices – Highest Noise Level', 'NumberTitle', 'off');
subplot(1,2,1);
cm_tr = confusionchart(last_train_true, last_train_pred);
cm_tr.Title = sprintf('Train  |  %s = %.2f', NOISE_TYPE, NOISE_VALUES(end));
subplot(1,2,2);
cm_te = confusionchart(last_test_true, last_test_pred);
cm_te.Title  = sprintf('Test  |  %s = %.2f', NOISE_TYPE, NOISE_VALUES(end));

fprintf('\nDone. Confusion matrices shown for noise value = %.2f\n', NOISE_VALUES(end));

%% ── NOISE & DENOISING HELPERS ────────────────────────────────────────────

function xn = add_gaussian(x, sig)
    xn = x + sig^2 * randn(size(x));
end

function xn = add_sinusoidal(x, c, N)
    % Replicates the loop in the original script:
    % each column gets a random-phase, random-amplitude sinusoid.
    n   = (0 : N-1)';
    xn  = x;
    for k = 1 : size(x, 2)
        sin_distb = c * rand() * sin(2*pi*(n/N + rand()));
        xn(:, k)  = x(:, k) + sin_distb;
    end
end

function x_den = mask_denoise(x_noisy, mask_ratio)
    [n_feat, n_samp] = size(x_noisy);
    x_den = x_noisy;
    n_mask = max(1, round(n_feat * mask_ratio));

    for k = 1 : n_samp
        col  = x_noisy(:, k);
        perm = randperm(n_feat);
        mask_idx   = perm(1 : n_mask);
        unmask_idx = perm(n_mask+1 : end);
        fill_val   = mean(col(unmask_idx));    % context mean → masked slots
        col(mask_idx) = fill_val;
        x_den(:, k)   = col;
    end
end
