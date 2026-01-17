function params = get_sys_params()
% GET_SYS_PARAMS - Returns system parameters for cart-pole simulation
%
% Outputs:
%   params - Structure containing:
%       M - Mass of the cart (kg)
%       m - Mass of the pole (kg)
%       L - Full length of the pole (m)
%       l - Distance to center of mass (m)
%       g - Gravity (m/s^2)
%       b - Coefficient of friction for cart (N/m/s)
%       dt - Time step for simulation (seconds)
%       x_threshold - Limit for cart position (m)
%       theta_threshold - Limit for pole angle (rad)
%       v_threshold - Limit for cart velocity (m/s)
%       omega_threshold - Limit for pole angular velocity (rad/s)

%% Physical Parameters
params.M = 1.0;       % Mass of the cart (kg)
params.m = 0.1;       % Mass of the pole (kg)
params.L = 1.0;       % Full length of the pole (m)
params.l = params.L/2;% Distance to center of mass (m)
params.g = 9.81;      % Gravity (m/s^2)
params.b = 0.1;       % Coefficient of friction for cart (N/m/s)

%% Simulation Settings
params.dt = 0.02;     % Time step for RL/Simulation (seconds)
params.x_threshold = 5;  % Limit for cart position
params.theta_threshold = 360 * pi / 180; % Limit for pole angle (12 deg)
params.v_threshold = 100.0;  % Limit for cart velocity (m/s)
params.omega_threshold = 100.0;  % Limit for pole angular velocity (rad/s)
end