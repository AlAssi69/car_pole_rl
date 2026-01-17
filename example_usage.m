%% EXAMPLE_USAGE - Examples of using the refactored framework
%
% This script demonstrates various ways to use the package structure
% for comparing controllers and policies.

clc; clear; close all;

%% Example 1: Simple simulation with PD controller
fprintf('=== Example 1: PD Controller ===\n');
params = utils.get_sys_params();
controller = controllers.PDController([-2, -2, -30, -5]);
state = [0; 0; 0.1; 0];

for i = 1:10
    u = controller.compute_action(state, params);
    state = integration.rk4(state, u, params);
    fprintf('Step %d: u=%.2f, theta=%.3f\n', i, u, state(3));
end

%% Example 2: Compare multiple controllers
fprintf('\n=== Example 2: Controller Comparison ===\n');
results = run_comparison('controllers', {'PD', 'LQR'}, ...
                         'max_steps', 200, ...
                         'visualize', false);

% Access results
pd_result = results.PDController;
lqr_result = results.LQRController;

fprintf('PD Controller: %d steps\n', pd_result.steps);
fprintf('LQR Controller: %d steps\n', lqr_result.steps);

%% Example 3: Compare controller vs policy
fprintf('\n=== Example 3: Controller vs Policy ===\n');
results = run_comparison('controllers', {'PD'}, ...
                         'policies', {'Random'}, ...
                         'max_steps', 100, ...
                         'visualize', false);

%% Example 4: Custom controller usage
fprintf('\n=== Example 4: Custom Controller ===\n');
% Create controller with custom gains
pd_custom = controllers.PDController([-5, -3, -40, -8]);
fprintf('Controller: %s\n', pd_custom.get_name());

% Test it
state = [0; 0; 0.1; 0];
u = pd_custom.compute_action(state, params);
fprintf('Action at state [0, 0, 0.1, 0]: u = %.2f\n', u);

%% Example 5: LQR controller with custom weights
fprintf('\n=== Example 5: Custom LQR Controller ===\n');
% LQR with emphasis on angle control
Q = diag([1, 1, 10, 1]);  % High weight on angle
R = 0.1;  % Low control cost
lqr_custom = controllers.LQRController(Q, R);
lqr_custom.initialize(params);
fprintf('LQR Controller initialized\n');

% Test it
state = [0; 0; 0.1; 0];
u = lqr_custom.compute_action(state, params);
fprintf('Action at state [0, 0, 0.1, 0]: u = %.2f\n', u);

fprintf('\n=== Examples Complete ===\n');
