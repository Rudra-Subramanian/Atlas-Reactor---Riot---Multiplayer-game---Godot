## Custom Camera Template
## Extend CameraMover to create specialized camera behaviors
## Based on CameraMover.gd and team_1_camera.gd

extends CameraMover

class_name CustomCameraTemplate

## TODO: Add custom properties
@export_group("Custom Camera Settings")
@export var auto_follow_enabled: bool = true
@export var follow_smoothing: float = 0.1
@export var zoom_min: float = 5.0
@export var zoom_max: float = 20.0
@export var current_zoom: float = 10.0

## Custom camera modes
enum CameraMode {
	FREE,           # Manual WASD control
	FOLLOW,         # Following a character
	CINEMATIC,      # Scripted camera movement
	OVERVIEW        # Bird's eye view
}

@export var current_mode: CameraMode = CameraMode.FREE

## Tracked targets
@export var primary_target: Node3D
@export var targets: Array[Node3D] = []

func _ready() -> void:
	super._ready()  # Call parent _ready if it exists
	setup_custom_camera()


func setup_custom_camera() -> void:
	# TODO: Initialize custom camera settings
	position.y = current_zoom
	rotation.x = deg_to_rad(-45)  # Default angle


func _process(delta: float) -> void:
	# Handle base camera movement/rotation
	if is_rotating:
		rotate_camera()
	
	if is_moving:
		move_camera()
	
	# Handle custom camera modes
	match current_mode:
		CameraMode.FREE:
			handle_free_mode(delta)
		CameraMode.FOLLOW:
			handle_follow_mode(delta)
		CameraMode.CINEMATIC:
			handle_cinematic_mode(delta)
		CameraMode.OVERVIEW:
			handle_overview_mode(delta)


func _unhandled_input(event: InputEvent) -> void:
	# Handle base rotation
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_Q:
				if not is_rotating:
					start_rotate_camera(45)
			KEY_E:
				if not is_rotating:
					start_rotate_camera(-45)
	
	# Handle custom camera controls
	handle_custom_input(event)


## Custom Mode Handlers

func handle_free_mode(delta: float) -> void:
	# Free camera - WASD movement allowed
	if not is_moving:
		# Movement handled by input
		pass


func handle_follow_mode(delta: float) -> void:
	if not primary_target:
		return
	
	if not is_moving:
		# Smoothly follow target
		var target_pos = primary_target.global_position
		target_pos.y = current_zoom
		
		if auto_follow_enabled:
			position = position.lerp(target_pos, follow_smoothing)


func handle_cinematic_mode(delta: float) -> void:
	# TODO: Implement cinematic camera paths
	pass


func handle_overview_mode(delta: float) -> void:
	# Center on all targets
	if targets.size() == 0:
		return
	
	var center = Vector3.ZERO
	for target in targets:
		if target:
			center += target.global_position
	
	center /= targets.size()
	center.y = current_zoom * 1.5  # Higher for overview
	
	if not is_moving:
		position = position.lerp(center, 0.05)


## Custom Input Handling

func handle_custom_input(event: InputEvent) -> void:
	if current_mode != CameraMode.FREE:
		return  # Only allow input in free mode
	
	if event is InputEventKey and event.pressed and not is_moving:
		var move_vector = Vector3.ZERO
		var distance = move_distance
		
		match event.keycode:
			KEY_W:
				move_vector = -transform.basis.z
			KEY_A:
				move_vector = -transform.basis.x
			KEY_S:
				move_vector = transform.basis.z
			KEY_D:
				move_vector = transform.basis.x
		
		if move_vector != Vector3.ZERO:
			move_vector.y = 0
			move_vector = move_vector.normalized()
			start_move_camera(move_vector * distance)


## Mode Switching

func set_camera_mode(mode: CameraMode) -> void:
	current_mode = mode
	print("Camera mode changed to: ", CameraMode.keys()[mode])


func follow_target(target: Node3D) -> void:
	primary_target = target
	current_mode = CameraMode.FOLLOW


func stop_following() -> void:
	primary_target = null
	current_mode = CameraMode.FREE


func focus_on_targets(target_list: Array[Node3D]) -> void:
	targets = target_list
	current_mode = CameraMode.OVERVIEW


## Zoom Controls

func zoom_in(amount: float = 1.0) -> void:
	current_zoom = max(zoom_min, current_zoom - amount)
	animate_zoom_change()


func zoom_out(amount: float = 1.0) -> void:
	current_zoom = min(zoom_max, current_zoom + amount)
	animate_zoom_change()


func animate_zoom_change() -> void:
	var target_pos = position
	target_pos.y = current_zoom
	move_cam_to_position(target_pos)


## Cinematic Functions

func play_camera_path(waypoints: Array[Vector3], duration: float) -> void:
	current_mode = CameraMode.CINEMATIC
	# TODO: Implement spline or lerp through waypoints


func look_at_target(target: Node3D, duration: float = 1.0) -> void:
	# Smoothly orient camera toward target
	var direction = target.global_position - global_position
	var target_rotation_y = atan2(direction.x, direction.z)
	var rotation_diff = rad_to_deg(target_rotation_y - rotation.y)
	start_rotate_camera(rotation_diff)


## Shake Effects

func camera_shake(intensity: float = 0.5, duration: float = 0.5) -> void:
	var shake_timer = 0.0
	var original_pos = position
	
	while shake_timer < duration:
		await get_tree().process_frame
		shake_timer += get_process_delta_time()
		
		var shake_amount = intensity * (1.0 - shake_timer / duration)
		var offset = Vector3(
			randf_range(-shake_amount, shake_amount),
			randf_range(-shake_amount, shake_amount),
			randf_range(-shake_amount, shake_amount)
		)
		
		position = original_pos + offset
	
	position = original_pos


## Team Integration

func assign_team_players(player_list: Array[Node3D]) -> void:
	for i in range(min(player_list.size(), 5)):
		match i:
			0: primary_target = player_list[i]
			# Add more if using parent's player properties
	
	targets = player_list
