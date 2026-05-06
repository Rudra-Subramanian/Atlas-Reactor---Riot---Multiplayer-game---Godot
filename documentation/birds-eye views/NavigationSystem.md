# Navigation System Documentation

## File: `navigation_path_finder.gd`

### Purpose
Helper class for querying navigation paths and visualizing them.

---

## Class Definition

```gdscript
class_name NavigationPathFinderHelper
extends Node3D
```

---

## Properties

| Property | Type | Description |
|----------|------|-------------|
| `line_shower` | `Node` | Reference to line visualization mesh |
| `query_parameters` | `NavigationPathQueryParameters3D` | Reusable query parameters object |
| `query_result` | `NavigationPathQueryResult3D` | Reusable query result object |

---

## Methods

### Lifecycle

#### `_ready() -> void`
Initializes line shower reference.

**Process:**
```gdscript
line_shower = $"/root/Game Scene/Level/Combat Manager/Team 1/region_display"
# Note: Can be set to null to disable visualization
```

**Usage:**
```gdscript
# To disable visualization
func _ready():
    line_shower = null
```

---

### Navigation Queries

#### `query_path(p_start_position: Vector3, p_target_position: Vector3, p_navigation_layers: int = 1) -> PackedVector3Array`

Queries the NavigationServer3D for a path between two positions.

**Parameters:**
- `p_start_position`: Starting position in world coordinates
- `p_target_position`: Target destination in world coordinates  
- `p_navigation_layers`: Navigation layer mask (default: 1)

**Returns:**
- `PackedVector3Array`: Array of waypoint positions, empty if invalid

**Process:**
1. Validates node is in scene tree
2. Gets navigation map from world
3. Checks if map is initialized
4. Configures query parameters
5. Queries NavigationServer3D
6. Optionally visualizes path if `line_shower` exists
7. Returns path array

---

### Detailed Implementation

```gdscript
func query_path(p_start_position: Vector3, p_target_position: Vector3, p_navigation_layers: int = 1) -> PackedVector3Array:
    # Validation: Must be in tree
    if not is_inside_tree():
        return PackedVector3Array()

    # Get navigation map
    var map: RID = get_world_3d().get_navigation_map()

    # Validate map is initialized
    if NavigationServer3D.map_get_iteration_id(map) == 0:
        return PackedVector3Array()

    # Configure query
    query_parameters.map = map
    query_parameters.start_position = p_start_position
    query_parameters.target_position = p_target_position
    query_parameters.navigation_layers = p_navigation_layers

    # Execute query
    NavigationServer3D.query_path(query_parameters, query_result)
    var path: PackedVector3Array = query_result.get_path()
    
    # Optional visualization
    if line_shower != null:
        line_shower.draw_line(path, 0)
    
    return path
```

---

## Usage Examples

### Basic Path Query

```gdscript
# Attach to scene
var nav_helper = NavigationPathFinderHelper.new()
add_child(nav_helper)

# Query a path
var start = character.global_position
var target = Vector3(10, 0, 5)
var path = nav_helper.query_path(start, target)

if path.size() > 0:
    print("Path found with ", path.size(), " waypoints")
    for point in path:
        print("  Waypoint: ", point)
else:
    print("No valid path")
```

---

### Integration with Character Movement

```gdscript
# In character movement script
@onready var nav_helper = $"/root/NavigationHelper"

func move_to_position(target: Vector3):
    var path = nav_helper.query_path(global_position, target)
    
    if path.size() > 1:  # Must have at least start + destination
        # Follow path
        follow_path(path)
    else:
        print("Cannot reach target")
```

---

### Using Navigation Layers

```gdscript
# Different navigation layers for different character types

# Ground units (layer 1)
var ground_path = nav_helper.query_path(start, target, 1)

# Flying units (layer 2)
var air_path = nav_helper.query_path(start, target, 2)

# Units that can use both (layers 1 + 2 = 3)
var combined_path = nav_helper.query_path(start, target, 3)
```

---

### Custom Visualization

```gdscript
# Disable built-in visualization
func _ready():
    line_shower = null

# Create custom visualization
var path = nav_helper.query_path(start, target)
for i in range(path.size() - 1):
    draw_arrow(path[i], path[i + 1])
```

---

## Integration Points

### With Movement Decal

The movement_decal.gd uses similar navigation queries:

```gdscript
# In movement_decal.gd
var path_to_point = query_path(center_position, result.position)
var length_to_path = get_length_of_path(path_to_point, result.position)

if length_to_path > maximum_path_length:
    # Point is too far via navigation
```

