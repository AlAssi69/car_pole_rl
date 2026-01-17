function next_state = step_simulation_rk4(current_state, action, params)
% RK4 Integration: Best balance of Speed vs. Accuracy for RL

dt = params.dt;

% k1: Slope at the beginning
k1 = cart_pole_dynamics(current_state, action, params);

% k2: Slope at the midpoint (using k1)
k2 = cart_pole_dynamics(current_state + 0.5 * dt * k1, action, params);

% k3: Slope at the midpoint (using k2)
k3 = cart_pole_dynamics(current_state + 0.5 * dt * k2, action, params);

% k4: Slope at the end
k4 = cart_pole_dynamics(current_state + dt * k3, action, params);

% Weighted average
next_state = current_state + (dt / 6) * (k1 + 2*k2 + 2*k3 + k4);

% Crucial: Wrap angle to [-pi, pi] for the Neural Network
% This ensures the agent knows that 359 degrees is close to 1 degree.
next_state(3) = atan2(sin(next_state(3)), cos(next_state(3)));
end