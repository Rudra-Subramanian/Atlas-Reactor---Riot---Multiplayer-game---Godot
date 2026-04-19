class_name NavigationPathFinderHelper

extends Node3D

@onready var line_shower = null
# BEING ABLE TO QUERY POSITIONS ON MAP
# Prepare query objects.
var query_parameters := NavigationPathQueryParameters3D.new()
var query_result := NavigationPathQueryResult3D.new()

func _ready():
	line_shower = $"/root/Game Scene/Level/Combat Manager/Team 1/region_display"
	#line_shower = null

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
	if line_shower != null:
		line_shower.draw_line(path , 0)
	return path
