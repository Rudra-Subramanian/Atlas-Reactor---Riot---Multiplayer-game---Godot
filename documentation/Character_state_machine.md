# Character State Machine Documentation

## File: `characters/Character_state_machine.gd`

### Purpose
Manages character states, actions, and turn-based action execution. Each character has one attached as a child node.

---

## Node Type

```gdscript
extends Node
```

**Attachment:** Child of CharacterBody3D representing a character

---

## Properties

### Movement Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `movement_path` | `Array[Vector3]` | `[]` | Current planned movement path |
| `walking_speed` | `float` | `5` | Walking movement speed |
| `peeking_speed` | `float` | `5` | Peeking movement speed |
| `sprinting_speed` | `float` | `8` | Sprinting movement speed |
| `sneaking_speed` | `float` | `3` | Sneaking movement speed |
| `current_movement_speed` | `float` | `10.0` | Active movement speed |

### Character Stats

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `Health` | `float` | `100` | Current health points |

### Turn Management

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `TurnActions` | `Dictionary` | `{1:[], 2:[], 3:[], 4:[]}` | Actions queued for each phase |
| `Action_list` | `Dictionary` | (See below) | All available actions for this character |
| `Current_Action` | `String` | `''` | Currently selected action name |

**Action_list Structure:**
```gdscript
{
    'Sprint': ActionBasis or null,
    'Walk': ActionBasis or null,
    'Sneak': ActionBasis or null,
    'Peek': ActionBasis or null,
    'Hold': ActionBasis or null,
    'Ability1': ActionBasis or null,
    'Ability2': ActionBasis or null,
    'Ability3': ActionBasis or null,
    'Ability4': ActionBasis or null
}
```

---

## Enumerations

### `CharacterState`

```gdscript
enum CharacterState {
    WAIT,      # Waiting for input
    WALK,      # Walking movement
    RUN,       # Running movement
    SPRINT,    # Sprinting movement
    PEEK,      # Peeking around cover
    HOLD,      # Holding position
    ABILITY1,  # Using ability 1
    ABILITY2,  # Using ability 2
    ABILITY3,  # Using ability 3
    ABILITY4,  # Using ability 4
    DONE       # Completed turn actions
}
```

**Current State:**
```gdscript
@onready var CurrentState = CharacterState.WAIT
```

---

## Methods

### Lifecycle

#### `_ready() -> void`
Initializes all actions when character is added to scene.

**Process:**
1. Calls `initialize_actions()`
2. Populates `Action_list` with all available actions

---

### Navigation

#### `get_path_to_movement_position(position_from, position_to) -> Array`
**Status:** Stub implementation - returns empty array

**Purpose:** Intended to query navigation path between two positions

**Returns:**
- `Array`: Currently returns `[]`, should return path waypoints

---

### Action Validation

#### `check_if_valid_movement_position(action: String, end_position) -> bool`
Validates if a movement destination is reachable within action constraints.

**Parameters:**
- `action`: Name of the action being performed
- `end_position`: Target destination position

**Process:**
1. Gets path from current position to destination
2. Calculates total path distance
3. Compares against action's remaining distance
4. Prints "Valid movement" if acceptable

**Returns:**
- `bool`: Currently always returns `true` (needs implementation)

**Usage:**
```gdscript
if character_state.check_if_valid_movement_position("Sprint", target_pos):
    # Execute movement
```

---

### Turn Management

#### `SetTurnAction(turn: int, action: ActionBasis) -> void`
Assigns an action to a specific turn phase.

**Parameters:**
- `turn`: Phase number (1-4)
- `action`: The ActionBasis instance to execute

**Usage:**
```gdscript
var sprint = Action_list['Sprint']
SetTurnAction(4, sprint)  # Execute sprint in Movement phase
```

---

### Action Initialization

#### `initialize_actions() -> void`
Dynamically initializes all actions using reflection.

**Process:**
1. Iterates through `Action_list` keys
2. For each action, constructs function name: `"initialize_" + action_name`
3. Uses `Expression.parse()` to dynamically call initialization function
4. Populates `Action_list` with initialized ActionBasis instances

