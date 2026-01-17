function dx = cart_pole_dynamics(x, u, params)
% CART_POLE_DYNAMICS - Non-linear dynamics of the cart-pole system
% 
% Inputs:
%   x - State vector [p; p_dot; theta; theta_dot]
%       x(1): Cart Position (p)
%       x(2): Cart Velocity (p_dot)
%       x(3): Pole Angle (theta) - 0 is upright
%       x(4): Pole Angular Velocity (theta_dot)
%   u - Control input (force applied to cart)
%   params - System parameters structure
%
% Outputs:
%   dx - State derivative vector

% Unpack state
p_dot = x(2);
theta = x(3);
theta_dot = x(4);

% Force limiting (optional, but realistic for RL)
% u = max(-10, min(10, u));

%% Pre-calculations for readability
costheta = cos(theta);
sintheta = sin(theta);
total_mass = params.M + params.m;

%% Equations of Motion (Non-Linear)
% Derived from Lagrangian mechanics

% Denominator for the coupled equations
temp = (u + params.m * params.l * theta_dot^2 * sintheta - params.b * p_dot) / total_mass;

denom = params.l * (4/3 - params.m * costheta^2 / total_mass);

% Angular Acceleration (theta_doubledot)
theta_ddot = (params.g * sintheta - costheta * temp) / denom;

% Linear Acceleration (p_doubledot)
p_ddot = temp - (params.m * params.l * theta_ddot * costheta) / total_mass;

%% Return State Derivative
dx = zeros(4, 1);
dx(1) = p_dot;
dx(2) = p_ddot;
dx(3) = theta_dot;
dx(4) = theta_ddot;
end
