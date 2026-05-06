# UI Systems Documentation

## Overview

Two UI controllers manage the player interface and game state.

---

## Player UI (Main Controller)

### File: `scenes/uis/player_ui.gd`

Primary UI controller for character selection, action buttons, and camera control.

```gdscript
extends Control
```

---

### UI Structure

The UI is divided into three main sections:

```
Player_UI (Control)
├── bottom character (HBoxContainer) - Character selection
├── actions (VBoxContainer) - Action buttons
└── Turn end actions (VBoxContainer) - Confirm/Cancel
```

---

### Properties

#### UI Node References

| Property | Type | Description |
|----------|------|-------------|
| `bottom_bar` | `HBoxContainer` | Container for character buttons |
| `left_bar` | `VBoxContainer` | Container for action buttons |
| `right_bar` | `VBoxContainer` | Container for turn end buttons |
| `cancel_button` | `Button` | Cancel current action |
| `confirm_button` | `Button` | Confirm turn actions |

#### Action Buttons

| Property | Type | Description |
|----------|------|-------------|
| `Ability1_button` | `Button` | Ability 1 button |
| `Ability2_button` | `Button` | Ability 2 button |
| `Ability3_button` | `Button` | Ability 3 button |
| `Ability4_button` | `Button` | Ability 4 button |
| `action_sprint` | `Button` | Sprint action button |
| `action_sneak` | `Button` | Sneak action button |
| `action_peek` | `Button` | Peek action button |
| `action_hold` | `Button` | Hold action button |
| `action_walk` | `Button` | Walk action button |

#### Character Buttons

| Property | Type | Description |
|----------|------|-------------|
| `character_1` to `character_5` | `Button` | Character selection buttons |
| `character_button_list` | `Array` | Array of all character buttons |
| `free_cam` | `Button` | Free camera mode button |

#### Game State

| Property | Type | Description |
|----------|------|-------------|
| `camera_3d` | `Camera3D` | Reference to game camera |
| `Agents` | `Array` | List of all player characters |
| `current_character` | `Node3D` | Currently selected character |
| `current_click_mode` | `ClickMode` | Current interaction mode |
| `region_display` | `MeshInstance3D` | Movement visualization mesh |

---

### Enumerations

```gdscript
enum ClickMode {
    NOCLICK,           # No clicking allowed
    CHARACTER_MOVE,    # Click to move character
    CHARACTER_ACTION,  # Click to use action
    CHARACTER_AIM      # Click to aim ability
}
```

---

### Signals

```gdscript
signal Character_Pressed(Character: Node3D)
signal FreeCamStart()
signal ActionPressed(ButtonName: String, character_node: Node3D)
signal CancelPressed()
signal ConfirmPressed()
```

---

## Core Methods

### Lifecycle

#### `_ready() -> void`
Initializes all signal connections.

**Connections:**
```gdscript
# Button connections
cancel_button.pressed.connect(CancelPressed.emit)
confirm_button.pressed.connect(ConfirmPressed.emit)
character_1.pressed.connect(Char1_pressed)
# ... etc

# Signal handlers
Character_Pressed.connect(_character_pressed)
ConfirmPressed.connect(_confirm_pressed)
CancelPressed.connect(_cancel_pressed)
ActionPressed.emit('None')  # Initialize cursor

# Final setup
ChangeLeftBar(current_character)
EnableUI()
```

---

### Initialization

#### `initialize_character_list(new_character_list: Array) -> void`
Sets up character buttons for available characters.

**Parameters:**
- `new_character_list`: Array of character Node3D references

**Process:**
1. Stores list in `Agents`
2. Updates each button with character info
3. Shows/hides buttons based on character count

**Usage:**
```gdscript
ui.initialize_character_list([char1, char2, char3])
```

---

#### `initialize_camera(camera_to_connect: Camera3D) -> void`
Connects camera to UI signals.

**Parameters:**
- `camera_to_connect`: The game camera

**Connections:**
```gdscript
ActionPressed → cursor.on_action_pressed
FreeCamStart → camera.stop_tracking
Character_Pressed → camera.track_character
```

---

### Character Selection

#### Character Button Handlers

Each character has a dedicated handler:

```gdscript
func Char1_pressed() -> void:
    if len(Agents) > 0:
        Character_Pressed.emit(Agents[0])

func Char2_pressed() -> void:
    if len(Agents) > 1:
        Character_Pressed.emit(Agents[1])
# ... Char3, Char4, Char5 similar pattern
```

