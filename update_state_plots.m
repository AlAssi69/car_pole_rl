function update_state_plots(lines, state, time)
% Push new data to the animated lines
for i = 1:4
    addpoints(lines(i), time, state(i));
end
% Force update
drawnow limitrate;
end