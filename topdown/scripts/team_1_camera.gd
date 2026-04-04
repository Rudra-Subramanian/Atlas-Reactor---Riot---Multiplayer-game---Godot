extends CameraMover


@export var player1 : Node3D
@export var player2 : Node3D
@export var player3 : Node3D
@export var player4 : Node3D
@export var player5 : Node3D
@onready var tracking_character : Node3D = null

# SCREEN INPUT ---------------------
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_Q:
		if not is_rotating:
			start_rotate_camera(45)
	
	if event is InputEventKey and event.pressed and event.keycode == KEY_E:
		if not is_rotating:
			start_rotate_camera(-45)
	
	if tracking_character != null:
		return #no input movement allowed
	
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
	
# SCREEN INPUT  END---------------------

# HELPER FUNCTIONS ---------------------
func assign_player(index: int, PlayerNode: Node3D):
	if index == 1:
		player1 = PlayerNode
	elif index == 2:
		player2 = PlayerNode
	elif index == 3:
		player3 = PlayerNode
	elif index == 4:
		player4 = PlayerNode
	elif index == 5:
		player5 = PlayerNode
		


func _process(_delta: float) -> void:
	if is_rotating:
		rotate_camera()
	
	if is_moving:
		move_camera()
	
	if tracking_character and not is_moving:
		var current_y = tracking_character.position.y + 5
		var character_x = tracking_character.position.x
		var character_z = tracking_character.position.z
		position = Vector3(character_x, current_y, character_z)
		return
