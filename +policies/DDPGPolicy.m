classdef DDPGPolicy < policies.Policy
    % DDPGPOLICY - Deep Deterministic Policy Gradient Policy
    %
    % Implements Actor-Critic DDPG algorithm using SimpleNN.

    properties
        actor           % Actor Network
        critic          % Critic Network
        target_actor    % Target Actor
        target_critic   % Target Critic

        noise           % OUNoise process
        buffer          % ReplayBuffer

        gamma           % Discount factor
        tau             % Soft update parameter
        actor_lr        % Actor learning rate
        critic_lr       % Critic learning rate
        batch_size      % Minibatch size

        initialized     % Flag

        action_bound    % Max action magnitude
        is_training     % Flag for exploration noise
    end

    methods
        function obj = DDPGPolicy(action_bound, config)
            % DDPGPOLICY - Constructor
            % Inputs:
            %   action_bound - (optional) Maximum action magnitude. If not provided, uses config.
            %   config - (optional) Configuration structure. If not provided, loads from utils.get_config()
            
            % Load config if not provided
            if nargin < 2
                config = utils.get_config();
            end
            
            % Use action_bound from config if not provided
            if nargin < 1 || isempty(action_bound)
                action_bound = config.ddpg.action_bound;
            end

            obj.action_bound = action_bound;
            obj.is_training = true;

            % Hyperparameters from config
            obj.gamma = config.ddpg.gamma;
            obj.tau = config.ddpg.tau;
            obj.actor_lr = config.ddpg.actor_lr;
            obj.critic_lr = config.ddpg.critic_lr;
            obj.batch_size = config.ddpg.batch_size;

            % Initialize Noise and Buffer from config
            obj.noise = utils.OUNoise(config.ddpg.noise.mu, ...
                                      config.ddpg.noise.theta, ...
                                      config.ddpg.noise.sigma, ...
                                      config.ddpg.noise.dt);
            obj.buffer = utils.ReplayBuffer(config.ddpg.buffer_capacity);

            % Networks from config
            obj.actor = utils.SimpleNN(config.ddpg.actor.layers, config.ddpg.actor.activations);
            obj.target_actor = utils.SimpleNN(config.ddpg.actor.layers, config.ddpg.actor.activations);
            obj.target_actor.copy_from(obj.actor);

            obj.critic = utils.SimpleNN(config.ddpg.critic.layers, config.ddpg.critic.activations);
            obj.target_critic = utils.SimpleNN(config.ddpg.critic.layers, config.ddpg.critic.activations);
            obj.target_critic.copy_from(obj.critic);

            obj.initialized = true;
        end

        function u = compute_action(obj, state, params)
            % COMPUTE_ACTION - Get action from policy
            % state: 4x1 vector

            % 1. Forward pass actor
            action_raw = obj.actor.forward(state);

            % 2. Add noise (exploration) if training
            if obj.is_training
                noise_val = obj.noise.sample();
                u = (action_raw + noise_val) * obj.action_bound;
            else
                u = action_raw * obj.action_bound;
            end

            % Clip
            u = max(min(u, obj.action_bound), -obj.action_bound);
        end

        function u_det = get_deterministic_action(obj, state)
            % GET_DETERMINISTIC_ACTION - For evaluation (no noise)
            action_raw = obj.actor.forward(state);
            u_det = action_raw * obj.action_bound;
        end

        function update(obj, experience)
            % UPDATE - Train the networks
            % experience: struct(state, action, reward, next_state, done)

            % 1. Add to buffer
            % Store normalized action for easier training (-1 to 1)
            action_norm = experience.action / obj.action_bound;
            obj.buffer.add(experience.state, action_norm, experience.reward, ...
                experience.next_state, experience.done);

            % 2. Check if enough samples
            if obj.buffer.count < obj.batch_size
                return;
            end

            % 3. Sample batch
            batch = obj.buffer.sample(obj.batch_size);
            states = batch.states;      % 4xN
            actions = batch.actions;    % 1xN
            rewards = batch.rewards;    % 1xN
            next_states = batch.next_states; % 4xN
            dones = batch.dones;        % 1xN

            % 4. Compute Targets
            % next_actions = TargetActor(next_states)
            next_actions = obj.target_actor.forward(next_states);

            % target_Q = TargetCritic(next_states, next_actions)
            critic_input_next = [next_states; next_actions];
            target_Q = obj.target_critic.forward(critic_input_next);

            % y = r + gamma * target_Q * (1-done)
            y = rewards + obj.gamma * target_Q .* (1 - dones);

            % 5. Update Critic
            % Q_pred = Critic(states, actions)
            critic_input = [states; actions];
            [Q_pred, cache_critic] = obj.critic.forward(critic_input);

            % Loss = MSE = mean((y - Q_pred)^2)
            % dLoss/dQ = -2/N * (y - Q_pred)  (or just y-Q for simpler gradient step scaling)
            % Let's use 1/N scaling in gradient application or implicit
            diff = Q_pred - y;
            critic_loss = mean(diff.^2);

            d_out_critic = 2 * diff / obj.batch_size;

            [grads_critic, ~] = obj.critic.backward(d_out_critic, cache_critic);
            obj.critic.update(grads_critic, obj.critic_lr);

            % 6. Update Actor
            % Maximize Q(s, Actor(s)) -> Minimize -Q

            % a_pred = Actor(s)
            [a_pred, cache_actor] = obj.actor.forward(states);

            % Q_actor = Critic(s, a_pred)
            critic_input_actor = [states; a_pred];
            [~, cache_critic_for_actor] = obj.critic.forward(critic_input_actor);

            % We want gradient of Q w.r.t a_pred
            % d(-Q)/dQ = -1
            d_out_Q = -ones(size(rewards)) / obj.batch_size;

            [~, d_input_critic] = obj.critic.backward(d_out_Q, cache_critic_for_actor);

            % Extract gradient w.r.t action (last component of input)
            % Input to critic was [state; action] (4+1 rows)
            % d_input_critic is 5xN. Action is row 5.
            d_action = d_input_critic(5:end, :);

            % Backprop through Actor
            [grads_actor, ~] = obj.actor.backward(d_action, cache_actor);
            obj.actor.update(grads_actor, obj.actor_lr);

            % 7. Soft Updates
            obj.target_critic.soft_update(obj.critic, obj.tau);
            obj.target_actor.soft_update(obj.actor, obj.tau);
        end

        function reset(obj)
            obj.noise.reset();
        end
    end
end
