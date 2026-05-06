# Team Initializer Documentation

## File: `levels/test_levels/team_initializer.gd`

### Purpose
Automatically connects level components (characters, camera, UI, visualizations) during scene initialization.

---

## Node Type

```gdscript
extends Node
```

**Scene Position:** Root or high-level parent of level components

---

## Scene Structure

Expected child structure:

```
TeamInitializer (Node)
├── Camera3D (Team1Camera or similar)
├── Control (PlayerUI)
├── Node3D (Character 1)
├── Node3D (Character 2)
├── Node3D (Character 3)
├── ... (More characters)
└── MeshInstance3D (region_display for movement visualization)
```

---

## Initialization Process

### `_ready() -> void`

Automatically detects and connects all level components.

**Process:**
1. Gets all child nodes
2. Identifies each by class type
3. Stores references by category
4. Connects systems together

---

## Detection Logic

### Component Identification

Uses `get_class()` to identify node types:

```gdscript
for child in all_children:
    var class_type = child.get_class()
    
    if class_type == 'Camera3D':
        camera = child
    elif class_type == 'Control':
        ui = child
    elif class_type == 'Node3D':
        character_list.append(child)
    elif class_type == 'MeshInstance3D':
        region_display = child
```

---

### Component Categories

| Class Type | Stored As | Purpose |
|------------|-----------|---------|
| `Camera3D` | `camera` | Main gameplay camera |
| `Control` | `ui` | Player UI controller |
| `Node3D` | `character_list[]` | Player characters |
| `MeshInstance3D` | `region_display` | Movement range visualization |

**Note:** All characters must be direct Node3D nodes, not CharacterBody3D (returns as Node3D via get_class())

---

## Connection Logic

### UI to Camera Connection

```gdscript
if camera != null and ui != null:
    ui.initialize_camera(camera)
```

**Establishes:**
- Cursor action signal connection
- Camera tracking signal connection  
- Free cam signal connection

---

### Camera to Characters Connection

```gdscript
if camera != null and len(character_list) > 0:
    for i in range(len(character_list)):
        camera.assign_player(i, character_list[i])
```

**Assigns:**
- Character index 0 → camera.player1
- Character index 1 → camera.player2
- etc.

---

### UI to Characters Connection

```gdscript
if ui != null and len(character_list) > 0:
    ui.initialize_character_list(character_list)
```

**Sets up:**
- Character selection buttons
- Button labels/names
- Character reference array

---

### UI to Region Display Connection

```gdscript
if ui != null and region_display != null:
    ui.region_display = region_display
```

**Enables:**
- Movement range visualization
- Action radius display

---

## Complete Code Flow

```gdscript
func _ready() -> void:
    # 1. Get all children
    var all_children = get_children()
    
    # 2. Initialize storage
    var character_list = []
    var camera: Camera3D = null
    var ui: Control = null
    var region_display: MeshInstance3D = null
    
    # 3. Categorize children
    for child in all_children:
        match child.get_class():
            'Camera3D':
                camera = child
            'Control':
                ui = child
            'Node3D':
                character_list.append(child)
            'MeshInstance3D':
                region_display = child
    
    # 4. Connect UI ↔ Camera
    if camera and ui:
        ui.initialize_camera(camera)
    
    # 5. Connect Camera ↔ Characters
    if camera and character_list:
        for i in range(len(character_list)):
            camera.assign_player(i, character_list[i])
    
    # 6. Connect UI ↔ Characters
    if ui and character_list:
        ui.initialize_character_list(character_list)
    
    # 7. Connect UI ↔ Region Display
    if ui and region_display:
        ui.region_display = region_display
```

---

## Usage Example

### Level Scene Setup

```
Level (Node)
├── TeamInitializer (team_initializer.gd) ← Attach script here
│   ├── Team1Camera (Camera3D)
│   │   └── CursorPlacer
│   ├── PlayerUI (Control)
│   ├── Character1 (CharacterBody3D)*
│   │   └── CharacterStateMachine (Node)
│   ├── Character2 (CharacterBody3D)*
│   │   └── CharacterStateMachine (Node)
│   ├── Character3 (CharacterBody3D)*
│   │   └── CharacterStateMachine (Node)
│   └── RegionDisplay (MeshInstance3D)
└── Environment
    └── NavigationRegion3D
```

*Note: CharacterBody3D nodes report as 'Node3D' via get_class()

---

### Manual Setup (Without Initializer)

If not using team_initializer, connect manually:

```gdscript
# In level script
func _ready():
    var camera = $Team1Camera
    var ui = $PlayerUI
    var chars = [$Character1, $Character2, $Character3]
    var display = $RegionDisplay
    
    ui.initialize_camera(camera)
    ui.initialize_character_list(chars)
    ui.region_display = display
    
    for i in range(chars.size()):
        camera.assign_player(i, chars[i])
```

---

## Debugging

### Debug Prints

Add debug output to see what's detected:

```gdscript
for child in all_children:
    print("Child: ", child.name, " | Class: ", child.get_class())
    
    if child.get_class() == 'Camera3D':
        print("  → Camera found")
    # ... etc
```

---

### Verify Connections

```gdscript
# After connections
print("\n=== Connection Status ===")
print("Camera: ", camera != null)
print("UI: ", ui != null)
print("Characters: ", len(character_list))
print("Region Display: ", region_display != null)

if ui:
    print("\nUI Agents: ", ui.Agents.size())
    print("UI Camera: ", ui.camera_3d != null)
    print("UI Region Display: ", ui.region_display != null)

if camera:
    print("\nCamera Players:")
    print("  Player 1: ", camera.player1)
    print("  Player 2: ", camera.player2)
```

---

## Common Issues

### Issue: Characters Not Detected

**Cause:** CharacterBody3D indirectly inherits from Node3D  
**Solution:** Detection works, but verify with debug prints

**Check:**
```gdscript
var char = CharacterBody3D.new()
print(char.get_class())  # Prints "CharacterBody3D", not "Node3D"
```

**Note:** The detection might need adjustment:
```gdscript
if child.get_class() == 'CharacterBody3D' or child is Node3D:
    character_list.append(child)
```

---

### Issue: Wrong Node Type Detected

**Cause:** Multiple MeshInstance3D or Node3D in scene  
**Solution:** Use specific names or groups

**Better Detection:**
```gdscript
if child.name == "RegionDisplay":
    region_display = child
elif child.is_in_group("characters"):
    character_list.append(child)
```

---

### Issue: Order Dependency

**Cause:** Connections assume specific initialization order  
**Solution:** Add null checks before connections

```gdscript
if camera != null and ui != null:
    ui.initialize_camera(camera)
else:
    push_warning("Camera or UI not found!")
```

---

## Best Practices

### 1. Use Groups for Character Detection

```gdscript
# In character scenes
func _ready():
    add_to_group("team_characters")

# In team_initializer
if child.is_in_group("team_characters"):
    character_list.append(child)
```

---

### 2. Name Important Nodes

```gdscript
# Detect by name AND type
if child.get_class() == 'MeshInstance3D' and child.name == "RegionDisplay":
    region_display = child
```

---

### 3. Export Properties for Manual Override

```gdscript
extends Node

@export var camera: Camera3D
@export var ui: Control
@export var region_display: MeshInstance3D
@export var characters: Array[Node3D]

func _ready():
    # Auto-detect if not manually assigned
    if camera == null:
        camera = find_camera()
    
    # Then proceed with connections...
```

---

### 4. Validate Before Connecting

```gdscript
func _ready():
    var components = detect_components()
    
    if not validate_components(components):
        push_error("Missing required components!")
        return
    
    connect_components(components)

func validate_components(comp) -> bool:
    if comp.camera == null:
        push_error("No camera found!")
        return false
    if comp.character_list.size() == 0:
        push_warning("No characters found!")
    return true
```

---

## Improvements

### Enhanced Version

```gdscript
extends Node

# Optional manual overrides
@export var manual_camera: Camera3D
@export var manual_ui: Control
@export var manual_region_display: MeshInstance3D

func _ready() -> void:
    var components = {
        "camera": manual_camera,
        "ui": manual_ui,
        "characters": [],
        "region_display": manual_region_display
    }
    
    # Auto-detect missing components
    for child in get_children():
        if components.camera == null and child is Camera3D:
            components.camera = child
        elif components.ui == null and child is Control:
            components.ui = child
        elif child.is_in_group("characters"):
            components.characters.append(child)
        elif components.region_display == null and child.name == "RegionDisplay":
            components.region_display = child
    
    # Validate
    assert(components.camera != null, "No camera found")
    assert(components.ui != null, "No UI found")
    
    # Connect
    connect_systems(components)

func connect_systems(comp):
    comp.ui.initialize_camera(comp.camera)
    comp.ui.initialize_character_list(comp.characters)
    
    if comp.region_display:
        comp.ui.region_display = comp.region_display
    
    for i in range(comp.characters.size()):
        comp.camera.assign_player(i, comp.characters[i])
```

---

## Related Files

- `player_ui.gd` - UI system being initialized
- `team_1_camera.gd` - Camera system receiving character references
- `movement_decal.gd` - Region display being connected
- `Character_state_machine.gd` - Character script expected on characters

---

## Alternative: Autoload Approach

Instead of per-level initialization, use autoload:

```gdscript
# In Project Settings → Autoload
# Add: LevelManager → level_manager.gd

# level_manager.gd
extends Node

func initialize_level(level_root: Node):
    # Find components in any level
    var camera = find_child_by_type(level_root, Camera3D)
    var ui = find_child_by_type(level_root, Control)
    # ... connect
```

Then call from level:

```gdscript
func _ready():
    LevelManager.initialize_level(self)
```
