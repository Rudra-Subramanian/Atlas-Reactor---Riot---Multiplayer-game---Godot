# Atlas Reactor - Complete Documentation Index

## Quick Reference Guide

This documentation covers all Godot 4.6 GDScript files in the Atlas Reactor project.

---

## Documentation Structure

### 📚 Core Documentation Files

1. **[README.md](./README.md)** - Project overview and quick start
2. **[ActionClass.md](./ActionClass.md)** - Action system deep dive
3. **[Character_state_machine.md](./Character_state_machine.md)** - Character state and action management
4. **[CameraSystems.md](./CameraSystems.md)** - All camera implementations
5. **[MovementSystems.md](./MovementSystems.md)** - Movement and navigation
6. **[UISystems.md](./UISystems.md)** - Player UI controllers
7. **[NavigationSystem.md](./NavigationSystem.md)** - Navigation and pathfinding
8. **[CursorSystem.md](./CursorSystem.md)** - Cursor and targeting
9. **[TeamInitializer.md](./TeamInitializer.md)** - Level initialization

### 🎯 Templates

Located in `templates/` folder:

- **[action_template.gd](./templates/action_template.gd)** - Creating custom actions
- **[character_template.gd](./templates/character_template.gd)** - New character setup
- **[custom_camera_template.gd](./templates/custom_camera_template.gd)** - Custom cameras
- **[level_template.gd](./templates/level_template.gd)** - Level creation
- **[ability_template.gd](./templates/ability_template.gd)** - Ability system

---

## File Reference Table