---

#### `free_cam_pressed() -> void`
Emits signal to enter free camera mode.

```gdscript
func free_cam_pressed() -> void:
    FreeCamStart.emit()
```

---

#### `_character_pressed(character: Node3D) -> void`
Signal handler when character selected.

**Parameters:**
- `character`: The selected character node

**Process:**
1. Sets `current_character`
2. Updates left bar with character's actions
3. Updates character name label

---

### Action Management

#### `action_button_pressed(action_string: String) -> void`
Handles action button clicks.

**Parameters:**
- `action_string`: Name of action ('Sprint', 'Walk', 'Ability1', etc.)

**Process:**
1. Emits `ActionPressed` signal
2. Gets action from character's state machine
3. Sets character's `Current_Action`
4. If movement action:
   - Sets click mode to `CHARACTER_MOVE`
   - Disables action buttons
   - Displays movement region visualization

**Usage:**
```gdscript
action_sprint.pressed.connect(action_button_pressed.bind('Sprint'))
```

**Example Flow:**
```gdscript
# User clicks Sprint button
action_button_pressed('Sprint')
    ↓
ActionPressed.emit('Sprint', current_character)
    ↓
current_character.get_child(1).Current_Action = 'Sprint'
    ↓
current_click_mode = ClickMode.CHARACTER_MOVE
    ↓
DisableActions()
    ↓
region_display.display_region(center, radius)
```

---

### Turn Management

#### `_confirm_pressed() -> void`
Confirms current turn actions.

**Currently:** Stub implementation (prints message)

**Intended:**
1. Lock in all character actions
2. Disable UI
3. Execute turn resolution

---

#### `_cancel_pressed() -> void`
Cancels current action and resets.

**Process:**
1. Gets current/last action name
2. Gets action object from character
3. Hides cursor
4. Reinitializes action to reset it
5. Sets click mode to `NOCLICK`
6. Enables action buttons
7. Clears region display

**Code Flow:**
```gdscript
var action_name = current_character.get_child(1).Current_Action
if action_name == '':
    action_name = current_character.get_child(1).Last_Action
    
# Reset action
var function_string = "current_character.get_child(1).initialize_" + action_name + "()"
function_to_run.parse(function_string)
function_to_run.execute()

# Cleanup UI
cursor.update_show(false)
EnableActions()
region_display.clear_mesh()
```

---

### UI State Management

#### `DisableActions() -> void`
Disables action and character buttons.

**Behavior:**
- Disables all left bar buttons
- Disables all bottom bar buttons EXCEPT:
  - Current character button
  - Free cam button

**Usage:**
```gdscript
# When action selected
DisableActions()
```

---

#### `EnableActions() -> void`
Re-enables all UI buttons.

**Also:**
- Sets mouse mode to visible
- Enables all left and bottom bar buttons

---

#### `update_bottom_bar_buttons() -> void`
Shows/hides character buttons based on character count.

**Logic:**
```gdscript
for i in range(len(character_button_list)):
    if i < len(Agents):
        character_button_list[i].show()
    else:
        character_button_list[i].hide()
```

---

### UI Updates

#### `set_label(textstring: String) -> bool`
Updates the current character label.

**Parameters:**
- `textstring`: Text to display (usually character name)

**Returns:**
- `bool`: True if label found and updated

---

#### `ChangeBottomBar(Character: Node3D, index: int) -> void`
Updates a character button with character info.

**Parameters:**
- `Character`: Character node
- `index`: Button index (0-4)

**Sets button text to:**
- Character.name if available
- "Character {index}" otherwise

---

#### `ChangeLeftBar(Character: Node3D) -> void`
Updates action buttons for selected character.

**Parameters:**
- `Character`: Selected character (or null to hide all)

**Process:**
1. If null: hides all left bar buttons
2. If valid character:
   - Sets label to character name
   - Updates each button with action name from `Action_list`
   - Shows all buttons

**Example:**
```gdscript
# Character has actions: Sprint, Walk, Sneak, Peek, Hold
ChangeLeftBar(character)
# Buttons now labeled with those action names
```

---

## Character UI Scene (Legacy)

### File: `scripts/character_ui_scene.gd`

**Status:** Legacy UI controller - appears to be from earlier version.

