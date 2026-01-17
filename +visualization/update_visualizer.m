function update_visualizer(handles, state, time, params)
% UPDATE_VISUALIZER - Update visualization with new state
%
% Inputs:
%   handles - Visualization handles structure
%   state - Current state vector [p; p_dot; theta; theta_dot]
%   time - Current simulation time
%   params - System parameters structure

if ~isvalid(handles.fig), return; end % Safety check

% Unpack State
p = state(1);
theta = state(3);

%% 1. Update Animation (Cart & Pole)
cart_w = handles.cart_w;
cart_h = handles.cart_h;

% Calculate Pole Coordinates
pole_x = p + params.L * sin(theta);
pole_y = params.L * cos(theta);
pivot_y = cart_h / 2;

% Update Cart Position
set(handles.cart, 'Position', [p - cart_w/2, 0, cart_w, cart_h]);

% Update Pole Position
set(handles.pole, 'XData', [p, pole_x], 'YData', [pivot_y, pivot_y + pole_y]);
set(handles.joint, 'XData', p, 'YData', pivot_y);

% Update view window to follow the cart for clarity
view_width = 5.0;  % meters visible on each side
x_min = max(-params.x_threshold, p - view_width);
x_max = min(params.x_threshold, p + view_width);
xlim(handles.ax_anim, [x_min, x_max]);

%% 2. Update State Plots
% Loop through the 4 states and add points to the animated lines
for i = 1:4
    addpoints(handles.lines(i), time, state(i));
end

drawnow limitrate; % Updates screen efficiently (max 20fps to save speed)
end