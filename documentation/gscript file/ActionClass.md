# ActionClass Documentation

## File: `ActionClass.gd`

### Purpose
Defines the base class for all character actions in the game. Handles movement constraints, turn phases, and path validation.

---

## Class Definition

```gdscript
class_name ActionBasis
```

---

## Enumerations

### `ActionType`
Defines the category of action being performed.

```gdscript
enum ActionType {
    SHOOT,   # Ranged weapon attack
    THROW,   # Thrown weapon/item
    USE,     # Use item or interact
    CAST,    # Cast ability/spell
    MOVE     # Movement action
}
```

---

## Properties

### Core Properties

| Property | Type | Description |
|----------|------|-------------|
| `move_speed` | `float` | Speed at which the character moves during action execution |
| `move_distance` | `float` | Maximum distance this action allows the character to travel |
| `action_turn` | `int` | Which phase this action executes in (1-4): 1=Prep, 2=Dash, 3=Attack, 4=Movement |
| `movement_points` | `Array[Vector3]` | Ordered array of waypoints defining the movement path |
| `action_type` | `ActionType` | The category of action (from ActionType enum) |

---

## Methods

### Setters

#### `_set_move_speed(speed: float) -> void`
Sets the movement speed for this action.

**Parameters:**
- `speed`: Speed value in units per second

**Usage:**
```gdscript
var action = ActionBasis.new()
action._set_move_speed(8.0)
```

---

#### `_set_move_distance(distance: float) -> void`
Sets the maximum allowed movement distance for this action.

**Parameters:**
- `distance`: Maximum distance in world units

**Usage:**
```gdscript
action._set_move_distance(10.0)
```

---

#### `_set_action_turn(turn: int) -> void`
Sets which turn phase this action executes in.

**Parameters:**
- `turn`: Phase number (1=Prep, 2=Dash, 3=Attack, 4=Movement)

**Usage:**
```gdscript
action._set_action_turn(4)  # Execute in Movement phase
```

---

### Movement Management

#### `set_movement_zero(position: Vector3) -> void`
Resets the movement path to a single starting position.

**Parameters:**
- `position`: The starting position for the movement path

**Usage:**
```gdscript
action.set_movement_zero(character.global_position)
```

---

#### `add_movement_point(position: Vector3) -> void`
Adds a waypoint to the movement path. Validates that the new point doesn't exceed `move_distance`.

**Parameters:**
- `position`: The new waypoint to add

**Behavior:**
- Calculates total path distance with new point
- If exceeds `move_distance`, reverts and prints error
- If valid, appends point to `movement_points`

**Usage:**
```gdscript
action.add_movement_point(Vector3(10, 0, 5))
# If point is too far: prints "point too far"
```

---

#### `get_movement_path() -> Array`
Returns the complete movement path.

**Returns:**
- `Array`: The `movement_points` array

**Usage:**
```gdscript
var path = action.get_movement_path()
for point in path:
    print(point)
```

---

#### `get_last_point() -> Vector3`
Returns the final waypoint in the movement path.

**Returns:**
- `Vector3`: The last position in `movement_points`

**Usage:**
```gdscript
var destination = action.get_last_point()
```

---

### Distance Calculations

#### `get_current_distance() -> float`
Calculates the total distance traveled along the movement path.

**Returns:**
- `float`: Sum of distances between all consecutive waypoints

**Algorithm:**
1. Iterates through all movement points
2. Calculates distance between each consecutive pair
3. Sums all distances

**Usage:**
```gdscript
var traveled = action.get_current_distance()
print("Total distance: ", traveled)
```

---

#### `get_distance_left() -> float`
Calculates remaining movement distance available.

**Returns:**
- `float`: `move_distance - get_current_distance()`

**Usage:**
```gdscript
var remaining = action.get_distance_left()
if remaining > 5.0:
    # Can move further
```

---

## Usage Example

```gdscript
# Create a sprint action
var sprint_action = ActionBasis.new()
sprint_action.action_type = ActionBasis.ActionType.MOVE
sprint_action._set_move_speed(8.0)
sprint_action._set_move_distance(10.0)
sprint_action._set_action_turn(4)

# Initialize with character position
sprint_action.set_movement_zero(character.global_position)

# Add waypoints
sprint_action.add_movement_point(Vector3(5, 0, 0))
sprint_action.add_movement_point(Vector3(8, 0, 3))

# Check remaining distance
if sprint_action.get_distance_left() > 0:
    print("Can move further!")
```

---

## Integration with Character System

Actions are stored in the Character State Machine's `Action_list` dictionary:

```gdscript
Action_list = {
    'Sprint': ActionBasis,
    'Walk': ActionBasis,
    'Sneak': ActionBasis,
    # ... etc
}
```

Each action is initialized with specific parameters for that action type.

---

## Best Practices

1. **Always initialize with `set_movement_zero()`** before adding waypoints
2. **Check `get_distance_left()`** before allowing new waypoints
3. **Validate paths** using navigation system before finalizing
4. **Set action_turn appropriately** based on game phase system
5. **Use correct ActionType** to enable proper execution logic

---

## Related Files

- `Character_state_machine.gd` - Uses ActionBasis to manage character actions
- `player_ui.gd` - Displays and triggers actions based on ActionBasis properties
- `movement_decal.gd` - Visualizes action movement range using `get_distance_left()`
