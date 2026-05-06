# Atlas Reactor - Godot 4.6 Project Documentation

## Project Overview

A turn-based tactical multiplayer game inspired by Atlas Reactor, built with **Godot 4.6** using GDScript. Features simultaneous turn resolution with 4 action phases per turn.

## Project Structure

```
topdown/
├── ActionClass.gd              # Core action system class
├── navigation_path_finder.gd   # Navigation helper for pathfinding
├── characters/
│   └── Character_state_machine.gd  # Character state and action management
├── scripts/
│   ├── CameraMover.gd              # Base camera movement class
│   ├── team_1_camera.gd            # Team-specific camera controller
│   ├── freeview_cam_movement.gd    # Free camera mode
│   ├── point_and_click_mover.gd    # Point-and-click movement system
│   ├── character_pathfollowmover.gd # Path-following movement
│   ├── movement_decal.gd           # Movement range visualization
│   └── character_ui_scene.gd       # Legacy UI manager
├── scenes/
│   ├── cursor_placer.gd            # Cursor/targeting system
│   └── uis/
│       └── player_ui.gd            # Main player UI controller
└── levels/
    └── test_levels/
        └── team_initializer.gd     # Level initialization system
```

## Core Systems

### 1. Action System
- **ActionClass.gd** - Defines all character actions with movement constraints
- **Character_state_machine.gd** - Manages character states and action execution

### 2. Movement Systems
- **point_and_click_mover.gd** - Click-to-move with navigation
- **character_pathfollowmover.gd** - Alternative path-following movement
- **movement_decal.gd** - Visual range indicators

### 3. Camera Systems
- **CameraMover.gd** - Base class with smooth transitions
- **team_1_camera.gd** - Team camera with tracking
- **freeview_cam_movement.gd** - Free-look camera mode

### 4. UI Systems
- **player_ui.gd** - Main UI controller
- **cursor_placer.gd** - Cursor and targeting visual feedback

### 5. Utilities
- **navigation_path_finder.gd** - Navigation queries
- **team_initializer.gd** - Level setup automation

## Game Flow

1. **Decision Phase**: Players select characters and actions
2. **Action Planning**: Click destinations, select abilities
3. **Confirmation**: Lock in all actions
4. **Execution**: All actions resolve simultaneously across 4 phases
5. **Turn End**: Reset for next turn

## Documentation Files

Each script has detailed documentation:

- [ActionClass Documentation](ActionClass.md)
- [Character State Machine Documentation](Character_state_machine.md)
- [Camera Systems Documentation](CameraSystems.md)
- [Movement Systems Documentation](MovementSystems.md)
- [UI Systems Documentation](UISystems.md)
- [Navigation System Documentation](NavigationSystem.md)
- [Initialization System Documentation](TeamInitializer.md)

## Getting Started

See the [Templates](./templates/) folder for example implementations of each system component.
