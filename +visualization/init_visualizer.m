function handles = init_visualizer(params)
% INIT_VISUALIZER - Initialize visualization figure and handles
%
% Inputs:
%   params - System parameters structure
%
% Outputs:
%   handles - Structure containing figure and graphics handles

% Create a full-screen figure
fig = figure('Name', 'RL Training Monitor', 'Color', 'w', ...
    'Units', 'normalized', 'Position', [0.1 0.1 0.8 0.8]);

%% 1. Animation Subplot (Left Side)
ax_anim = subplot(2, 3, [1, 4]); % Spans 2 rows
hold(ax_anim, 'on'); grid(ax_anim, 'on'); axis(ax_anim, 'equal');
% Use a reasonable initial view window for clarity
view_width = 5.0;  % meters visible on each side
xlim(ax_anim, [-view_width view_width]); ylim(ax_anim, [-1.5 2]);
xlabel(ax_anim, 'Position (m)');
title(ax_anim, 'System Animation');

% Draw Ground
line(ax_anim, [-params.x_threshold params.x_threshold], [0 0], 'Color', 'k', 'LineWidth', 2);

% Initialize Graphics Objects (Cart and Pole)
% We create them once and just move them later
h_cart = rectangle(ax_anim, 'Position', [0 0 0 0], 'FaceColor', [0.2 0.2 0.8], 'Curvature', 0.1);
h_pole = line(ax_anim, [0 0], [0 0], 'Color', [0.8 0.2 0.2], 'LineWidth', 4);
h_joint = plot(ax_anim, 0, 0, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 6);

%% 2. State Plots (Right Side) using AnimatedLines
titles = {'Cart Position (p)', 'Cart Velocity (v)', ...
    'Pole Angle (\theta)', 'Pole Angular Vel (\omega)'};
ylabels = {'m', 'm/s', 'rad', 'rad/s'};

state_lines = gobjects(1, 4); % Array to store line handles

% Create 4 subplots
plot_indices = [2, 3, 5, 6]; % Grid positions
for i = 1:4
    ax = subplot(2, 3, plot_indices(i));
    grid(ax, 'on'); box(ax, 'on');
    
    % Create an animated line (highly optimized for loops)
    state_lines(i) = animatedline(ax, 'Color', 'b', 'LineWidth', 1.5);
    
    title(ax, titles{i});
    ylabel(ax, ylabels{i});
    xlabel(ax, 'Time (s)');
    
    % Set dynamic limits logic if needed later
end

%% Pack handles into a struct
handles.fig = fig;
handles.ax_anim = ax_anim; % Store axes handle for dynamic view updates
handles.cart = h_cart;
handles.pole = h_pole;
handles.joint = h_joint;
handles.lines = state_lines; % Vector of 4 animated lines
handles.cart_w = 0.6; % Cart width for drawing
handles.cart_h = 0.3; % Cart height for drawing
end