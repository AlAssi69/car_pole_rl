%% Main Simulation Loop
% This script demonstrates the refactored package structure for easy
% comparison between control theory approaches and RL policies.
%
% To switch between different controllers/policies, simply change the
% 'controller' or 'policy' variable below.

clc; clear; close all;

%% Load Configuration
config = utils.get_config();

% Set random seed
rng(config.main.random_seed);

%% Configuration
% Choose your control strategy from config
USE_CONTROLLER = config.main.use_controller;

if USE_CONTROLLER
    % Available controllers:
    %   - controllers.PDController([Kp, Kd_p, Ktheta, Kd_theta])
    %   - controllers.LQRController(Q, R)
    controller = controllers.PDController(config.controller.PD.gains);
    % controller = controllers.LQRController(config.controller.LQR.Q, config.controller.LQR.R);
    strategy_name = controller.get_name();
else
    % Available policies:
    %   - policies.RandomPolicy(action_min, action_max)
    %   - policies.DDPGPolicy(action_max, config)
    
    % Check if trained model exists
    if exist(config.training.save_file, 'file')
        fprintf('Loading trained DDPG Policy...\n');
        d = load(config.training.save_file);
        policy = d.policy;
        policy.is_training = false; % Disable noise for evaluation
    else
        fprintf('Using untrained DDPG Policy (Random weights)...\n');
        policy = policies.DDPGPolicy([], config);
        policy.is_training = false; % Still disable noise for pure evaluation of weights
        % Or use RandomPolicy:
        % policy = policies.RandomPolicy(-10, 10);
    end
    
    strategy_name = policy.get_name();
end

% Integration method from config
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

% Simulation parameters from config
max_steps = config.simulation.max_steps;

% Visualization flags from config
VISUALIZE_SYSTEM = config.visualization.system;
VISUALIZE_STATES = config.visualization.states;

%% 1. Load Parameters
params = utils.get_sys_params();

% 2. Initial State [p; p_dot; theta; theta_dot] from config
state = config.initial_state.evaluation;
time = 0;

% Initialize data storage for summary
trajectory = zeros(4, max_steps);
actions = zeros(1, max_steps);
times = zeros(1, max_steps);

% 3. Setup Figures (only if visualization is enabled)
fig_anim = [];
fig_states = [];
state_lines = [];

if VISUALIZE_SYSTEM
    % Figure A: System Animation (The Cart & Pole) - Square on the left
    anim_size = config.visualization.animation_size;
    anim_left = 100;  % Distance from left edge of screen
    anim_bottom = 250;  % Distance from bottom edge of screen
    fig_anim = figure('Name', 'System Animation', 'Color', 'w', ...
        'Position', [anim_left, anim_bottom, anim_size*1.2, anim_size]);
end

if VISUALIZE_STATES
    % Figure B: State Plots (The Graphs) - Rectangle on the right
    states_width = config.visualization.states_width;
    states_height = config.visualization.states_height;
    states_bottom = 80;  % Distance from bottom edge of screen
    if VISUALIZE_SYSTEM
        % Position to the right of animation if both are shown
        states_left = anim_left + anim_size*1.2 + 50;  % Position to the right of animation (50px gap)
    else
        % Center it if only states are shown
        states_left = 100;
    end
    fig_states = figure('Name', 'State Trajectories', 'Color', 'w', ...
        'Position', [states_left, states_bottom, states_width, states_height]);
    
    % Initialize the 4x1 State Plots and get handles to lines
    state_lines = visualization.init_state_plots(fig_states);
end

fprintf('=== Simulation Configuration ===\n');
fprintf('Strategy: %s\n', strategy_name);
fprintf('Integration: %s\n', func2str(step_func));
fprintf('Max Steps: %d\n', max_steps);
fprintf('Time Step: %.4f s\n', params.dt);
fprintf('Visualization: System=%d, States=%d\n', VISUALIZE_SYSTEM, VISUALIZE_STATES);
fprintf('Initial State: p=%.3f m, v=%.3f m/s, theta=%.3f rad, omega=%.3f rad/s\n', ...
    state(1), state(2), state(3), state(4));
