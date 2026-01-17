function visualize_system(x, params, fig_handle, step, max_steps)
% VISUALIZE_SYSTEM - Simple visualization of cart-pole system
%
% Inputs:
%   x - State vector [p; p_dot; theta; theta_dot]
%   params - System parameters structure
%   fig_handle - Figure handle to draw in
%   step - Current simulation step
%   max_steps - Maximum number of steps

% Set the current figure
set(0, 'CurrentFigure', fig_handle);
clf; hold on; grid on;

% Unpack state
p = x(1);
theta = x(3);

%% Geometry Calculations
% Cart dimensions
cart_w = 0.5;
cart_h = 0.3;

% Pole end position
pole_x = p + params.L * sin(theta);
pole_y = params.L * cos(theta);

%% Rendering
% Draw Ground
line([-params.x_threshold, params.x_threshold], [0, 0], 'Color', 'k', 'LineWidth', 2);

% Draw Cart (Rectangle)
rectangle('Position', [p - cart_w/2, 0, cart_w, cart_h], ...
    'FaceColor', [0.2, 0.2, 0.8], 'Curvature', 0.1);

% Draw Pole (Line)
% Pivot point is center of cart top
pivot_y = cart_h / 2;
line([p, pole_x], [pivot_y, pivot_y + pole_y], ...
    'Color', [0.8, 0.2, 0.2], 'LineWidth', 4);

% Draw Pivot Joint
plot(p, pivot_y, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 6);

%% Formatting
axis equal;  % Make axes equal to prevent distortion

% Use a reasonable view window centered on the cart for clarity
% View window size: show about 5 meters on each side of the cart
view_width = 5.0;  % meters visible on each side
x_min = max(-params.x_threshold, p - view_width);
x_max = min(params.x_threshold, p + view_width);
xlim([x_min, x_max]);
ylim([-1, 2]);
title(sprintf('Cart-Pole System\nPosition: %.2f m | Angle: %.2f rad | Step: %d/%d', p, theta, step, max_steps));
drawnow;
end