# Code Templates for Atlas Reactor Systems

This folder contains ready-to-use templates for implementing common features in the Atlas Reactor project.

## Available Templates

### Core Systems
- [action_template.gd](./action_template.gd) - Creating custom actions
- [character_template.gd](./character_template.gd) - Setting up new characters
- [ability_template.gd](./ability_template.gd) - Implementing abilities

### Camera Systems
- [custom_camera_template.gd](./custom_camera_template.gd) - Extending CameraMover
- [camera_behavior_template.gd](./camera_behavior_template.gd) - Custom camera behaviors

### Movement Systems
- [custom_movement_template.gd](./custom_movement_template.gd) - Alternative movement implementations
- [movement_validation_template.gd](./movement_validation_template.gd) - Custom movement constraints

### UI Systems
- [action_button_template.gd](./action_button_template.gd) - Adding new action buttons
- [character_selection_template.gd](./character_selection_template.gd) - Custom selection logic

### Level Setup
- [level_template.gd](./level_template.gd) - Creating new levels
- [team_setup_template.gd](./team_setup_template.gd) - Team configuration

## Usage

1. Copy the relevant template file
2. Rename to your specific use case
3. Fill in the TODO sections
4. Attach to appropriate node in your scene
5. Configure exported properties in editor

## Quick Start Example

```gdscript
# Creating a new ability action:

# 1. Copy ability_template.gd
# 2. Rename to teleport_ability.gd
# 3. Fill in the specifics:

extends ActionBasis

func initialize():
    action_type = ActionType.CAST
    _set_move_speed(0)
    _set_move_distance(15)  # 15 unit teleport range
    _set_action_turn(3)     # Execute in Attack phase
```
