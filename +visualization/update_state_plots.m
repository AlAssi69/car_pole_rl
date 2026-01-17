function update_state_plots(lines, state, time, u)
% UPDATE_STATE_PLOTS - Update state trajectory plots
%
% Inputs:
%   lines - Array of animated line handles (4 states + 1 control)
%   state - Current state vector [p; p_dot; theta; theta_dot]
%   time - Current simulation time
%   u - Control input (force)

% Push new data to the animated lines for states
for i = 1:4
    addpoints(lines(i), time, state(i));
end
% Push control input to the 5th plot
addpoints(lines(5), time, u);
% Force update
drawnow limitrate;
end