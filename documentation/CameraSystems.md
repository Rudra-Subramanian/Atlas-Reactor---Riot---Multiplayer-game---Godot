# Camera Systems Documentation

## Overview

The camera system uses a class hierarchy with smooth interpolation for movement and rotation.

---

## CameraMover (Base Class)

### File: `scripts/CameraMover.gd`

Base class providing smooth camera transitions.

```gdscript
class_name CameraMover
extends Camera3D
```

---

### Properties

#### Rotation Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `is_rotating` | `bool` | `false` | Whether camera is currently rotating |
| `rotation_progress` | `float` | `0.0` | Current rotation animation progress |
| `rotation_duration` | `float` | `15.0` | Frames to complete rotation |
| `target_rotation` | `float` | `0.0` | Target Y rotation in radians |
| `start_rotation` | `float` | `0.0` | Starting Y rotation in radians |

#### Movement Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `is_moving` | `bool` | `false` | Whether camera is currently moving |
| `move_progress` | `float` | `0.0` | Current movement animation progress |
| `move_duration` | `float` | `15.0` | Frames to complete movement |
| `start_position` | `Vector3` | - | Starting position |
| `target_position` | `Vector3` | - | Target position |
| `move_distance` | `float` | `5.0` | Default move distance for WASD input |

---

### Methods

#### `start_move_camera(move_vector: Vector3) -> void`
Initiates relative camera movement.

**Parameters:**
- `move_vector`: Direction and distance to move (relative to current position)

**Usage:**
```gdscript
camera.start_move_camera(Vector3(5, 0, 0))  # Move 5 units on X axis
```

---

#### `move_cam_to_position(move_vector: Vector3) -> void`
Initiates absolute camera movement.

**Parameters:**
- `move_vector`: Absolute world position to move to

**Usage:**
```gdscript
camera.move_cam_to_position(Vector3(10, 5, 10))
```

---

#### `move_camera() -> void`
Updates camera position each frame during movement animation.

**Process:**
1. Increments `move_progress`
2. Calculates interpolation factor with easing
3. Lerps between start and target positions
4. Stops when animation completes

**Called:** Automatically in `_process()` when `is_moving` is true

---

#### `start_rotate_camera(rotation_value: float) -> void`
Initiates camera rotation.

**Parameters:**
- `rotation_value`: Degrees to rotate (positive = clockwise)

**Usage:**
```gdscript
camera.start_rotate_camera(45)   # Rotate 45° clockwise
camera.start_rotate_camera(-90)  # Rotate 90° counter-clockwise
```

---

#### `rotate_camera() -> void`
Updates camera rotation each frame during rotation animation.

**Process:**
1. Increments `rotation_progress`
2. Calculates interpolation with easing
3. Lerps Y rotation
4. Snaps to target when complete

**Called:** Automatically in `_process()` when `is_rotating` is true

---

## Team1Camera (Extended Camera)

### File: `scripts/team_1_camera.gd`

Team-specific camera with character tracking and WASD movement.

```gdscript
extends CameraMover
```

---

### Additional Properties

| Property | Type | Description |
|----------|------|-------------|
| `player1` | `Node3D` | Reference to team player 1 |
| `player2` | `Node3D` | Reference to team player 2 |
| `player3` | `Node3D` | Reference to team player 3 |
| `player4` | `Node3D` | Reference to team player 4 |
| `player5` | `Node3D` | Reference to team player 5 |
| `tracking_character` | `Node3D` | Currently tracked character (null = free cam) |

---

### Methods

#### `_unhandled_input(event: InputEvent) -> void`
Handles keyboard input for camera control.

**Controls:**
- **Q**: Rotate 45° counter-clockwise
- **E**: Rotate 45° clockwise
- **W**: Move forward (when not tracking)
- **A**: Move left (when not tracking)
- **S**: Move backward (when not tracking)
- **D**: Move right (when not tracking)

**Movement Behavior:**
- Calculates direction relative to camera's current rotation
- Uses `move_distance` (default 5.0)
- Disabled when `tracking_character` is set

---

#### `assign_player(index: int, PlayerNode: Node3D) -> void`
Assigns a character to a player slot.

**Parameters:**
- `index`: Slot number (0-4)
- `PlayerNode`: Character to assign

