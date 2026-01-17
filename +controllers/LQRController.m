classdef LQRController < controllers.Controller
    % LQRCONTROLLER - Linear Quadratic Regulator
    %
    % LQR controller for the linearized cart-pole system.
    % Uses Riccati equation to compute optimal gains.
    
    properties
        K  % LQR gain vector
        Q  % State weighting matrix
        R  % Control weighting scalar
    end
    
    methods
        function obj = LQRController(Q, R)
            % LQRCONTROLLER Constructor
            %
            % Inputs:
            %   Q - State weighting matrix (4x4), default: eye(4)
            %   R - Control weighting scalar, default: 1.0
            
            if nargin < 1
                Q = eye(4);
            end
            if nargin < 2
                R = 1.0;
            end
            
            obj.Q = Q;
            obj.R = R;
            obj.K = [];  % Will be computed in initialize
        end
        
        function initialize(obj, params)
            % INITIALIZE - Compute LQR gains from linearized system
            %
            % This method linearizes the cart-pole dynamics around the
            % upright equilibrium and solves the Riccati equation.
            
            % Linearize around equilibrium: [0, 0, 0, 0]
            [A, B] = obj.linearize_system(params);
            
            % Solve Riccati equation: P = care(A, B, Q, R)
            try
                P = care(A, B, obj.Q, obj.R);
                obj.K = obj.R \ (B' * P);
            catch
                % Fallback: Use simple pole placement if care fails
                warning('LQR: Using pole placement fallback');
                desired_poles = [-2, -2.5, -3, -3.5];
                obj.K = place(A, B, desired_poles);
            end
        end
        
        function [A, B] = linearize_system(obj, params)
            % LINEARIZE_SYSTEM - Linearize cart-pole dynamics
            %
            % Linearizes around equilibrium point [0, 0, 0, 0]
            
            % System parameters
            M = params.M;
            m = params.m;
            l = params.l;
            g = params.g;
            b = params.b;
            
            % Linearized A matrix (around theta=0, so sin(theta)≈theta, cos(theta)≈1)
            A = zeros(4, 4);
            A(1, 2) = 1;  % p_dot
            A(3, 4) = 1;  % theta_dot
            
            % Linearized dynamics
            total_mass = M + m;
            denom = l * (4/3 - m / total_mass);
            
            A(2, 2) = -b / total_mass;  % p_ddot from p_dot
            A(2, 3) = m * g / total_mass;  % p_ddot from theta
            A(4, 2) = b / (total_mass * denom);  % theta_ddot from p_dot
            A(4, 3) = -g / denom;  % theta_ddot from theta
            
            % Linearized B matrix
            B = zeros(4, 1);
            B(2) = 1 / total_mass;
            B(4) = -1 / (total_mass * denom);
        end
        
        function u = compute_action(obj, state, params)
            % COMPUTE_ACTION - LQR control law
            %
            % If not initialized, initialize first
            if isempty(obj.K)
                obj.initialize(params);
            end
            
            u = -obj.K * state;
        end
        
        function name = get_name(obj)
            name = 'LQR Controller';
        end
    end
end