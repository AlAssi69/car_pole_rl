classdef PDController < controllers.Controller
    % PDCONTROLLER - Proportional-Derivative controller
    %
    % A simple PD controller with gains K = [Kp, Kd_p, Ktheta, Kd_theta]
    % Control law: u = -K * state
    
    properties
        K  % Gain vector [Kp, Kd_p, Ktheta, Kd_theta]
    end
    
    methods
        function obj = PDController(K)
            % PDCONTROLLER Constructor
            %
            % Inputs:
            %   K - Gain vector [Kp, Kd_p, Ktheta, Kd_theta]
            %       Default: [-2, -2, -30, -5]
            
            if nargin < 1
                % Default gains
                K = [-2, -2, -30, -5];
            end
            
            obj.K = K(:);  % Ensure column vector
        end
        
        function u = compute_action(obj, state, params)
            % COMPUTE_ACTION - PD control law
            u = -obj.K' * state;
        end
        
        function name = get_name(obj)
            name = sprintf('PD Controller (K=[%.1f, %.1f, %.1f, %.1f])', ...
                obj.K(1), obj.K(2), obj.K(3), obj.K(4));
        end
    end
end