| File | Type | Extends | Purpose | Documentation |
|------|------|---------|---------|---------------|
| `ActionClass.gd` | Class | - | Base action definition | [Link](./ActionClass.md) |
| `Character_state_machine.gd` | Script | Node | Character actions & states | [Link](./Character_state_machine.md) |
| `CameraMover.gd` | Class | Camera3D | Base camera controller | [Link](./CameraSystems.md#cameramover-base-class) |
| `team_1_camera.gd` | Script | CameraMover | Team camera with tracking | [Link](./CameraSystems.md#team1camera-extended-camera) |
| `freeview_cam_movement.gd` | Script | Camera3D | Free camera mode | [Link](./CameraSystems.md#freeviewcammovement) |
| `point_and_click_mover.gd` | Script | CharacterBody3D | Click-to-move system | [Link](./MovementSystems.md#point-and-click-mover) |
| `character_pathfollowmover.gd` | Script | CharacterBody3D | Path following movement | [Link](./MovementSystems.md#character-path-follow-mover) |
| `movement_decal.gd` | Script | MeshInstance3D | Movement visualization | [Link](./MovementSystems.md#movement-decal-visualization) |
| `player_ui.gd` | Script | Control | Main UI controller | [Link](./UISystems.md#player-ui-main-controller) |
| `character_ui_scene.gd` | Script | Control | Legacy UI controller | [Link](./UISystems.md#character-ui-scene-legacy) |
| `navigation_path_finder.gd` | Class | Node3D | Navigation helper | [Link](./NavigationSystem.md) |
| `cursor_placer.gd` | Script | Node3D | 3D cursor system | [Link](./CursorSystem.md) |
| `team_initializer.gd` | Script | Node | Level component setup | [Link](./TeamInitializer.md) |

---

## System Integration Map

```
┌─────────────────────────────────────────────────────────┐
│                    Level (Root Node)                     │
├─────────────────────────────────────────────────────────┤
│  TeamInitializer (Connects all systems)                  │
│    ├── Team1Camera (Camera tracking & movement)          │
│    │    └── CursorPlacer (Visual feedback)              │
│    ├── PlayerUI (Action selection & buttons)             │
│    ├── RegionDisplay (Movement visualization)            │
│    └── Characters (CharacterBody3D)                      │
│         └── CharacterStateMachine (Actions & states)     │
└─────────────────────────────────────────────────────────┘
```

---

## Common Workflows

### Adding a New Character

1. Read: [Character_state_machine.md](./Character_state_machine.md)
2. Use template: [character_template.gd](./templates/character_template.gd)
3. Configure actions in Character State Machine
4. Add to level scene

### Creating Custom Action

1. Read: [ActionClass.md](./ActionClass.md)
2. Use template: [action_template.gd](./templates/action_template.gd)
3. Add initialization in Character State Machine
4. Connect to UI button

### Setting Up Level

1. Read: [TeamInitializer.md](./TeamInitializer.md)
2. Use template: [level_template.gd](./templates/level_template.gd)
3. Add Camera, UI, Characters as children
4. Attach TeamInitializer script

### Implementing Ability

1. Read: [ActionClass.md](./ActionClass.md) & [UISystems.md](./UISystems.md)
2. Use template: [ability_template.gd](./templates/ability_template.gd)
3. Add to Character's Action_list
4. Handle in action execution logic

### Custom Camera Behavior

1. Read: [CameraSystems.md](./CameraSystems.md)
2. Use template: [custom_camera_template.gd](./templates/custom_camera_template.gd)
3. Extend CameraMover class
4. Override _process() for custom behavior

---

## Key Concepts

### Turn System

**4 Phases per Turn:**
1. **Prep** (Phase 1) - Setup actions
2. **Dash** (Phase 2) - Quick movements
3. **Attack** (Phase 3) - Abilities and attacks
4. **Movement** (Phase 4) - Standard movement

**Turn Flow:**
```
Player Planning
    ↓
UI: Select Character
    ↓
UI: Select Action
    ↓
UI: Choose Target/Destination
    ↓
Action stored in Character State Machine
    ↓
Repeat for all characters
    ↓
UI: Confirm Actions
    ↓
Execute all actions simultaneously in phase order
    ↓
Next Turn
```

### Action System

All actions use `ActionBasis` class:

```gdscript
var action = ActionBasis.new()
action.action_type = ActionType.MOVE
action._set_move_speed(8.0)
action._set_move_distance(10.0)
action._set_action_turn(4)
action.set_movement_zero(character.position)
```

### Navigation System

Uses Godot's NavigationServer3D:

```gdscript
# Query path
var path = query_path(start_pos, target_pos)

# Validate distance
var distance = get_length_of_path(path)
if distance <= max_distance:
    # Path is valid
```

### Camera Tracking

```gdscript
# Follow character
camera.track_character(character)

# Free mode
camera.stop_tracking()

# Move camera
camera.start_move_camera(Vector3(5, 0, 0))

# Rotate camera
camera.start_rotate_camera(45)  # degrees
```

### UI Signal Flow

```gdscript
# Character selection
Character_Pressed.emit(character)
    ↓
Camera tracks character
UI updates action bar
    ↓
# Action selection
ActionPressed.emit('Sprint', character)
    ↓
Cursor shows
Region display draws valid area
    ↓
# Player clicks destination
Character movement queued
    ↓
# Confirm turn
ConfirmPressed.emit()
    ↓
Execute all actions
```

---

## Godot 4.6 Features Used

### Navigation

- **NavigationServer3D** - Pathfinding queries
- **NavigationAgent3D** - Character path following
- **NavigationRegion3D** - Navigation mesh regions
- **NavigationPathQueryParameters3D** - Query configuration

### Physics

- **CharacterBody3D** - Character controllers
- **PhysicsRayQueryParameters3D** - Raycasting
- **ShapeCast3D** - Shape collision queries

### Rendering

- **ImmediateMesh** - Dynamic line drawing
- **MeshInstance3D** - 3D visualization
- **StandardMaterial3D** - Material properties
- **ORMMaterial3D** - ORM material workflow

### Nodes

- **Camera3D** - 3D camera
- **Control** - UI elements
- **AnimationPlayer** - Cursor animations
- **Timer** - Cooldown tracking

---

## Best Practices Summary

### Code Organization

✅ **Do:**
- Use `class_name` for reusable classes
- Group related exports with `@export_group`
- Document public functions
- Use type hints: `var name: Type`
- Use signals for loose coupling

❌ **Don't:**
- Hard-code node paths
- Use `get_node()` without validation
- Create circular dependencies
- Ignore null checks

### Performance

✅ **Do:**
- Reuse query objects (NavigationPathQueryParameters3D)
- Cache frequently accessed nodes with `@onready`
- Use `is_instance_valid()` before accessing nodes
- Limit per-frame raycasts

❌ **Don't:**
- Create new objects in `_process()`
- Query navigation every frame
- Use `find_node()` in hot paths

### Scene Structure

✅ **Do:**
- Use groups for character teams
- Name important nodes clearly
- Use export variables for connections
- Validate references in `_ready()`

❌ **Don't:**
- Rely on child indices
- Hard-code child relationships
- Skip null checks

---

## Troubleshooting

### Common Issues

**Problem:** Characters not detected by TeamInitializer  
**Solution:** Ensure characters are direct children and use `is_in_group()`

**Problem:** Navigation path returns empty  
**Solution:** Check NavigationMesh is baked and synced

**Problem:** UI buttons not responding  
**Solution:** Verify signal connections in `_ready()`

**Problem:** Camera not following character  
**Solution:** Call `initialize_camera()` before tracking

**Problem:** Movement range not showing  
**Solution:** Connect `region_display` to UI

---

## Additional Resources

### Godot Documentation

- [NavigationServer3D](https://docs.godotengine.org/en/stable/classes/class_navigationserver3d.html)
- [CharacterBody3D](https://docs.godotengine.org/en/stable/classes/class_characterbody3d.html)
- [Signals](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html)
- [Groups](https://docs.godotengine.org/en/stable/classes/class_node.html#class-node-method-add-to-group)

### Project Files

- Main scene: `res://scenes/main_level.tscn`
- Project settings: `res://project.godot`
- Action class: `res://ActionClass.gd`

---

## Version Information

- **Godot Version:** 4.6
- **Language:** GDScript only
- **Rendering:** GL Compatibility
- **Documentation Date:** April 2026

---

## Contact & Contributing

When modifying these systems:

1. Update relevant documentation file
2. Add examples to templates
3. Test integration with other systems
4. Update this index if adding new files

---

**Happy coding with Godot 4.6! 🎮**
