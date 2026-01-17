function params = get_sys_params()
%% Physical Parameters
params.M = 1.0;       % Mass of the cart (kg)
params.m = 0.1;       % Mass of the pole (kg)
params.L = 1.0;       % Full length of the pole (m)
params.l = params.L/2;% Distance to center of mass (m)
params.g = 9.81;      % Gravity (m/s^2)
params.b = 0.1;       % Coefficient of friction for cart (N/m/s)

%% Simulation Settings
params.dt = 0.02;     % Time step for RL/Simulation (seconds)
params.x_threshold = 2.4;  % Limit for cart position
params.theta_threshold = 12 * pi / 180; % Limit for pole angle (12 deg)
end