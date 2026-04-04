
class_name CameraMover
extends Camera3D



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
