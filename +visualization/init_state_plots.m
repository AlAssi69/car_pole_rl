function lines = init_state_plots(fig_handle)
% INIT_STATE_PLOTS - Initialize state trajectory plots
%
% Inputs:
%   fig_handle - Figure handle to create plots in
%
% Outputs:
%   lines - Array of animated line handles (4 states + 1 control input)

% Set target figure
set(0, 'CurrentFigure', fig_handle);

titles = {'Cart Position (p)', 'Cart Velocity (v)', ...
    'Pole Angle (\theta)', 'Pole Angular Vel (\omega)', 'Control Input (u)'};
ylabels = {'m', 'm/s', 'rad', 'rad/s', 'N'};

lines = gobjects(1, 5); % Pre-allocate array for line handles (4 states + 1 control)

for i = 1:5
    % Create subplot (5 rows, 1 column)
    ax = subplot(5, 1, i);
    grid(ax, 'on'); box(ax, 'on'); hold(ax, 'on');
    
    % Create animated line (faster than plot)
    % Use red color for control input (5th plot), blue for states
    if i == 5
        lines(i) = animatedline(ax, 'Color', 'r', 'LineWidth', 1.5);
    else
        lines(i) = animatedline(ax, 'Color', 'b', 'LineWidth', 1.5);
    end
    
    % Formatting
    title(ax, titles{i}, 'FontWeight', 'bold');
    ylabel(ax, ylabels{i});
    if i == 5
        xlabel(ax, 'Time (s)');
    else
        set(ax, 'XTickLabel', []); % Hide x-labels for top plots
    end
end
end