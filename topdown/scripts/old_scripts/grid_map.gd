extends GridMap
#@onready var camera = get_node("../../CharacterBody3D/Camera3D")
#
#func _unhandled_input(event: InputEvent) -> void:
	#if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		##var cell = get_cell_item(event.position)
		##print('EVENT: %s \n cell: %s' % [event, cell])
		#var pos = event.position
		#var from = camera.project_ray_origin(pos)
		#var to = from + camera.project_ray_normal(pos) * 1000
		#var space_state = get_world_3d().direct_space_state
		#var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))
		#print('EVENT: %s \n To: %s \n result: %s' % [pos, to, result])
		#print(get_cell_item(result.position))
	#return