**Usage:**
Called automatically in `_ready()`, but can be called to reset actions:
```gdscript
character_state.initialize_actions()
```

---

### Individual Action Initializers

Each action has a dedicated initialization function:

#### `initialize_Sprint() -> void`
Creates the Sprint action.

**Configuration:**
- Type: `MOVE`
- Speed: `8`
- Distance: `10`
- Phase: `4` (Movement)

**Code:**
```gdscript
var sprint_action = ActionBasis.new()
sprint_action.action_type = ActionBasis.ActionType.MOVE
sprint_action._set_move_speed(8)
sprint_action._set_move_distance(10)
sprint_action._set_action_turn(4)
sprint_action.add_movement_point(get_parent().global_position)
Action_list['Sprint'] = sprint_action
```

---

#### `initialize_Walk() -> void`
Creates the Walk action.

**Configuration:**
- Type: `MOVE`
- Speed: `5`
- Distance: `6.25` (25/4)
- Phase: `4` (Movement)

**Code:**
```gdscript
var walk_action = ActionBasis.new()
walk_action.action_type = ActionBasis.ActionType.MOVE
walk_action._set_move_speed(5)
walk_action._set_move_distance(25/4)
walk_action._set_action_turn(4)
walk_action.add_movement_point(get_parent().global_position)
Action_list['Walk'] = walk_action
```

---

#### Stub Initializers
These functions exist but are not yet implemented:

- `initialize_Sneak() -> void`
- `initialize_Peak() -> void` *(Note: typo in original, should be "Peek")*
- `initialize_Hold() -> void`
- `initialize_Ability1() -> void`
- `initialize_Ability2() -> void`
- `initialize_Ability3() -> void`
- `initialize_Ability4() -> void`

**To Implement:**
```gdscript
func initialize_Ability1():
    var ability1_action = ActionBasis.new()
    ability1_action.action_type = ActionBasis.ActionType.CAST
    ability1_action._set_move_speed(0)
    ability1_action._set_move_distance(0)
    ability1_action._set_action_turn(3)  # Attack phase
    Action_list['Ability1'] = ability1_action
```

---

## Usage in Scene Tree

```
CharacterBody3D (Character)
└── Node (Character_state_machine.gd)
```

**Accessing from character:**
```gdscript
# From character script
var state_machine = get_child(1)
var sprint_action = state_machine.Action_list['Sprint']

# From UI
var character_script = current_character.get_child(1)
var walk_speed = character_script.walking_speed
```

---

## Integration Points

### With UI System
```gdscript
# player_ui.gd
func action_button_pressed(action_string: String):
    var character_script = current_character.get_child(1)
    var character_action = character_script.Action_list[action_string]
```

### With Movement System
```gdscript
# Movement decal uses action distance
var circle_radius = character_action.get_distance_left()
var center_position = character_action.get_last_point()
region_display.display_region(center_position, circle_radius)
```

---

## Best Practices

1. **Always access via parent:** `character.get_child(1)` to get state machine
2. **Check for null:** Some actions may not be initialized
3. **Reset actions:** Call `initialize_<ActionName>()` to reset individual actions
4. **Use TurnActions:** Queue actions properly for phase execution
5. **Validate movements:** Always check distances before committing

---

## Extension Guide

### Adding New Action

1. **Add to Action_list dictionary:**
```gdscript
@onready var Action_list : Dictionary = {
    'Sprint': null,
    'Walk': null,
    'MyNewAction': null  # Add here
}
```

2. **Create initializer function:**
```gdscript
func initialize_MyNewAction():
    var new_action = ActionBasis.new()
    new_action.action_type = ActionBasis.ActionType.SHOOT
    new_action._set_move_speed(0)
    new_action._set_move_distance(15)  # Shoot range
    new_action._set_action_turn(3)  # Attack phase
    Action_list['MyNewAction'] = new_action
```

3. **Add UI button** in player_ui.gd

4. **Handle in game logic** during turn resolution

---

## Related Files

- `ActionClass.gd` - Action definition
- `player_ui.gd` - UI integration
- `movement_decal.gd` - Visual feedback
- `point_and_click_mover.gd` - Movement execution
