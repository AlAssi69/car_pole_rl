function config = get_config()
% GET_CONFIG - Centralized configuration for all parameters and hyperparameters
%
% This function returns a structure containing all configuration parameters
% used throughout the project, organized by category for easy maintenance
% and experimentation.
%
% Outputs:
%   config - Structure containing all configuration parameters

%% ========================================================================
% PHYSICAL SYSTEM PARAMETERS
% ========================================================================
config.physical.M = 1.0;              % Mass of the cart (kg)
config.physical.m = 0.1;              % Mass of the pole (kg)
config.physical.L = 1.0;              % Full length of the pole (m)
config.physical.l = config.physical.L / 2;  % Distance to center of mass (m)
config.physical.g = 9.81;            % Gravity (m/s^2)
config.physical.b = 0.1;             % Coefficient of friction for cart (N/m/s)

%% ========================================================================
% SIMULATION SETTINGS
% ========================================================================
config.simulation.dt = 0.02;         % Time step for simulation (seconds)
config.simulation.max_steps = 500;    % Maximum steps per episode/simulation
config.simulation.x_threshold = 5;   % Limit for cart position (m)
config.simulation.theta_threshold = 360 * pi / 180;  % Limit for pole angle (rad)
config.simulation.v_threshold = 100.0;  % Limit for cart velocity (m/s)
config.simulation.omega_threshold = 100.0;  % Limit for pole angular velocity (rad/s)
config.simulation.integration_method = 'rk4';  % 'euler', 'rk4', or 'ode45'

%% ========================================================================
% DDPG ALGORITHM HYPERPARAMETERS
% ========================================================================
config.ddpg.gamma = 0.99;             % Discount factor
config.ddpg.tau = 0.005;              % Soft update parameter (Polyak averaging)
config.ddpg.actor_lr = 1e-4;         % Actor learning rate
config.ddpg.critic_lr = 1e-3;         % Critic learning rate
config.ddpg.batch_size = 64;         % Minibatch size for training
config.ddpg.buffer_capacity = 100000; % Experience replay buffer capacity
config.ddpg.action_bound = 30;       % Maximum action magnitude (force in N)

%% ========================================================================
% DDPG NETWORK ARCHITECTURE
% ========================================================================
config.ddpg.actor.layers = [4, 64, 64, 1];  % Actor network layer sizes
config.ddpg.actor.activations = {'relu', 'relu', 'tanh'};  % Activation functions
config.ddpg.critic.layers = [5, 64, 64, 1];  % Critic network layer sizes
config.ddpg.critic.activations = {'relu', 'relu', 'linear'};  % Activation functions

%% ========================================================================
% EXPLORATION NOISE (Ornstein-Uhlenbeck)
% ========================================================================
config.ddpg.noise.mu = 0;             % Long-term mean
config.ddpg.noise.theta = 0.15;       % Mean reversion speed
config.ddpg.noise.sigma = 0.2;        % Volatility
config.ddpg.noise.dt = 0.02;          % Time step (should match simulation.dt)

%% ========================================================================
% TRAINING PARAMETERS
% ========================================================================
config.training.max_episodes = 200;  % Maximum number of training episodes
config.training.max_steps_per_episode = 500;  % Maximum steps per episode
config.training.plot_every = 10;     % Print progress every N episodes
config.training.save_file = 'trained_ddpg_policy.mat';  % Output file name

%% ========================================================================
% REWARD FUNCTION PARAMETERS
% ========================================================================
% Reward = -(Q_weights * state^2 + R_weight * action^2) - failure_penalty
config.reward.Q_weights = [1.0, 0.1, 10.0, 0.1];  % [position, velocity, angle, angular_vel]
config.reward.R_weight = 0.001;      % Control effort weight
config.reward.failure_penalty = 100; % Penalty when episode terminates early

%% ========================================================================
% INITIAL STATE SETTINGS
% ========================================================================
config.initial_state.training = [0; 0; 0.1; 0];  % [p; p_dot; theta; theta_dot] for training
config.initial_state.training_noise = [0; 0; 0.1; 0];  % Noise scale: [0; 0; 0.1; 0] means theta gets 0.1*randn
config.initial_state.evaluation = [0; 0; 0.6; 0];  % Initial state for evaluation/testing

%% ========================================================================
% VISUALIZATION SETTINGS
% ========================================================================
config.visualization.system = true;  % Show cart-pole animation
config.visualization.states = true;  % Show state trajectory plots
config.visualization.animation_size = 500;  % Size of animation window (pixels)
config.visualization.states_width = 600;   % Width of states plot window
config.visualization.states_height = 700;  % Height of states plot window

%% ========================================================================
% CONTROLLER PARAMETERS (for comparison)
% ========================================================================
config.controller.PD.gains = [-2, -2, -30, -5];  % [Kp, Kd_p, Ktheta, Kd_theta]
config.controller.LQR.Q = eye(4);    % State weighting matrix
config.controller.LQR.R = 1.0;      % Control weighting scalar

%% ========================================================================
% MAIN SCRIPT SETTINGS
% ========================================================================
config.main.use_controller = true;  % true = use controller, false = use policy
config.main.random_seed = 'default';  % Random seed for reproducibility
end