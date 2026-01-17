classdef Policy < handle
    % POLICY - Abstract base class for RL policies
    %
    % This class provides a common interface for all RL policies,
    % making it easy to switch between different algorithms and compare
    % them with control theory approaches.
    %
    % Subclasses should implement:
    %   - compute_action(state, params) - Returns control action
    %   - update(experience) - Update policy from experience (for learning)
    
    methods (Abstract)
        u = compute_action(obj, state, params)
        % COMPUTE_ACTION - Compute action given current state
        %
        % Inputs:
        %   obj - Policy instance
        %   state - Current state vector [p; p_dot; theta; theta_dot]
        %   params - System parameters structure
        %
        % Outputs:
        %   u - Control action (force)
    end
    
    methods
        function name = get_name(obj)
            % GET_NAME - Returns a human-readable name for the policy
            name = class(obj);
        end
        
        function update(obj, experience)
            % UPDATE - Update policy from experience (optional for non-learning policies)
            %
            % Inputs:
            %   experience - Structure containing (state, action, reward, next_state, done)
            %
            % Default implementation does nothing (for non-learning policies)
        end
        
        function reset(obj)
            % RESET - Reset policy state (e.g., for new episode)
            % Default implementation does nothing
        end
    end
end