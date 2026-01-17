classdef Controller < handle
    % CONTROLLER - Abstract base class for control laws
    %
    % This class provides a common interface for all control strategies,
    % making it easy to switch between different control laws and compare
    % them with RL policies.
    %
    % Subclasses should implement:
    %   - compute_action(state, params) - Returns control action
    
    methods (Abstract)
        u = compute_action(obj, state, params)
        % COMPUTE_ACTION - Compute control action given current state
        %
        % Inputs:
        %   obj - Controller instance
        %   state - Current state vector [p; p_dot; theta; theta_dot]
        %   params - System parameters structure
        %
        % Outputs:
        %   u - Control action (force)
    end
    
    methods
        function name = get_name(obj)
            % GET_NAME - Returns a human-readable name for the controller
            name = class(obj);
        end
    end
end