```gdscript
extends Control
```

---

### Key Differences

1. **Simpler structure:** Fewer references
2. **Game state tracking:** Has `GameStates` array
3. **Movement validation:** `check_all_movement_done()`
4. **Auto-reset:** Clears `ready_characters` array

---

### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `GameStates` | `Array` | Decision/Dash/Action/Movement/Turn End | All game phases |
| `GameState` | `bool` | `false` | Whether turn is executing |
| `GameStep` | `String` | `'Decision'` | Current game phase |
| `all_characters` | `Array` | `['astra']` | Character names |
| `ready_characters` | `Array` | `[]` | Characters that finished moving |

---

### Signals

```gdscript
signal move_characters()
signal CurrentGameStep(step: String)
```

---

### Methods

#### `check_all_movement_done() -> bool`
Checks if all characters completed movement.

**Returns:**
- `bool`: True if all characters in `ready_characters`

**Side Effect:** Clears `ready_characters` array when returning true

---

#### `set_character_done_movement(character: String, bool_value: bool) -> void`
Marks character as finished moving.

**Connected to:** `character.movement_finished` signal

**Process:**
1. If not finished, returns early
2. Adds character to `ready_characters`
3. Calls `change_state_player_actions()`

---

#### `_confirm_button_pressed() -> void`
Confirms turn and starts execution.

**Process:**
1. Emits `CurrentGameStep('Confirm')`
2. Disables all action buttons
3. Sets mouse filter to IGNORE (click-through)
4. Emits `move_characters` signal
5. Sets `GameState = true`

---

#### `change_state_player_actions() -> void`
Re-enables UI when all movement complete.

**Process:**
1. Checks `check_all_movement_done()`
2. If all done:
   - Enables all buttons
   - Sets mouse filter enabled
   - Sets `GameState = false`

---

## Usage Examples

### Complete UI Setup

```gdscript
# In team initializer or level setup
var ui = $PlayerUI
var camera = $Camera3D
var characters = [char1, char2, char3]
var region_display = $RegionDisplay

# Connect everything
ui.initialize_camera(camera)
ui.initialize_character_list(characters)
ui.region_display = region_display
```

---

### Handling Action Flow

```gdscript
# User clicks character button
Char1_pressed()
    ↓
Character_Pressed.emit(character)
    ↓  
_character_pressed(character)
    ↓
ChangeLeftBar(character)  # Shows character's actions
    ↓
# User clicks Sprint
action_button_pressed('Sprint')
    ↓
DisableActions()  # Prevent other actions
region_display.display_region(...)  # Show range
current_click_mode = CHARACTER_MOVE
    ↓
# User clicks destination on map
# (handled in character movement script)
    ↓
# User clicks Cancel
_cancel_pressed()
    ↓
Reset action, EnableActions(), clear display
```

---

### Turn Execution (Legacy System)

```gdscript
# User plans all actions, clicks Confirm
_confirm_button_pressed()
    ↓
DisableActions()
move_characters.emit()
    ↓
# Each character moves
character.movement_finished.emit(name, true)
    ↓
set_character_done_movement(name, true)
    ↓
# When all done
change_state_player_actions()
    ↓
EnableActions()  # Ready for next turn
```

---

## Best Practices

1. **Always initialize camera and characters** before use
2. **Use DisableActions()/EnableActions()** to control turn flow
3. **Connect movement_finished signals** to track completion
4. **Clear region display** when canceling actions
5. **Update Current_Action** on character state machine
6. **Validate actions** before allowing execution
7. **Handle null current_character** gracefully

---

## Integration Points

### With Camera System
```gdscript
initialize_camera(camera)
# Connects: ActionPressed, FreeCamStart, Character_Pressed
```

---

### With Character System
```gdscript
# Access character's state machine
var state = current_character.get_child(1)
var action = state.Action_list['Sprint']
var distance = action.get_distance_left()
```

---

### With Movement Visualization
```gdscript
# Show valid movement area
var center = action.get_last_point()
var radius = action.get_distance_left()
region_display.display_region(center, radius, false)
```

---

## Related Files

- `Character_state_machine.gd` - Action data source
- `team_1_camera.gd` - Camera tracking
- `cursor_placer.gd` - Visual feedback
- `movement_decal.gd` - Range visualization
- `ActionClass.gd` - Action definitions
