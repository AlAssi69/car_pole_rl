%% RUN_COMPARISON - Compare multiple controllers and policies
%
% This script runs multiple control strategies and compares their
% performance, making ablation studies easy.
%
% Usage:
%   results = run_comparison();
%   results = run_comparison('controllers', {'PD', 'LQR'}, 'max_steps', 1000);

function results = run_comparison(varargin)
%% Parse inputs
% Load config for defaults
config = utils.get_config();

p = inputParser;
addParameter(p, 'controllers', {'PD'}, @iscell);
addParameter(p, 'policies', {}, @iscell);
addParameter(p, 'max_steps', config.simulation.max_steps, @isnumeric);
addParameter(p, 'initial_state', config.initial_state.evaluation, @isnumeric);
addParameter(p, 'integration', config.simulation.integration_method, @ischar);
addParameter(p, 'visualize', config.visualization.system, @islogical);
parse(p, varargin{:});

%% Setup
params = utils.get_sys_params();

% Select integration method
switch lower(p.Results.integration)
    case 'euler'
        step_func = @integration.euler;
    case 'rk4'
        step_func = @integration.rk4;
    case {'ode45', 'ode45_integration'}
        step_func = @integration.ode45_integration;
    otherwise
        error('Unknown integration method: %s', p.Results.integration);
end

%% Initialize strategies
strategies = {};
strategy_names = {};

% Add controllers
for i = 1:length(p.Results.controllers)
    name = p.Results.controllers{i};
    switch upper(name)
        case 'PD'
            strategies{end+1} = controllers.PDController(config.controller.PD.gains);
            strategy_names{end+1} = 'PD Controller';
        case 'LQR'
            ctrl = controllers.LQRController(config.controller.LQR.Q, config.controller.LQR.R);
            ctrl.initialize(params);
            strategies{end+1} = ctrl;
            strategy_names{end+1} = 'LQR Controller';
        otherwise
            warning('Unknown controller: %s', name);
    end
end

% Add policies
for i = 1:length(p.Results.policies)
    name = p.Results.policies{i};
    switch upper(name)
        case 'RANDOM'
            strategies{end+1} = policies.RandomPolicy(-10, 10);
            strategy_names{end+1} = 'Random Policy';
        otherwise
            warning('Unknown policy: %s', name);
    end
end

if isempty(strategies)
    error('No valid strategies specified');
end

%% Run simulations
fprintf('Running comparison with %d strategies...\n', length(strategies));
results = struct();

for s = 1:length(strategies)
    strategy = strategies{s};
    name = strategy_names{s};
    fprintf('\n[%d/%d] Running: %s\n', s, length(strategies), name);

    % Initialize
    state = p.Results.initial_state;
    time = 0;
    trajectory = zeros(4, p.Results.max_steps);
    actions = zeros(1, p.Results.max_steps);
    times = zeros(1, p.Results.max_steps);

    % Setup visualization if requested
    if p.Results.visualize
        fig = figure('Name', sprintf('Simulation: %s', name), ...
            'Position', [100 + 50*s, 100 + 50*s, 600, 400]);
        handles = visualization.init_visualizer(params);
    end

    % Run simulation
    for step = 1:p.Results.max_steps
        % Compute action
        u = strategy.compute_action(state, params);

        % Step simulation
        state = step_func(state, u, params);
        time = time + params.dt;

        % Store data
        trajectory(:, step) = state;
        actions(step) = u;
        times(step) = time;

        % Update visualization
        if p.Results.visualize && isvalid(handles.fig)
            visualization.update_visualizer(handles, state, time, params);
            pause(0.01);
        end

        % Check for failure
        if abs(state(1)) > params.x_threshold || abs(state(3)) > params.theta_threshold
            fprintf('  Failed at step %d\n', step);
            break;
        end
    end

    % Store results
    results.(matlab.lang.makeValidName(name)) = struct(...
        'name', name, ...
        'trajectory', trajectory(:, 1:step), ...
        'actions', actions(1:step), ...
        'times', times(1:step), ...
        'steps', step, ...
        'final_state', state);

    fprintf('  Completed: %d steps\n', step);
end

%% Display summary
fprintf('\n=== Comparison Summary ===\n');
fprintf('%-20s | Steps\n', 'Strategy');
fprintf('%-20s-|-------\n', repmat('-', 1, 20));
names = fieldnames(results);
for i = 1:length(names)
    r = results.(names{i});
    fprintf('%-20s | %d\n', r.name, r.steps);
end
fprintf('\n');
end