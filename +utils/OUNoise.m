classdef OUNoise < handle
    % OUNOISE - Ornstein-Uhlenbeck Noise process for exploration
    %
    % Based on the provided colored_noise.m example.

    properties
        mu      % Long-term mean
        theta   % Mean reversion speed
        sigma   % Volatility
        dt      % Time step
        x_prev  % Previous noise value
    end

    methods
        function obj = OUNoise(mu, theta, sigma, dt)
            % OUNOISE - Constructor
            % Inputs:
            %   mu - Mean (default 0)
            %   theta - Reversion speed (default 0.15)
            %   sigma - Volatility (default 0.2)
            %   dt - Time step (default 0.02)

            if nargin < 1, mu = 0; end
            if nargin < 2, theta = 0.15; end
            if nargin < 3, sigma = 0.2; end
            if nargin < 4, dt = 0.02; end

            obj.mu = mu;
            obj.theta = theta;
            obj.sigma = sigma;
            obj.dt = dt;

            obj.reset();
        end

        function noise = sample(obj)
            % SAMPLE - Generate a noise sample
            % dx = theta * (mean - previous) * dt + sigma * sqrt(dt) * noise

            % Generate standard Gaussian noise
            epsilon = randn();

            % Calculate update
            dx = obj.theta * (obj.mu - obj.x_prev) * obj.dt + ...
                obj.sigma * sqrt(obj.dt) * epsilon;

            % Update state
            x_curr = obj.x_prev + dx;
            obj.x_prev = x_curr;

            noise = x_curr;
        end

        function reset(obj)
            % RESET - Reset noise state to mean
            obj.x_prev = obj.mu;
        end
    end
end
