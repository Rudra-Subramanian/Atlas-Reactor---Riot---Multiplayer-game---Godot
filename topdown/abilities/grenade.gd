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
	var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	
	
	# Find vector from start position to end position
	var start_pos = global_position
	var direction_vector = end_position - start_pos
	
	# Make sure both points are on the same y plane
	var start_flat = Vector3(start_pos.x, 0, start_pos.z)
	var end_flat = Vector3(end_position.x, 0, end_position.z)
	var flat_vector = end_flat - start_flat
	
	# Find distance from start point to end position (or length of vector found earlier)
	var distance = flat_vector.length()
	var horizontal_direction = flat_vector.normalized()
	
	# Calculate ((V^2)/g) * (2sin(45))
	var max_distance = ((initial_velocity * initial_velocity) / gravity) #* (2 * sin(deg_to_rad(45)))
	
	var theta = 0.0
	
	# If greater than max distance find impulse vector at V at 45 degrees in direction of target
	if distance > max_distance:
		print('too far')
		theta = deg_to_rad(45)
	else:
		# If within range then theta is asin((Distance*gravity)/(2v^2))
		var angle_value = (distance * gravity) / (2 * initial_velocity * initial_velocity)
		print('Angle value before clamping: %s' % [angle_value])
		angle_value = clamp(angle_value, -1.0, 1.0)  # Ensure valid range for asin
		theta = deg_to_rad(90 - (rad_to_deg(asin(angle_value))))
	
	# Find impulse vector at V at theta degrees in direction of target
	var horizontal_velocity = initial_velocity * cos(theta)
	var vertical_velocity = initial_velocity * sin(theta)
	var impulse_vector = (horizontal_direction * horizontal_velocity) + (Vector3.UP * vertical_velocity)
	print('angle: %s \nmax distance: %s\ndistance: %s\nhorizontal direction: %s\nhorizontal velocity: %s\nvertical velocity: %s' % [rad_to_deg(theta),max_distance,distance,horizontal_direction, horizontal_velocity, vertical_velocity])
	
	
	# apply_center_impulse(impulse_vector)
	apply_central_impulse(impulse_vector * mass)
	




func _ready():
	camera_3d = get_tree().get_root().get_child(0).get_node('freeview_cam')
	if camera_3d:
		print(camera_3d.name)
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		print('start aiming with initial velocity of 10m/s')
		ready_set_point = true
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
	
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and camera_3d != null:
		print('clicked point')
		if ready_set_point == true:
			var old_end_point = end_point
			end_point = get_position_from_camera(event.position)
			if old_end_point != end_point and end_point != global_position:
				ready_set_point = false
				send_object(end_point, 10.0)  # Using 20 m/s
