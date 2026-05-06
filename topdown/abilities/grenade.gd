extends RigidBody3D
@onready var camera_3d : Camera3D = null

@onready var end_point : Vector3 
@onready var ready_set_point : bool = false

func get_position_from_camera(pos):
	var from =  camera_3d.project_ray_origin(pos)
	var to = from + camera_3d.project_ray_normal(pos) * 1000
	var space_state = camera_3d.get_world_3d().direct_space_state
	var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))
	if len(result) > 0:
		print('Clicked Position: %s' % [result.position])
		return result.position
	return global_position

func send_object(end_position, initial_velocity):
	#find vector from start position to end position
	# make sure both points are on the same y plane
	#find distance from start point to end position (or length of vector found earlier)
	# calculate ((V^2)/g) * (2sin(45)), if greater than max distance find impulse vector at V at 45 degrees in direction of targett
	# if greater then theta is asin((Distance*gravity)/(2v^2))
	#find impulse vector at V at theta degrees in direction of target
	#apply_center_impulse(impulse_vector)
	pass
	




func _ready():
	camera_3d = get_tree().get_root().get_child(0).get_node('freeview_cam')
	if camera_3d:
		print(camera_3d.name)
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		print('start aiming with initial velocity of 5m/s')
		ready_set_point = true
	
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and camera_3d != null:
		print('clicked point')
		if ready_set_point == true:
			var old_end_point = end_point
			end_point = get_position_from_camera(event.position)
			if old_end_point != end_point and end_point != global_position:
				ready_set_point = false
