# Cursor and Targeting System Documentation

## File: `scenes/cursor_placer.gd`

### Purpose
Manages the 3D cursor that follows the mouse and provides visual feedback for actions.

---

## Node Type

```gdscript
extends Node3D
```

**Scene Structure:**
```
Camera3D
└── cursor_placer (Node3D)
    └── AnimationPlayer
```

---

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `ShowCursor` | `bool` | `false` | Whether cursor is visible and active |
| `camera_3d` | `Camera3D` | - | Parent camera (auto-referenced) |
| `animation_player` | `AnimationPlayer` | - | Controls cursor animations |

---

## Methods

### Action Handling

#### `on_action_pressed(action_string: String, character: Node3D) -> void`

Signal handler for when player selects an action.

**Parameters:**
- `action_string`: Name of selected action ('Sprint', 'Ability1', etc.)
- `character`: Character performing the action

**Behavior:**
```gdscript
if action_string == 'Sprint':
    update_show(true)   # Show cursor for movement
elif action_string == 'None':
    update_show(false)  # Hide cursor
elif 'Ability' in action_string:
    update_show(false)  # Hide for abilities (use different visual)
```

**Connected In:** player_ui.gd
```gdscript
ActionPressed.connect(cursor.on_action_pressed)
```

---

### Physics Update

#### `_physics_process(delta: float) -> void`

Updates cursor position every physics frame when visible.

**Process:**
1. Only runs if `ShowCursor == true`
2. Gets mouse position in viewport
3. Raycasts from camera through mouse position
4. If hits geometry, moves cursor to intersection point

**Raycast Details:**
```gdscript
var mouse_position = get_viewport().get_mouse_position()
var from = camera_3d.project_ray_origin(mouse_position)
var to = from + camera_3d.project_ray_normal(mouse_position) * 1000
var space_state = camera_3d.get_world_3d().direct_space_state
var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))

if len(result) > 0:
    global_position = result.position
```

**Performance:** Runs every physics frame (~60 FPS)

---

### Visibility Control

#### `update_show(boolvalue: bool) -> void`

Controls cursor visibility and mouse mode.

**Parameters:**
- `boolvalue`: True to show cursor, false to hide

**Process:**
1. Sets `ShowCursor`
2. Sets `visible` property
3. If showing:
   - Hides OS mouse cursor (`Input.MOUSE_MODE_HIDDEN`)
   - Plays hover animation
4. If hiding:
   - Shows OS mouse cursor (`Input.MOUSE_MODE_VISIBLE`)
   - Stops all animations

**Usage:**
```gdscript
cursor.update_show(true)   # Show 3D cursor, hide OS cursor
cursor.update_show(false)  # Hide 3D cursor, show OS cursor
```

---

### Animation Control

#### `spin_cursor() -> void`

**Status:** Defined but not currently used.

**Purpose:** Play spinning animation.

```gdscript
func spin_cursor():
    animation_player.play("Cone|spin")
```

---

#### `play_hover_animation() -> void`

Plays floating/hovering animation.

```gdscript
func play_hover_animation():
    animation_player.play("Cone|float")
```

**Called:** Automatically when cursor becomes visible

---

#### `stop_animations() -> void`

Stops all cursor animations.

```gdscript
func stop_animations():
    animation_player.current_animation = "[stop]"
```

**Called:** Automatically when cursor is hidden

---

## Animation Setup

The cursor model should have these animations:

### Required Animations

#### `Cone|float`
- **Type:** Looping
- **Description:** Gentle up/down bobbing motion
- **Use:** Default when cursor is visible

**Example:**
```
Frame 0: Y = 0.0
Frame 30: Y = 0.2
Frame 60: Y = 0.0
```

---

#### `Cone|spin` (Optional)
- **Type:** Looping
- **Description:** Rotation around Y axis
- **Use:** Could indicate targeting/charging

**Example:**
```
Frame 0: Rotation Y = 0°
Frame 60: Rotation Y = 360°
```

---

## Usage Examples

### Basic Setup

```gdscript
# Scene structure
Camera3D
├── cursor_placer.gd (this script)
│   └── ConeMesh (visual model)
│   └── AnimationPlayer

# In player_ui.gd initialization
func initialize_camera(camera_to_connect: Camera3D):
    camera_3d = camera_to_connect
    var cursor = camera_3d.get_child(0)
    ActionPressed.connect(cursor.on_action_pressed)
```

---

### Action Flow

```gdscript
# User clicks Sprint button
player_ui.action_button_pressed('Sprint')
    ↓
ActionPressed.emit('Sprint', character)
    ↓
cursor.on_action_pressed('Sprint', character)
    ↓
cursor.update_show(true)
    ↓
# Cursor now follows mouse, hovering animation plays
# OS cursor hidden
```

---

### Canceling Action

```gdscript
# User clicks Cancel button
player_ui._cancel_pressed()
    ↓
ActionPressed.emit('None', character)
    ↓
cursor.on_action_pressed('None', character)
    ↓
cursor.update_show(false)
    ↓
# Cursor hidden, OS cursor visible
```

---

## Cursor Model Requirements

### Visual Model

The cursor should be a 3D mesh (typically cone or arrow):

