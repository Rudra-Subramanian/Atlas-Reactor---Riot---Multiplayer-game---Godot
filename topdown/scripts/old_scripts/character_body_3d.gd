extends CharacterBody3D
@export_group('Movement')
@export var base_speed = 5
@export var init_velocity = Vector3.ZERO

func _process(delta: float) -> void:
	var keyboard_input = Input.get_vector("move_down",
	"move_left",
	"move_right",
	"move_up")
	#print(keyboard_input)
	

	move_and_slide()
	
	return

func _unhandled_input(event: InputEvent) -> void:
	var direction = Vector3.ZERO
	var neweven = event
	if Input.is_action_pressed('move_right'):
		direction.x += 1
	if Input.is_action_pressed('move_left'):

		direction.x -= 1
	if Input.is_action_just_pressed('move_up'):

		direction.z -= 1
	if Input.is_action_just_pressed('move_down'):

		direction.z += 1
	self.velocity.x = direction.x * base_speed
	self.velocity.z = direction.z * base_speed
		
