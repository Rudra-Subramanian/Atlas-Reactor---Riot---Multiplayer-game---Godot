# Movement Systems Documentation

## Overview

Two main movement implementations + visualization system.

---

## Point and Click Mover

### File: `scripts/point_and_click_mover.gd`

Click-based movement with NavigationAgent3D.

```gdscript
extends CharacterBody3D
```

---

### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `camera_3d` | `Camera3D` | - | Reference to active camera for raycasting |
| `navigation_agent_3d` | `NavigationAgent3D` | - | Navigation agent component |
| `max_length` | `int` | `20` | Maximum allowed path length |
| `is_moving` | `bool` | `false` | Whether character is currently moving |
| `click_type` | `String` | `'Movement'` | Controls if clicking is enabled |

---

### Signals

```gdscript
signal movement_finished(name: String, bool_value: bool)
```

**Emitted:** When movement completes
**Parameters:**
- `name`: Character's name
- `bool_value`: True if movement finished

---

### Navigation Query System

#### Properties

```gdscript
var query_parameters := NavigationPathQueryParameters3D.new()
var query_result := NavigationPathQueryResult3D.new()
```

---

#### `query_path(p_start_position: Vector3, p_target_position: Vector3, p_navigation_layers: int = 1) -> PackedVector3Array`

Queries the NavigationServer for a path between two points.

**Parameters:**
- `p_start_position`: Path start point
- `p_target_position`: Path end point  
- `p_navigation_layers`: Navigation layer mask (default: 1)

**Returns:**
- `PackedVector3Array`: Array of waypoints, or empty if invalid

**Usage:**
```gdscript
var path = character.query_path(character.position, target_position)
print("Path has ", path.size(), " waypoints")
```

---

### Input Handling

#### `_unhandled_input(event: InputEvent) -> void`

Handles left-click to set movement destination.

**Process:**
1. Checks if `click_type == 'Movement'` and not currently moving
2. Raycasts from camera through mouse position
3. If hits geometry, calls `move_navigation_to_target()`

**Raycast Algorithm:**
```gdscript
var from = camera_3d.project_ray_origin(mouse_pos)
var to = from + camera_3d.project_ray_normal(mouse_pos) * 1000
var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))
```

---

### Movement Functions

#### `StartMovement() -> void`
Enables movement if not already moving.

**Usage:**
```gdscript
character.StartMovement()
```

---

#### `get_world_pos_from_camera_view(event: InputEvent) -> Vector3`
Converts mouse click to 3D world position.

**Parameters:**
- `event`: Input event containing mouse position

**Returns:**
- `Vector3`: World position of raycast hit

---

#### `move_navigation_to_target(target_position: Vector3) -> void`
Sets navigation target with distance validation.

**Parameters:**
- `target_position`: Desired destination

**Process:**
1. Stores old target position
2. Sets new target on NavigationAgent
3. Calculates path length
4. If exceeds `max_length`:
   - Reverts to old target
   - Double-checks length
   - If still invalid, sets target to current position

**Usage:**
```gdscript
character.move_navigation_to_target(Vector3(10, 0, 5))
```

---

#### `_process(_delta: float) -> void`
Moves character along navigation path each frame.

**Process:**
1. Gets next path position from NavigationAgent
2. Calculates direction vector
3. Sets velocity (speed: 5 units/sec)
4. If `is_moving`: calls `move_and_slide()`
5. Updates movement state based on target reached

---

#### `set_is_moving(value: bool) -> void`
Updates movement state and emits signal if changed.

**Parameters:**
- `value`: New movement state

**Behavior:**
- Emits `movement_finished` signal when state changes
- Signal includes character name and completion status

---

#### `handle_ended_movement(name: String, bool_value: bool) -> void`
Signal handler for movement completion.

**Parameters:**
- `name`: Character name
- `bool_value`: True if movement ended

**Behavior:**
- If movement ended, resets navigation target to current position

**Connected in `_ready()`:**
```gdscript
movement_finished.connect(handle_ended_movement)
```

---

### Utility

#### `is_position_within_distance(target_pos: Vector3, distance: float) -> bool`
Checks if position is within range.

**Parameters:**
- `target_pos`: Position to check
- `distance`: Maximum allowed distance

**Returns:**
- `bool`: True if within range

---

## Character Path Follow Mover

### File: `scripts/character_pathfollowmover.gd`

Alternative movement system (similar to point_and_click but with different speeds).

```gdscript
extends CharacterBody3D
```

---

### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `movement_path` | `Array[Vector3]` | `[]` | Planned movement waypoints |
| `walking_speed` | `float` | `5` | Walk speed |
| `peeking_speed` | `float` | `1` | Peek speed |
| `running_speed` | `float` | `8` | Run speed |
| `current_movement_speed` | `float` | `10.0` | Active speed |
| `Health` | `float` | `100` | Character health |
| `TurnActions` | `Array` | `[]` | Queued turn actions |

---

### Enumerations

```gdscript
enum CharacterState {
    WAIT,
    WALK,
    RUN,
    PEEK,
    ABILITY1,
    ABILITY2,
    ABILITY3,
    ABILITY4,
    DONE
}
```

---

### Signals

```gdscript
signal movement_finished(name: String, bool_value: bool)
```

---

### Key Differences from Point-and-Click