```gdscript
# Example cursor mesh setup
ConeMesh (or imported model)
├── Height: 1.0
├── Radius: 0.5
└── Material: 
    ├── Emission: Enabled
    ├── Emission Color: Bright color (e.g., cyan)
    └── Transparency: Optional (0.8 alpha)
```

---

### Recommended Properties

| Property | Value | Reason |
|----------|-------|--------|
| Cast Shadow | Off | Cursor shouldn't cast shadows |
| Emission | On | Visible in all lighting |
| Emission Energy | 2-5 | Bright enough to see clearly |
| Transparency | 0.7-0.9 | See terrain through it |
| Layers | Separate layer | Avoid being occluded |

---

## Advanced Usage

### Different Cursors for Different Actions

```gdscript
func on_action_pressed(action_string: String, character: Node3D):
    if action_string == 'Sprint':
        update_show(true)
        cursor_mesh.material.emission = Color.CYAN
    elif action_string == 'Sneak':
        update_show(true)
        cursor_mesh.material.emission = Color.DARK_GREEN
    elif 'Ability' in action_string:
        update_show(true)
        spin_cursor()  # Different animation for abilities
    elif action_string == 'None':
        update_show(false)
```

---

### Ground Offset

Keep cursor slightly above ground to avoid z-fighting:

```gdscript
# In _physics_process
if len(result) > 0:
    global_position = result.position + Vector3(0, 0.1, 0)  # 0.1 unit above ground
```

---

### Collision Layers

Ensure cursor raycasts only hit navigation surfaces:

```gdscript
# Create query with specific collision mask
var query = PhysicsRayQueryParameters3D.create(from, to)
query.collision_mask = 1  # Only layer 1 (ground)
var result = space_state.intersect_ray(query)
```

---

## Integration Points

### With Player UI

```gdscript
# player_ui.gd connects signal
func initialize_camera(camera_to_connect: Camera3D):
    camera_3d = camera_to_connect
    var cursor = camera_3d.get_children()[0]
    ActionPressed.connect(cursor.on_action_pressed)
```

---

### With Camera Movement

Cursor follows mouse regardless of camera rotation:
- Ray always projects from camera's current orientation
- Cursor position updates as camera rotates
- Smooth tracking even during camera transitions

---

## Performance Optimization

### Conditional Updates

Only raycast when cursor is visible:

```gdscript
func _physics_process(delta: float) -> void:
    if not ShowCursor:
        return  # Skip raycast entirely
    
    # Raycast code here
```

---

### Raycast Length

Limit raycast distance to avoid unnecessary calculations:

```gdscript
# Instead of 1000 units
var to = from + camera_3d.project_ray_normal(mouse_position) * 100
# Sufficient for most game levels
```

---

## Debugging

### Visualize Raycast

```gdscript
func _physics_process(delta: float) -> void:
    if ShowCursor:
        var mouse_position = get_viewport().get_mouse_position()
        var from = camera_3d.project_ray_origin(mouse_position)
        var to = from + camera_3d.project_ray_normal(mouse_position) * 1000
        
        # Debug draw
        var debug_line = ImmediateMesh.new()
        # ... draw line from 'from' to 'to'
        
        var result = space_state.intersect_ray(...)
        if len(result) > 0:
            print("Hit at: ", result.position)
            global_position = result.position
        else:
            print("No hit")
```

---

### Check Cursor State

```gdscript
# Add to _process for debugging
func _process(delta):
    if Input.is_action_just_pressed("ui_cancel"):
        print("ShowCursor: ", ShowCursor)
        print("Visible: ", visible)
        print("Position: ", global_position)
        print("Animation: ", animation_player.current_animation)
```

---

## Best Practices

1. **Keep cursor simple:** Low-poly mesh for performance
2. **Use emission:** Makes cursor visible in all lighting
3. **Offset from ground:** Prevents z-fighting
4. **Hide when not needed:** Reduces unnecessary raycasts
5. **Match action types:** Different visuals for different actions
6. **Smooth animations:** Short, looping animations feel better
7. **Consider colorblind users:** Use shape + color to indicate different modes

---

## Extension Ideas

### Multiple Cursor Shapes

```gdscript
@onready var move_cursor = $MoveCursor
@onready var attack_cursor = $AttackCursor

func on_action_pressed(action_string: String, character: Node3D):
    if action_string in ['Sprint', 'Walk', 'Sneak']:
        show_cursor(move_cursor)
    elif action_string in ['Ability1', 'Ability2']:
        show_cursor(attack_cursor)
    else:
        hide_all_cursors()
```

---

### Range Indicator

```gdscript
# Add range indicator to cursor
@onready var range_indicator = $RangeCircle

func on_action_pressed(action_string: String, character: Node3D):
    if action_string == 'Ability1':
        range_indicator.scale = Vector3(3, 1, 3)  # 3 unit radius
        update_show(true)
```

---

### Validation Feedback

```gdscript
func _physics_process(delta: float) -> void:
    if ShowCursor:
        # ... raycast code ...
        
        if is_valid_target_position(result.position):
            cursor_mesh.material.emission = Color.GREEN
        else:
            cursor_mesh.material.emission = Color.RED
```

---

## Related Files

- `player_ui.gd` - Triggers cursor visibility via ActionPressed signal
- `team_1_camera.gd` - Provides camera reference for raycasting
- `point_and_click_mover.gd` - Uses similar raycast for click detection
- `movement_decal.gd` - Visualizes valid movement area
