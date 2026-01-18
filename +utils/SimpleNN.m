classdef SimpleNN < handle
    % SIMPLENN - A simple fully-connected neural network for RL
    % Supports ReLU, Tanh, Linear activations.
    % Implements manual backpropagation.

    properties
        layer_sizes % Array of layer sizes [input, hidden1, ..., output]
        activation_funcs % Cell array of activation functions for each layer (except input)
        weights % Cell array of weight matrices
        biases  % Cell array of bias vectors
    end

    methods
        function obj = SimpleNN(layer_sizes, activations)
            % SIMPLENN - Constructor
            % layer_sizes: [n_in, n_h1, ..., n_out]
            % activations: cell array of strings, length = length(layer_sizes)-1

            obj.layer_sizes = layer_sizes;
            obj.activation_funcs = activations;

            obj.weights = cell(1, length(layer_sizes)-1);
            obj.biases = cell(1, length(layer_sizes)-1);

            % He Initialization / Xavier
            for i = 1:length(layer_sizes)-1
                n_in = layer_sizes(i);
                n_out = layer_sizes(i+1);

                % Xavier/Glorot initialization for Tanh/Linear, He for ReLU
                if strcmpi(activations{i}, 'relu')
                    scale = sqrt(2/n_in);
                else
                    scale = sqrt(1/n_in);
                end

                obj.weights{i} = randn(n_out, n_in) * scale;
                obj.biases{i} = zeros(n_out, 1);
            end
        end

        function [output, cache] = forward(obj, input)
            % FORWARD - Forward pass
            % input: (input_dim x batch_size)

            num_layers = length(obj.weights);
            cache = cell(num_layers, 2); % Store {Z, A} for each layer

            A = input;

            for i = 1:num_layers
                W = obj.weights{i};
                b = obj.biases{i};

                Z = W * A + b; % Broadcast b automatically in modern MATLAB

                func = obj.activation_funcs{i};
                if strcmpi(func, 'relu')
                    A_next = max(0, Z);
                elseif strcmpi(func, 'tanh')
                    A_next = tanh(Z);
                elseif strcmpi(func, 'linear')
                    A_next = Z;
                else
                    error('Unknown activation: %s', func);
                end

                cache{i, 1} = input; % Store input to this layer (A_prev)
                cache{i, 2} = Z;     % Store Z for backprop

                input = A_next; % For next iteration
                A = A_next;
            end

            output = A;
        end

        function [grads, dx] = backward(obj, dout, cache)
            % BACKWARD - Backward pass
            % dout: Gradient of loss w.r.t output (output_dim x batch_size)
            % cache: From forward pass
            %
            % Returns:
            %   grads: struct with dW and db cell arrays
            %   dx: Gradient w.r.t input (for chaining, e.g. Critic -> Actor)

            num_layers = length(obj.weights);
            dW = cell(1, num_layers);
            db = cell(1, num_layers);

            delta = dout;

            for i = num_layers:-1:1
                A_prev = cache{i, 1};
                Z = cache{i, 2};
                func = obj.activation_funcs{i};

                % 1. dActivation
                if strcmpi(func, 'relu')
                    dZ = delta;
                    dZ(Z <= 0) = 0;
                elseif strcmpi(func, 'tanh')
                    dZ = delta .* (1 - tanh(Z).^2);
                elseif strcmpi(func, 'linear')
                    dZ = delta;
                end

                % 2. Gradients
                m = size(Z, 2);
                dW{i} = (dZ * A_prev') / m;
                db{i} = sum(dZ, 2) / m;

                % 3. Propagate back
                if i > 1 || nargout > 1
                    delta = obj.weights{i}' * dZ;
                end
            end

            grads.dW = dW;
            grads.db = db;

            if nargout > 1
                dx = delta;
            end
        end

        function update(obj, grads, learning_rate)
            % UPDATE - Update weights using gradients
            for i = 1:length(obj.weights)
                obj.weights{i} = obj.weights{i} - learning_rate * grads.dW{i};
                obj.biases{i} = obj.biases{i} - learning_rate * grads.db{i};
            end
        end

        function soft_update(obj, other_net, tau)
            % SOFT_UPDATE - Polyak averaging: theta = tau*other + (1-tau)*theta
            for i = 1:length(obj.weights)
                obj.weights{i} = tau * other_net.weights{i} + (1-tau) * obj.weights{i};
                obj.biases{i} = tau * other_net.biases{i} + (1-tau) * obj.biases{i};
            end
        end

        function copy_from(obj, other_net)
            % COPY_FROM - Hard copy weights
            obj.weights = other_net.weights;
            obj.biases = other_net.biases;
        end
    end
end
