extends CharacterBody3D
@onready var camera_3d: Camera3D = $"../freeview_cam"
@onready var movement_path: Array[Vector3] = []
@export var walking_speed: float = 5
@export var peeking_speed: float = 1
@export var running_speed: float = 8
@export var current_movement_speed: float = 10.0 #knife run speed
@onready var Health : float = 100
@onready var TurnActions: Array = []

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


signal movement_finished(name,bool_value)


# --------------------------
# BEING ABLE TO QUERY POSITIONS ON MAP
# Prepare query objects.
var query_parameters := NavigationPathQueryParameters3D.new()
var query_result := NavigationPathQueryResult3D.new()

func query_path(p_start_position: Vector3, p_target_position: Vector3, p_navigation_layers: int = 1) -> PackedVector3Array:
	if not is_inside_tree():
		return PackedVector3Array()

	var map: RID = get_world_3d().get_navigation_map()

	if NavigationServer3D.map_get_iteration_id(map) == 0:
		# This map has never synced and is empty, no point in querying it.
		return PackedVector3Array()

	query_parameters.map = map
	query_parameters.start_position = p_start_position
	query_parameters.target_position = p_target_position
	query_parameters.navigation_layers = p_navigation_layers

	NavigationServer3D.query_path(query_parameters, query_result)
	var path: PackedVector3Array = query_result.get_path()

	return path
# ----------------------------
