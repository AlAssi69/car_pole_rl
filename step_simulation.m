function next_state = step_simulation(current_state, action, params)
% Simple Euler Integration for speed in RL training
% x_new = x + dx * dt

dx = cart_pole_dynamics(current_state, action, params);
next_state = current_state + dx * params.dt;

% Optional: Wrap angle to [-pi, pi] if needed
% next_state(3) = wrapToPi(next_state(3));
end