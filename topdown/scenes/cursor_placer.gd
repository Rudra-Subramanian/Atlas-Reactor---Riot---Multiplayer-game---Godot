extends Node3D


@onready var ShowCursor : bool = false
@onready var camera_3d = $".."
@onready var animation_player = $AnimationPlayer


func on_action_pressed(action_string: String):
	print(action_string)
	if action_string == 'Sprint':
		update_show(true)
	elif action_string == 'None':
		update_show(false)
	elif 'Ability' in action_string:
		update_show(false)
		
	

func _physics_process(delta: float) -> void:
	if ShowCursor:
		var mouse_position = get_viewport().get_mouse_position()
		var from =  camera_3d.project_ray_origin(mouse_position)
		var to = from + camera_3d.project_ray_normal(mouse_position) * 1000
		var space_state = camera_3d.get_world_3d().direct_space_state
		var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))
		if len(result) > 0:
			global_position = result.position
		


func update_show(boolvalue):
	ShowCursor = boolvalue
	visible = ShowCursor
	if visible:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		play_hover_animation()
		
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		stop_animations()
		


func spin_cursor():
	animation_player.play("Cone|spin")

	
	return
	
func play_hover_animation():
	animation_player.play("Cone|float")
	return

func stop_animations():
	animation_player.current_animation = "[stop]"
	
