# Configuration Guide

This project uses a centralized configuration system to manage all parameters and hyperparameters. All configuration is defined in `+utils/get_config.m`.

## Usage

To access the configuration anywhere in the project:

```matlab
config = utils.get_config();
```

## Configuration Structure

The configuration is organized into logical sections:

### `config.physical`
Physical system parameters:
- `M` - Mass of the cart (kg)
- `m` - Mass of the pole (kg)
- `L` - Full length of the pole (m)
- `l` - Distance to center of mass (m)
- `g` - Gravity (m/s²)
- `b` - Coefficient of friction for cart (N/m/s)

### `config.simulation`
Simulation settings:
- `dt` - Time step (seconds)
- `max_steps` - Maximum steps per episode
- `x_threshold` - Cart position limit (m)
- `theta_threshold` - Pole angle limit (rad)
- `v_threshold` - Cart velocity limit (m/s)
- `omega_threshold` - Pole angular velocity limit (rad/s)
- `integration_method` - 'euler', 'rk4', or 'ode45'

### `config.ddpg`
DDPG algorithm hyperparameters:
- `gamma` - Discount factor
- `tau` - Soft update parameter (Polyak averaging)
- `actor_lr` - Actor learning rate
- `critic_lr` - Critic learning rate
- `batch_size` - Minibatch size
- `buffer_capacity` - Experience replay buffer size
- `action_bound` - Maximum action magnitude (N)

### `config.ddpg.actor` / `config.ddpg.critic`
Network architecture:
- `layers` - Array of layer sizes
- `activations` - Cell array of activation functions

### `config.ddpg.noise`
Ornstein-Uhlenbeck noise parameters:
- `mu` - Long-term mean
- `theta` - Mean reversion speed
- `sigma` - Volatility
- `dt` - Time step

### `config.training`
Training parameters:
- `max_episodes` - Number of training episodes
- `max_steps_per_episode` - Steps per episode
- `plot_every` - Progress printing frequency
- `save_file` - Output file name

### `config.reward`
Reward function parameters:
- `Q_weights` - State penalty weights [position, velocity, angle, angular_vel]
- `R_weight` - Control effort weight
- `failure_penalty` - Early termination penalty

### `config.initial_state`
Initial state settings:
- `training` - Base initial state for training
- `training_noise` - Noise scale for training initialization
- `evaluation` - Initial state for evaluation/testing

### `config.visualization`
Visualization settings:
- `system` - Show cart-pole animation
- `states` - Show state trajectory plots
- `animation_size` - Animation window size (pixels)
- `states_width` / `states_height` - State plot window dimensions

### `config.controller`
Controller parameters (for comparison):
- `PD.gains` - PD controller gains [Kp, Kd_p, Ktheta, Kd_theta]
- `LQR.Q` - LQR state weighting matrix
- `LQR.R` - LQR control weighting scalar

### `config.main`
Main script settings:
- `use_controller` - Use controller (true) or policy (false)
- `random_seed` - Random seed for reproducibility

## Modifying Configuration

To modify any parameter, simply edit `+utils/get_config.m`. All changes will automatically propagate throughout the project.

## Examples

### Change DDPG learning rate:
```matlab
% In +utils/get_config.m, modify:
config.ddpg.actor_lr = 5e-4;  % Changed from 1e-4
```

### Change reward weights:
```matlab
% In +utils/get_config.m, modify:
config.reward.Q_weights = [2.0, 0.2, 20.0, 0.2];  % Increased penalties
```

### Switch to different integration method:
```matlab
% In +utils/get_config.m, modify:
config.simulation.integration_method = 'ode45';  % More accurate
```

## Backward Compatibility

The `get_sys_params()` function still works as before and now reads from the centralized config, ensuring backward compatibility with existing code.
