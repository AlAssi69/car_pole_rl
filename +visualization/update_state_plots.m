function update_state_plots(lines, state, time)
% UPDATE_STATE_PLOTS - Update state trajectory plots
%
% Inputs:
%   lines - Array of animated line handles (one per state)
%   state - Current state vector [p; p_dot; theta; theta_dot]
%   time - Current simulation time

% Push new data to the animated lines
for i = 1:4
    addpoints(lines(i), time, state(i));
end
% Force update
drawnow limitrate;
end
