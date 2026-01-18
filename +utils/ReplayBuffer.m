classdef ReplayBuffer < handle
    % REPLAYBUFFER - Experience Replay Buffer for RL
    %
    % Stores transitions (state, action, reward, next_state, done)
    
    properties
        capacity    % Maximum number of experiences
        buffer      % Cell array to store experiences
        position    % Current position in buffer
        count       % Current number of items
    end
    
    methods
        function obj = ReplayBuffer(capacity)
            % REPLAYBUFFER - Constructor
            obj.capacity = capacity;
            obj.buffer = cell(capacity, 1);
            obj.position = 1;
            obj.count = 0;
        end
        
        function add(obj, state, action, reward, next_state, done)
            % ADD - Add an experience tuple
            
            experience = struct(...
                'state', state, ...
                'action', action, ...
                'reward', reward, ...
                'next_state', next_state, ...
                'done', done);
            
            obj.buffer{obj.position} = experience;
            
            % Circular update
            obj.position = mod(obj.position, obj.capacity) + 1;
            if obj.count < obj.capacity
                obj.count = obj.count + 1;
            end
        end
        
        function batch = sample(obj, batch_size)
            % SAMPLE - Sample a random batch of experiences
            % Returns a structure of arrays
            
            if obj.count < batch_size
                batch = [];
                return;
            end
            
            indices = randperm(obj.count, batch_size);
            raw_batch = obj.buffer(indices);
            
            % Convert cell array of structs to struct of arrays for easier processing
            % Assuming state is Nx1 vector
            
            % Get dimensions from first element
            state_dim = length(raw_batch{1}.state);
            action_dim = length(raw_batch{1}.action);
            
            states = zeros(state_dim, batch_size);
            actions = zeros(action_dim, batch_size);
            rewards = zeros(1, batch_size);
            next_states = zeros(state_dim, batch_size);
            dones = zeros(1, batch_size);
            
            for i = 1:batch_size
                e = raw_batch{i};
                states(:, i) = e.state;
                actions(:, i) = e.action;
                rewards(1, i) = e.reward;
                next_states(:, i) = e.next_state;
                dones(1, i) = e.done;
            end
            
            batch.states = states;
            batch.actions = actions;
            batch.rewards = rewards;
            batch.next_states = next_states;
            batch.dones = dones;
        end
        
        function s = size(obj)
            s = obj.count;
        end
    end
end
