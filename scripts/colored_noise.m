clc; clear; close all;

% --- Simulation Parameters ---
num_steps = 1000;
dt = 0.01;

% --- Hyperparameters ---
mu = 0;         % Long-term mean (usually 0 for exploration)
theta = 0.15;   % Mean Reversion Speed (Stiffness of the "spring")
sigma = 0.3;    % Volatility (Magnitude of the noise)

% --- Initialization ---
ou_noise = zeros(1, num_steps);
white_noise = zeros(1, num_steps);
x_prev = 0;

% --- Simulation Loop ---
for t = 1:num_steps
    % 1. Generate standard Gaussian noise sample
    noise_sample = randn;

    % 2. Calculate OU Process (The "Colored" Noise)
    % dx = theta * (mean - previous) * dt + sigma * sqrt(dt) * noise
    dx = theta * (mu - x_prev) * dt + sigma * sqrt(dt) * noise_sample;
    x_curr = x_prev + dx;

    % Store and update
    ou_noise(t) = x_curr;
    x_prev = x_curr;

    % 3. Calculate White Noise (for comparison)
    % We scale it to have similar bounds for visual comparison
    white_noise(t) = sigma * noise_sample;
end

% --- Visualization ---
figure('Color', 'w');
t_vec = 1:num_steps;

subplot(2,1,1);
plot(t_vec, white_noise, 'Color', [0.7 0.7 0.7], 'LineWidth', 1);
title('White Noise (Uncorrelated)');
ylabel('Amplitude');
grid on;
xlim([0, num_steps]);

subplot(2,1,2);
plot(t_vec, ou_noise, 'Color', [0 0.4470 0.7410], 'LineWidth', 1.5);
title('Ornstein-Uhlenbeck Noise (Correlated / Colored)');
xlabel('Time Steps');
ylabel('Amplitude');
grid on;
xlim([0, num_steps]);

% Overlay for direct comparison
figure('Color', 'w');
plot(t_vec, white_noise, 'Color', [0.8 0.8 0.8], 'DisplayName', 'White Noise');
hold on;
plot(t_vec, ou_noise, 'Color', 'b', 'LineWidth', 2, 'DisplayName', 'OU Noise');
yline(mu, 'r--', 'Mean', 'LineWidth', 1.5);
title('Exploration Signal Comparison');
legend;
grid on;