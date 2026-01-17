%% Main Simulation Loop
% This script demonstrates the refactored package structure for easy
% comparison between control theory approaches and RL policies.
%
% To switch between different controllers/policies, simply change the
% 'controller' or 'policy' variable below.

clc; clear; close all;

%% Configuration
% Choose your control strategy:
% Option 1: Use a controller (control theory approach)
USE_CONTROLLER = true;  % Set to false to use a policy instead

if USE_CONTROLLER
    % Available controllers:
    %   - controllers.PDController([Kp, Kd_p, Ktheta, Kd_theta])
    %   - controllers.LQRController(Q, R)
    controller = controllers.PDController([-2, -2, -30, -5]);
    % controller = controllers.LQRController(eye(4), 1.0);
    strategy_name = controller.get_name();
else
    % Available policies:
    %   - policies.RandomPolicy(action_min, action_max)
    %   - (Future: PPO, DQN, etc.)
    policy = policies.RandomPolicy(-10, 10);
    strategy_name = policy.get_name();
end

% Choose integration method:
%   - integration.euler (fastest, least accurate)
%   - integration.rk4 (balanced, recommended)
%   - integration.ode45_integration (most accurate, slowest)
step_func = @integration.rk4;

% Simulation parameters
max_steps = 500;

%% 1. Load Parameters
params = utils.get_sys_params();

% 2. Initial State [p; p_dot; theta; theta_dot]
% Start slightly tilted (0.1 rad) so we see it move
state = [0; 0; 0.1; 0];
time = 0;

% 3. Setup Figures
% Figure A: System Animation (The Cart & Pole)
fig_anim = figure('Name', 'System Animation', 'Color', 'w', ...
    'Position', [100, 500, 600, 400]);

% Figure B: State Plots (The Graphs)
fig_states = figure('Name', 'State Trajectories', 'Color', 'w', ...
    'Position', [750, 100, 500, 800]);

% Initialize the 4x1 State Plots and get handles to lines
state_lines = visualization.init_state_plots(fig_states);

fprintf('Starting Simulation with: %s\n', strategy_name);
fprintf('Press Ctrl+C to stop.\n\n');

%% 4. Simulation Loop
for step = 1:max_steps
    % A. Compute Action
    if USE_CONTROLLER
        u = controller.compute_action(state, params);
    else
        u = policy.compute_action(state, params);
    end
    
    % B. Step Physics
    state = step_func(state, u, params);
    time = time + params.dt;
    
    % C. Visualize System (Figure A)
    if isvalid(fig_anim)
        visualization.visualize_system(state, params, fig_anim, step, max_steps);
    else
        break; % Stop if window is closed
    end
    
    % D. Update State Plots (Figure B)
    if isvalid(fig_states)
        visualization.update_state_plots(state_lines, state, time);
    end
    
    % E. Sync Speed
    % Limit update rate slightly to keep animation smooth
    pause(params.dt);
end

fprintf('\nSimulation completed.\n');
