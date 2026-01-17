function lines = init_state_plots(fig_handle)
% INIT_STATE_PLOTS - Initialize state trajectory plots
%
% Inputs:
%   fig_handle - Figure handle to create plots in
%
% Outputs:
%   lines - Array of animated line handles (one per state)

% Set target figure
set(0, 'CurrentFigure', fig_handle);

titles = {'Cart Position (p)', 'Cart Velocity (v)', ...
    'Pole Angle (\theta)', 'Pole Angular Vel (\omega)'};
ylabels = {'m', 'm/s', 'rad', 'rad/s'};

lines = gobjects(1, 4); % Pre-allocate array for line handles

for i = 1:4
    % Create subplot (4 rows, 1 column)
    ax = subplot(4, 1, i);
    grid(ax, 'on'); box(ax, 'on'); hold(ax, 'on');
    
    % Create animated line (faster than plot)
    lines(i) = animatedline(ax, 'Color', 'b', 'LineWidth', 1.5);
    
    % Formatting
    title(ax, titles{i}, 'FontWeight', 'bold');
    ylabel(ax, ylabels{i});
    if i == 4
        xlabel(ax, 'Time (s)');
    else
        set(ax, 'XTickLabel', []); % Hide x-labels for top plots
    end
end
end