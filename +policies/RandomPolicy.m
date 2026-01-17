classdef RandomPolicy < policies.Policy
    % RANDOMPOLICY - Random action policy (for testing/benchmarking)
    %
    % A simple policy that returns random actions within specified bounds.
    % Useful for baseline comparisons.
    
    properties
        action_min  % Minimum action value
        action_max  % Maximum action value
    end
    
    methods
        function obj = RandomPolicy(action_min, action_max)
            % RANDOMPOLICY Constructor
            %
            % Inputs:
            %   action_min - Minimum action value, default: -10
            %   action_max - Maximum action value, default: 10
            
            if nargin < 1
                action_min = -10;
            end
            if nargin < 2
                action_max = 10;
            end
            
            obj.action_min = action_min;
            obj.action_max = action_max;
        end
        
        function u = compute_action(obj, state, params)
            % COMPUTE_ACTION - Random action
            u = obj.action_min + (obj.action_max - obj.action_min) * rand();
        end
        
        function name = get_name(obj)
            name = sprintf('Random Policy [%.1f, %.1f]', obj.action_min, obj.action_max);
        end
    end
end