---

### With Point-and-Click Mover

Both implement the same pattern:

```gdscript
# In point_and_click_mover.gd
var query_parameters := NavigationPathQueryParameters3D.new()
var query_result := NavigationPathQueryResult3D.new()

func query_path(...):
    # Same implementation as NavigationPathFinderHelper
```

**Recommendation:** Centralize by using NavigationPathFinderHelper instead.

---

## Scene Setup

### Required Navigation Setup

1. **NavigationRegion3D** must exist in scene
2. **NavigationMesh** must be baked
3. **Character** must be within navigation region
4. **Map** must sync before first query

---

### Example Scene Structure

```
Level (Node3D)
├── NavigationRegion3D
│   └── MeshInstance3D (ground/level geometry)
├── NavigationPathFinderHelper
├── Characters
│   ├── Character1
│   └── Character2
└── CombatManager
    └── Team1
        └── region_display (for visualization)
```

---

## Navigation Server Details

### Map Lifecycle

```gdscript
# Get map
var map: RID = get_world_3d().get_navigation_map()

# Check if synced
var iteration = NavigationServer3D.map_get_iteration_id(map)
if iteration == 0:
    # Map not ready - has never synced
    # Usually means first frame or no NavigationRegion
```

**Map Syncing:**
- Happens automatically each physics frame
- First sync occurs after NavigationRegion added to tree
- Rebuilds when NavigationMesh changes

---

### Navigation Layers

Layers are bitmasks:

| Value | Binary | Layers |
|-------|--------|--------|
| 1 | 0001 | Layer 1 |
| 2 | 0010 | Layer 2 |
| 3 | 0011 | Layers 1+2 |
| 4 | 0100 | Layer 3 |
| 5 | 0101 | Layers 1+3 |

**Use Cases:**
- Layer 1: Ground navigation
- Layer 2: Jump/climb points
- Layer 3: Flying navigation
- Layer 4: Restricted areas (guards only)

---

## Performance Considerations

### Reusing Query Objects

**Good:** (Current implementation)
```gdscript
# Create once
var query_parameters := NavigationPathQueryParameters3D.new()
var query_result := NavigationPathQueryResult3D.new()

# Reuse many times
func query_path(...):
    query_parameters.map = map
    NavigationServer3D.query_path(query_parameters, query_result)
```

**Bad:**
```gdscript
# Creates new objects every call
func query_path(...):
    var params = NavigationPathQueryParameters3D.new()  # Avoid!
    var result = NavigationPathQueryResult3D.new()      # Avoid!
```

---

### Query Frequency

- **Per-frame queries:** Expensive, avoid if possible
- **On-click queries:** Fine, happens infrequently
- **Cached queries:** Best, query once and reuse

---

## Debugging

### Visualize Paths

```gdscript
# Ensure line_shower is set
func _ready():
    line_shower = $"/root/.../region_display"

# All queries will auto-draw
var path = query_path(start, target)
# Path drawn as pink line
```

---

### Check Path Validity

```gdscript
var path = query_path(start, target)

if path.size() == 0:
    print("No path found - check:")
    print("  - Is NavigationRegion in scene?")
    print("  - Is NavigationMesh baked?")
    print("  - Are positions on navigation mesh?")
    print("  - Are navigation layers correct?")
elif path.size() == 1:
    print("Path too short - likely start = target")
else:
    print("Valid path with ", path.size(), " waypoints")
```

---

### Print Path Details

```gdscript
var path = query_path(start, target)

for i in range(path.size()):
    print("Waypoint ", i, ": ", path[i])
    if i > 0:
        var dist = path[i].distance_to(path[i-1])
        print("  Distance from previous: ", dist)
```

---

## Best Practices

1. **Create one helper per scene/level:** Add as autoload or level child
2. **Reuse query objects:** Don't create new ones per query
3. **Validate return values:** Check `path.size() > 0`
4. **Cache frequent paths:** Store results instead of re-querying
5. **Use appropriate layers:** Match navigation layers to character capabilities
6. **Wait for map sync:** Check iteration_id before first query
7. **Visualize during development:** Enable line_shower for debugging

---

## Related Files

- `point_and_click_mover.gd` - Uses navigation queries for movement
- `character_pathfollowmover.gd` - Alternative movement with navigation
- `movement_decal.gd` - Uses queries to validate movement ranges
- `ActionClass.gd` - Stores paths in movement_points