1. **Multiple speeds:** Separate properties for walk/run/peek
2. **Turn actions:** Has `TurnActions` array for turn-based system
3. **Character states:** Full state enum for different actions

---

## Movement Decal (Visualization)

### File: `scripts/movement_decal.gd`

Visualizes movement range and valid positions.

```gdscript
extends MeshInstance3D
```

---

### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `shape_cast_3d` | `ShapeCast3D` | - | Shape casting node |
| `material` | `StandardMaterial3D` | - | Material for visualization |
| `radius` | `float` | `20.0` | Default visualization radius |
| `ray_count` | `int` | `100` | Number of rays to cast |
| `start_height` | `float` | `10.0` | Height to start raycasts |
| `cast_distance` | `float` | `20.0` | Raycast length downward |
| `circles` | `Array` | `[]` | Debug sphere meshes |
| `lines` | `Array` | - | Line visualization meshes |

---

### Core Functions

#### `display_region(center_position, circle_radius, show_circles = false) -> void`

Creates mesh showing valid movement area.

**Parameters:**
- `center_position`: Center of movement range
- `circle_radius`: Maximum movement distance
- `show_circles`: Whether to show debug spheres

**Process:**
1. Removes previous region
2. Gets boundary points via raycasting
3. Draws mesh connecting points

**Usage:**
```gdscript
region_display.display_region(character.position, 10.0, false)
```

---

#### `remove_region() -> void`
Clears all visualization meshes and debug spheres.

---

#### `get_bounding_pointsfunc(center_position, circle_radius, draw_spheres) -> Array[Vector3]`

Casts rays in circle to find valid ground positions.

**Process:**
1. Calculates `ray_count` positions in circle around center
2. For each position:
   - Raycasts downward from `start_height`
   - Validates path length vs max distance
   - Adds position if valid

**Returns:**
- `Array[Vector3]`: Valid boundary positions

---

#### `check_if_point_is_valid(i, angle_step, space_state, distance_from_center, center_position, draw_spheres, maximum_path_length) -> Dictionary`

Recursively validates a single point on the circle.

**Process:**
1. Calculates X/Z position at distance from center
2. Raycasts downward
3. If hit:
   - Queries navigation path
   - Checks if path length ≤ maximum
   - If too long, retries with smaller radius (recursive)
4. If no hit, retries with smaller radius

**Returns:**
- `Dictionary`: Raycast result with position, or null

**Recursion:**
Reduces `distance_from_center` by 0.2 each iteration until valid or < 0.2

---

### Mesh Drawing

#### `draw_line(point_array: Array, persist_ms: float) -> MeshInstance3D`

Draws a line strip through waypoints.

**Parameters:**
- `point_array`: Array of Vector3 positions
- `persist_ms`: Display duration (1=one frame, >1=seconds, <1=indefinite)

**Process:**
1. Creates ImmediateMesh
2. Adds vertices as LINE_STRIP
3. Applies pink unshaded material
4. Manages cleanup via `final_cleanup()`

---

#### `draw_better_mesh(hit_points: Array, center_pos: Vector3) -> void`

Creates filled mesh from boundary points.

**Algorithm:**
1. Adds center point to vertex array
2. Adds all boundary points
3. Creates triangle fan:
   - Each triangle: center → point[i] → point[i+1]
   - Last triangle wraps to first point
4. Applies blue semi-transparent material

**Material:**
- Color: Blue (0, 0, 1, 0.6)
- Unshaded
- Alpha transparency

---

#### `remove_lines() -> void`
Removes all line visualizations.

---

### Navigation Integration

Uses same navigation query system as movement:

```gdscript
var path = query_path(center_position, result.position)
var length = get_length_of_path(path, result.position)
```

---

#### `get_length_of_path(path: PackedVector3Array, final_position) -> float`

Calculates total navigation path distance.

**Parameters:**
- `path`: Navigation waypoints
- `final_position`: Final destination

**Returns:**
- `float`: Total path distance

---

## Usage Examples

### Basic Movement Setup

```gdscript
# Attach to CharacterBody3D
var character = CharacterBody3D.new()
var mover_script = preload("res://scripts/point_and_click_mover.gd")
character.set_script(mover_script)
```

---

### Movement with Visualization

```gdscript
# When action button pressed
var action = character.get_child(1).Action_list['Sprint']
var radius = action.get_distance_left()
var center = action.get_last_point()

# Show valid movement area
region_display.display_region(center, radius, false)

# When player clicks destination
character.move_navigation_to_target(clicked_position)
```

---

### Connect Movement Signals

```gdscript
# In UI or game manager
character.movement_finished.connect(_on_character_movement_finished)

func _on_character_movement_finished(char_name: String, finished: bool):
    if finished:
        print(char_name, " reached destination")
        # Proceed to next turn phase
```

---

## Best Practices

1. **Set max_length** based on action distances
2. **Always validate paths** before committing movement
3. **Use region display** to show valid areas
4. **Connect movement_finished** to track turn completion
5. **Reset navigation target** when movement cancels
6. **Check is_moving** before accepting new input

---

## Related Files

- `ActionClass.gd` - Defines movement constraints
- `Character_state_machine.gd` - Stores action data
- `player_ui.gd` - Triggers movement actions
- `navigation_path_finder.gd` - Additional path utilities