fprintf('\n=== Starting Simulation ===\n');
if ~VISUALIZE_SYSTEM && ~VISUALIZE_STATES
    fprintf('Running in headless mode (no visualization)\n');
end
fprintf('Press Ctrl+C to stop.\n\n');

%% 4. Simulation Loop
for step = 1:max_steps
    % A. Compute Action
    if USE_CONTROLLER
        u = controller.compute_action(state, params);
    else
        u = policy.compute_action(state, params);
    end
    
    % Debug: Show action every N steps or at key milestones
    if ~VISUALIZE_SYSTEM && ~VISUALIZE_STATES
        if mod(step, 50) == 0 || step <= 5 || step == max_steps
            fprintf('[Step %d, t=%.3f s] Action: u=%.3f N\n', step, time, u);
        end
    end
    
    % B. Step Physics
    state_prev = state;
    state = step_func(state, u, params);
    time = time + params.dt;
    
    % Store trajectory data
    trajectory(:, step) = state;
    actions(step) = u;
    times(step) = time;
    
    % Debug: Show state updates periodically
    if ~VISUALIZE_SYSTEM && ~VISUALIZE_STATES
        if mod(step, 50) == 0 || step <= 5 || step == max_steps
            fprintf('  State: p=%.3f m, v=%.3f m/s, theta=%.3f rad, omega=%.3f rad/s\n', ...
                state(1), state(2), state(3), state(4));
        end
    end
    
    % B.1. Check Termination Conditions
    % Stop if position or angle exceed thresholds
    if abs(state(1)) > params.x_threshold || abs(state(3)) > params.theta_threshold
        fprintf('\n[Step %d] Simulation terminated: Position or angle exceeded threshold.\n', step);
        fprintf('  Cart position: %.3f m (threshold: ±%.3f m)\n', state(1), params.x_threshold);
        fprintf('  Pole angle: %.3f rad (threshold: ±%.3f rad)\n', state(3), params.theta_threshold);
        break;
    end
    
    % Stop if velocity or angular velocity exceed thresholds
    if abs(state(2)) > params.v_threshold || abs(state(4)) > params.omega_threshold
        fprintf('\n[Step %d] Simulation terminated: Velocity exceeded threshold.\n', step);
        fprintf('  Cart velocity: %.3f m/s (threshold: ±%.3f m/s)\n', state(2), params.v_threshold);
        fprintf('  Pole angular velocity: %.3f rad/s (threshold: ±%.3f rad/s)\n', state(4), params.omega_threshold);
        break;
    end
    
    % C. Visualize System (Figure A)
    if VISUALIZE_SYSTEM
        if isvalid(fig_anim)
            visualization.visualize_system(state, params, fig_anim, step, max_steps);
        else
            break; % Stop if window is closed
        end
    end
    
    % D. Update State Plots (Figure B)
    if VISUALIZE_STATES && isvalid(fig_states)
        visualization.update_state_plots(state_lines, state, time, u);
    end
    
    % E. Sync Speed (only if visualization is enabled)
    % Limit update rate slightly to keep animation smooth
    if VISUALIZE_SYSTEM || VISUALIZE_STATES
        pause(params.dt);
    end
end

fprintf('\n=== Simulation Completed ===\n');
fprintf('Total steps: %d / %d\n', step, max_steps);
fprintf('Total time: %.3f s\n', time);

%% 5. Summary Report
fprintf('\n=== Simulation Summary ===\n');
fprintf('Strategy: %s\n', strategy_name);
fprintf('Integration Method: %s\n', func2str(step_func));
fprintf('Completion: %d%% (%d/%d steps)\n', round(100*step/max_steps), step, max_steps);

