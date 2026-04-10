extends Node


func _ready() -> void:
	var all_children = get_children()
	#associate children properly
	var character_list = []
	var camera : Camera3D = null
	var ui : Control = null
	for child in all_children:
		print(child.get_class())
		child.get_class()
		if child.get_class() == 'Camera3D':
			print('camera found')
			camera = child
		if child.get_class() == 'Control':
			print('control found')
			ui = child
		if child.get_class() == 'Node3D':
			print('character found')
			character_list.append(child)
	if camera != null and ui != null:
		ui.initialize_camera(camera)
		
	if camera != null and len(character_list) > 0:
		for i in range(len(character_list)):
			camera.assign_player(i, character_list[i])
	if ui != null and len(character_list) > 0:
		ui.initialize_character_list(character_list)
	
		
		
		
