% TRAIN_DDPG - Script to train the DDPG Agent
clc; clear; close all;

%% Load Configuration
config = utils.get_config();

% Extract training parameters
MAX_EPISODES = config.training.max_episodes;
MAX_STEPS = config.training.max_steps_per_episode;
PLOT_EVERY = config.training.plot_every;
SAVE_FILE = config.training.save_file;

% System Parameters
params = utils.get_sys_params();

% Integration method
switch lower(config.simulation.integration_method)
    case 'euler'
        step_func = @integration.euler;
    case 'rk4'
        step_func = @integration.rk4;
    case 'ode45'
        step_func = @integration.ode45_integration;
    otherwise
        error('Unknown integration method: %s', config.simulation.integration_method);
end

% Initialize Policy (uses config internally)
policy = policies.DDPGPolicy([], config);

% Tracking
episode_rewards = zeros(1, MAX_EPISODES);
avg_rewards = zeros(1, MAX_EPISODES);

fprintf('Starting DDPG Training...\n');
fprintf('Episodes: %d, Max Steps: %d\n', MAX_EPISODES, MAX_STEPS);

%% Training Loop
for ep = 1:MAX_EPISODES
    % Reset Environment
    % Initial state from config with noise
    init_state = config.initial_state.training;
    noise_scale = config.initial_state.training_noise;
    state = init_state + [noise_scale(1)*randn; noise_scale(2)*randn; ...
                          noise_scale(3)*randn; noise_scale(4)*randn];
    policy.reset(); % Reset noise

    total_reward = 0;

    for step = 1:MAX_STEPS
        % 1. Action
        u = policy.compute_action(state, params);

        % 2. Step Dynamics
        next_state = step_func(state, u, params);

        % 3. Calculate Reward from config
        % Reward = -(Q_weights * state^2 + R_weight * action^2) - failure_penalty
        Q_weights = config.reward.Q_weights;
        R_weight = config.reward.R_weight;
        
        reward = -(Q_weights(1) * next_state(1)^2 + ...
                   Q_weights(2) * next_state(2)^2 + ...
                   Q_weights(3) * next_state(3)^2 + ...
                   Q_weights(4) * next_state(4)^2 + ...
                   R_weight * u^2);

        % Failure penalty
        done = false;
        if abs(next_state(1)) > params.x_threshold || abs(next_state(3)) > params.theta_threshold
            reward = reward - config.reward.failure_penalty;
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