% Final state information
fprintf('\n--- Final State ---\n');
fprintf('Cart Position (p):     %.4f m  [threshold: ±%.3f m]\n', state(1), params.x_threshold);
fprintf('Cart Velocity (v):    %.4f m/s [threshold: ±%.3f m/s]\n', state(2), params.v_threshold);
fprintf('Pole Angle (theta):   %.4f rad [threshold: ±%.3f rad]\n', state(3), params.theta_threshold);
fprintf('Pole Angular Vel (ω): %.4f rad/s [threshold: ±%.3f rad/s]\n', state(4), params.omega_threshold);

% Check if system is stable (within thresholds)
within_thresholds = (abs(state(1)) <= params.x_threshold) && ...
    (abs(state(2)) <= params.v_threshold) && ...
    (abs(state(3)) <= params.theta_threshold) && ...
    (abs(state(4)) <= params.omega_threshold);
if within_thresholds
    status_str = 'STABLE';
else
    status_str = 'UNSTABLE';
end
fprintf('System Status: %s\n', status_str);

% Statistics over trajectory
actual_steps = step;
trajectory_actual = trajectory(:, 1:actual_steps);
actions_actual = actions(1:actual_steps);
times_actual = times(1:actual_steps);

fprintf('\n--- Trajectory Statistics ---\n');
fprintf('Cart Position:\n');
fprintf('  Min: %.4f m, Max: %.4f m, Mean: %.4f m, Std: %.4f m\n', ...
    min(trajectory_actual(1,:)), max(trajectory_actual(1,:)), ...
    mean(trajectory_actual(1,:)), std(trajectory_actual(1,:)));

fprintf('Cart Velocity:\n');
fprintf('  Min: %.4f m/s, Max: %.4f m/s, Mean: %.4f m/s, Std: %.4f m/s\n', ...
    min(trajectory_actual(2,:)), max(trajectory_actual(2,:)), ...
    mean(trajectory_actual(2,:)), std(trajectory_actual(2,:)));

fprintf('Pole Angle:\n');
fprintf('  Min: %.4f rad, Max: %.4f rad, Mean: %.4f rad, Std: %.4f rad\n', ...
    min(trajectory_actual(3,:)), max(trajectory_actual(3,:)), ...
    mean(trajectory_actual(3,:)), std(trajectory_actual(3,:)));

fprintf('Pole Angular Velocity:\n');
fprintf('  Min: %.4f rad/s, Max: %.4f rad/s, Mean: %.4f rad/s, Std: %.4f rad/s\n', ...
    min(trajectory_actual(4,:)), max(trajectory_actual(4,:)), ...
    mean(trajectory_actual(4,:)), std(trajectory_actual(4,:)));

fprintf('Control Input:\n');
fprintf('  Min: %.4f N, Max: %.4f N, Mean: %.4f N, Std: %.4f N\n', ...
    min(actions_actual), max(actions_actual), ...
    mean(actions_actual), std(actions_actual));

% Performance metrics
fprintf('\n--- Performance Metrics ---\n');
% Calculate RMS values
rms_position = sqrt(mean(trajectory_actual(1,:).^2));
rms_velocity = sqrt(mean(trajectory_actual(2,:).^2));
rms_angle = sqrt(mean(trajectory_actual(3,:).^2));
rms_angular_vel = sqrt(mean(trajectory_actual(4,:).^2));
rms_control = sqrt(mean(actions_actual.^2));

fprintf('RMS Position:      %.4f m\n', rms_position);
fprintf('RMS Velocity:     %.4f m/s\n', rms_velocity);
fprintf('RMS Angle:        %.4f rad\n', rms_angle);
fprintf('RMS Angular Vel:  %.4f rad/s\n', rms_angular_vel);
fprintf('RMS Control:      %.4f N\n', rms_control);

% Calculate control effort (integral of squared control)
control_effort = sum(actions_actual.^2) * params.dt;
fprintf('Total Control Effort: %.4f N²·s\n', control_effort);

fprintf('\n=== End of Summary ===\n');