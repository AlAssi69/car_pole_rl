% TRAIN_DDPG - Script to train the DDPG Agent
clc; clear; close all;

%% Configuration
MAX_EPISODES = 200;
MAX_STEPS = 500;
PLOT_EVERY = 10;
SAVE_FILE = 'trained_ddpg_policy.mat';

% System Parameters
params = utils.get_sys_params();
step_func = @integration.rk4;

% Initialize Policy
% Action bound is typically high for force, e.g., 10N or 20N
policy = policies.DDPGPolicy(30);

% Tracking
episode_rewards = zeros(1, MAX_EPISODES);
avg_rewards = zeros(1, MAX_EPISODES);

fprintf('Starting DDPG Training...\n');
fprintf('Episodes: %d, Max Steps: %d\n', MAX_EPISODES, MAX_STEPS);

%% Training Loop
for ep = 1:MAX_EPISODES
    % Reset Environment
    % Random initial state: small random perturbations
    state = [0; 0; 0.1*randn; 0]; % Start near upright
    policy.reset(); % Reset noise

    total_reward = 0;

    for step = 1:MAX_STEPS
        % 1. Action
        u = policy.compute_action(state, params);

        % 2. Step Dynamics
        next_state = step_func(state, u, params);

        % 3. Calculate Reward
        % Goal: Upright (theta=0) and Center (x=0)
        % Penalty for angle, distance, control effort
        p = next_state(1);
        theta = next_state(3);

        % Reward function: -Cost
        % Q = diag([1, 0.1, 10, 0.1])
        % R = 0.01
        reward = -(1.0 * p^2 + 0.1 * next_state(2)^2 + ...
            10.0 * theta^2 + 0.1 * next_state(4)^2 + ...
            0.001 * u^2);

        % Failure penalty
        done = false;
        if abs(p) > params.x_threshold || abs(theta) > params.theta_threshold
            reward = reward - 100;
            done = true;
        end

        % 4. Store and Train
        experience.state = state;
        experience.action = u;
        experience.reward = reward;
        experience.next_state = next_state;
        experience.done = done;

        policy.update(experience);

        state = next_state;
        total_reward = total_reward + reward;

        if done
            break;
        end
    end

    episode_rewards(ep) = total_reward;
    avg_rewards(ep) = mean(episode_rewards(max(1, ep-10):ep));

    if mod(ep, PLOT_EVERY) == 0
        fprintf('Episode %d: Reward = %.2f, Avg(10) = %.2f\n', ...
            ep, total_reward, avg_rewards(ep));
    end
end

%% Save
fprintf('Training Complete. Saving to %s\n', SAVE_FILE);
save(SAVE_FILE, 'policy', 'episode_rewards');

%% Plot Training Curve
figure;
plot(episode_rewards, 'Color', [0.7 0.7 0.7]); hold on;
plot(avg_rewards, 'LineWidth', 2);
title('DDPG Training Progress');
xlabel('Episode');
ylabel('Total Reward');
legend('Episode Reward', '10-Ep Moving Avg');
grid on;