**Usage:**
```gdscript
camera.assign_player(0, character1)  # player1 = character1
camera.assign_player(2, character3)  # player3 = character3
```

---

#### `track_character(character: Node3D) -> void`
Enables/disables character tracking.

**Parameters:**
- `character`: Character to track, or `null` to stop tracking

**Behavior:**
- Only tracks if character is in player list
- Sets `tracking_character`
- Disables WASD movement when tracking

**Usage:**
```gdscript
camera.track_character(player1)  # Follow player1
camera.track_character(null)     # Stop tracking
```

---

#### `stop_tracking() -> void`
Convenience method to stop tracking.

**Usage:**
```gdscript
camera.stop_tracking()
```

---

#### `_process(_delta: float) -> void`
Updates camera state each frame.

**Process:**
1. If rotating: calls `rotate_camera()`
2. If moving: calls `move_camera()`
3. If tracking character (and not moving):
   - Matches character's X and Z position
   - Maintains Y offset (+5 units above character)

---

## FreeviewCamMovement

### File: `scripts/freeview_cam_movement.gd`

Alternative free camera implementation (standalone, not using CameraMover base).

```gdscript
extends Camera3D
```

---

### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `astra` | `CharacterBody3D` | - | Reference to default character |
| `player1` | `CharacterBody3D` | `astra` | Tracked player |
| `tracking_character` | `bool` | `true` | Whether tracking is enabled |
| `no_input` | `bool` | `false` | Disables all input when true |

**Also has rotation/movement properties matching CameraMover**

---

### Methods

#### `start_tracking_character() -> void`
Smoothly moves camera to character's position and toggles tracking.

**Process:**
1. Preserves current Y height
2. Moves to character's XZ position
3. Toggles `tracking_character` state

**Usage:**
```gdscript
freeview_cam.start_tracking_character()
```

---

### Differences from Team1Camera

1. **Standalone:** Doesn't extend CameraMover
2. **Duplicated logic:** Has its own rotation/movement implementation
3. **Toggle tracking:** `start_tracking_character()` toggles rather than sets
4. **Single player:** Only tracks `player1`

---

## Usage Examples

### Basic Camera Setup

```gdscript
# In scene setup
var camera = Team1Camera.new()
add_child(camera)
camera.assign_player(0, character1)
camera.assign_player(1, character2)
```

---

### Tracking Character

```gdscript
# When player selects character
func _on_character_selected(character):
    camera.track_character(character)
```

---

### Free Camera Mode

```gdscript
# When player clicks "Free Cam" button
func _on_free_cam_pressed():
    camera.stop_tracking()
    # Player can now use WASD to move camera
```

---

### Smooth Camera Transition

```gdscript
# Move camera to specific position
camera.move_cam_to_position(Vector3(20, 10, 15))

# Rotate to face different direction
camera.start_rotate_camera(90)
```

---

## Camera Animation Tweaking

### Adjust Speed

```gdscript
# Faster rotation (fewer frames)
camera.rotation_duration = 8.0  # Completes in 8 frames instead of 15

# Slower movement
camera.move_duration = 30.0  # Takes 30 frames
```

---

### Adjust Easing

The `ease()` function uses `-2.0` for cubic ease-in-out:

```gdscript
var t = ease(progress, -2.0)  # Smooth acceleration/deceleration
```

Change easing curve:
- `-2.0`: Cubic (smooth)
- `-1.0`: Quadratic (less smooth)
- `1.0`: Linear (no easing)

---

## Integration with UI

```gdscript
# player_ui.gd
func initialize_camera(camera_to_connect: Camera3D):
    camera_3d = camera_to_connect
    FreeCamStart.connect(camera_3d.stop_tracking)
    Character_Pressed.connect(camera_3d.track_character)
```

---

## Best Practices

1. **Use Team1Camera** for gameplay (better structure)
2. **Extend CameraMover** for custom camera behaviors
3. **Check is_moving/is_rotating** before starting new animations
4. **Adjust durations** based on desired feel
5. **Maintain Y offset** when tracking to keep good view angle

---

## Related Files

- `player_ui.gd` - Connects UI signals to camera
- `team_initializer.gd` - Sets up camera references
- `cursor_placer.gd` - Uses camera for raycasting
