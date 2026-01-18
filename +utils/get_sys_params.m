function params = get_sys_params()
% GET_SYS_PARAMS - Returns system parameters for cart-pole simulation
%
% This function now uses the centralized config for consistency.
% For backward compatibility, it returns parameters in the original format.
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

% Get centralized config
config = utils.get_config();

% Extract physical parameters
params.M = config.physical.M;
params.m = config.physical.m;
params.L = config.physical.L;
params.l = config.physical.l;
params.g = config.physical.g;
params.b = config.physical.b;

% Extract simulation settings
params.dt = config.simulation.dt;
params.x_threshold = config.simulation.x_threshold;
params.theta_threshold = config.simulation.theta_threshold;
params.v_threshold = config.simulation.v_threshold;
params.omega_threshold = config.simulation.omega_threshold;
end