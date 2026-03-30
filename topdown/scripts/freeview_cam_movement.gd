extends Camera3D
@onready var astra : CharacterBody3D = $"../astra"

@onready var tracking_character : bool = true
@onready var no_input : bool = false


@onready var is_rotating: bool = false
@onready var rotation_progress: float = 0.0
@onready var rotation_duration: float = 15.0
@onready var target_rotation: float = 0.0
@onready var start_rotation: float = 0.0

@onready var is_moving: bool = false
@onready var move_progress: float = 0.0
@onready var move_duration: float = 15.0
@onready var start_position: Vector3
@onready var target_position: Vector3
@onready var move_distance: float = 5.0

func _unhandled_input(event: InputEvent) -> void:
	if no_input == true:
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_Q:
		if not is_rotating:
			start_rotate_camera(45)
	
	if event is InputEventKey and event.pressed and event.keycode == KEY_E:
		if not is_rotating:
			start_rotate_camera(-45)
			


	
	if tracking_character == true:
		return
	
	if event is InputEventKey and event.pressed and event.keycode == KEY_W:
		if not is_moving:
			var forward = -transform.basis.z
			forward.y = 0
			forward = forward.normalized()
			start_move_camera(forward * move_distance)
	
	if event is InputEventKey and event.pressed and event.keycode == KEY_A:
		if not is_moving:
			var left = -transform.basis.x
			left.y = 0
			left = left.normalized()
			start_move_camera(left * move_distance)
	
	if event is InputEventKey and event.pressed and event.keycode == KEY_S:
		if not is_moving:
			var backward = transform.basis.z
			backward.y = 0
			backward = backward.normalized()
			start_move_camera(backward * move_distance)
	
	if event is InputEventKey and event.pressed and event.keycode == KEY_D:
		if not is_moving:
			var right = transform.basis.x
			right.y = 0
			right = right.normalized()
			start_move_camera(right * move_distance)
	

	return
	
func start_tracking_character() -> void:	
	if not is_moving:
		var current_y = position.y
		var character_x = astra.position.x
		var character_z = astra.position.z
		var newposition = Vector3(character_x, current_y, character_z)
		move_cam_to_position(newposition)
		tracking_character = not tracking_character
	return

func start_rotate_camera(rotation_value: float) -> void:
	start_rotation = rotation.y
	target_rotation = rotation.y + deg_to_rad(rotation_value)
	is_rotating = true
	rotation_progress = 0.0
	

func rotate_camera() -> void:
	rotation_progress += 1.0
	var t = rotation_progress / rotation_duration
	# Ease in-out for smooth motion
	t = ease(t, -2.0)
	rotation.y = lerp(start_rotation, target_rotation, t)
	
	if rotation_progress >= rotation_duration:
		rotation.y = target_rotation
		is_rotating = false



func start_move_camera(move_vector: Vector3) -> void:
	start_position = global_position
	target_position = global_position + move_vector
	is_moving = true
	move_progress = 0.0

func move_cam_to_position(move_vector: Vector3) -> void:
	start_position = global_position
	target_position = move_vector
	is_moving=true
	move_progress = 0.0
	

func move_camera() -> void:
	move_progress += 1.0
	var t = move_progress / move_duration
	# Ease in-out for smooth motion
	t = ease(t, -2.0)
	global_position = lerp(start_position, target_position, t)
	
	if move_progress >= move_duration:
		global_position = target_position
		is_moving = false

func _process(_delta: float) -> void:
	if is_rotating:
		rotate_camera()


	if is_moving:
		move_camera()
	
	if tracking_character and not is_moving:
		var current_y = position.y
		var character_x = astra.position.x
		var character_z = astra.position.z
		position = Vector3(character_x, current_y, character_z)
		return
