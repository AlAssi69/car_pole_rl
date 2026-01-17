# Cart-Pole Control & RL Framework

This codebase provides a modular framework for comparing control theory approaches with reinforcement learning policies on the cart-pole system.

## Package Structure

The code is organized into packages (MATLAB namespaces) for easy extension and comparison:

```
PTR/
├── +dynamics/          # System dynamics
│   └── cart_pole_dynamics.m
├── +integration/       # Numerical integration methods
│   ├── euler.m
│   ├── rk4.m
│   └── ode45.m
├── +controllers/       # Control theory approaches
│   ├── Controller.m    # Abstract base class
│   ├── PDController.m  # Proportional-Derivative controller
│   └── LQRController.m # Linear Quadratic Regulator
├── +policies/          # RL policies
│   ├── Policy.m        # Abstract base class
│   └── RandomPolicy.m  # Random baseline
├── +visualization/     # Visualization tools
│   ├── init_visualizer.m
│   ├── update_visualizer.m
│   ├── visualize_system.m
│   ├── init_state_plots.m
│   └── update_state_plots.m
├── +utils/             # Utilities
│   └── get_sys_params.m
├── main.m              # Main simulation script
└── run_comparison.m    # Comparison script for ablation studies
```

## Usage

### Basic Simulation

Run a single simulation with a controller or policy:

```matlab
% Edit main.m to select your strategy:
USE_CONTROLLER = true;
controller = controllers.PDController([-2, -2, -30, -5]);
% or
USE_CONTROLLER = false;
policy = policies.RandomPolicy(-10, 10);

% Then run:
main
```

### Comparison Studies

Compare multiple controllers and policies:

```matlab
% Compare PD and LQR controllers
results = run_comparison('controllers', {'PD', 'LQR'}, ...
                         'max_steps', 1000, ...
                         'visualize', false);

% Compare controllers vs policies
results = run_comparison('controllers', {'PD', 'LQR'}, ...
                         'policies', {'Random'}, ...
                         'max_steps', 500);
```

## Adding New Controllers

1. Create a new class in `+controllers/` that inherits from `controllers.Controller`
2. Implement the `compute_action(state, params)` method
3. Optionally override `get_name()` for better display

Example:
```matlab
classdef MyController < controllers.Controller
    methods
        function u = compute_action(obj, state, params)
            % Your control law here
            u = ...;
        end
    end
end
```

## Adding New RL Policies

1. Create a new class in `+policies/` that inherits from `policies.Policy`
2. Implement the `compute_action(state, params)` method
3. Optionally implement `update(experience)` for learning policies
4. Optionally override `get_name()` for better display

Example:
```matlab
classdef MyPolicy < policies.Policy
    properties
        network  % Neural network, etc.
    end
    
    methods
        function u = compute_action(obj, state, params)
            % Your policy here
            u = ...;
        end
        
        function update(obj, experience)
            % Update policy from experience
        end
    end
end
```

## Design Philosophy

- **Separation of Concerns**: Dynamics, integration, control, and visualization are separate
- **Easy Ablation**: Switch between strategies with a single line change
- **Extensible**: Add new controllers/policies without modifying existing code
- **Unified Interface**: All controllers and policies share the same interface

## Integration Methods

- `integration.euler`: Fastest, least accurate (good for RL training)
- `integration.rk4`: Balanced speed/accuracy (recommended)
- `integration.ode45_integration`: Most accurate, slowest (ground truth)

## Future RL Policies

The framework is ready for:
- PPO (Proximal Policy Optimization)
- DQN (Deep Q-Network)
- SAC (Soft Actor-Critic)
- TD3 (Twin Delayed DDPG)
- And more...

Each can be added as a new class in `+policies/` following the `Policy` interface.
