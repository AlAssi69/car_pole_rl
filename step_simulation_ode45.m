function next_state = step_simulation_ode45(current_state, action, params)
% MATLAB Built-in ODE45: "Ground Truth" accuracy

% Define a time span for this single step
tspan = [0, params.dt];

% Create an anonymous function because ode45 expects f(t,x)
ode_fun = @(t, x) cart_pole_dynamics(x, action, params);

% Run solver (suppress output with options if needed)
options = odeset('RelTol', 1e-6, 'AbsTol', 1e-6);
[~, x_trajectory] = ode45(ode_fun, tspan, current_state, options);

% Take the final point of the trajectory
next_state = x_trajectory(end, :)';

% Wrap angle
next_state(3) = atan2(sin(next_state(3)), cos(next_state(3)));
end