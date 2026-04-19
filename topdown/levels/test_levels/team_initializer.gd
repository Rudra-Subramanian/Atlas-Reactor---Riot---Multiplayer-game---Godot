extends Node

@onready var camera : Camera3D = null
@onready var character_list = []
@onready var ui : Control = null
@onready var region_display : MeshInstance3D = null


func _ready() -> void:
	var all_children = get_children()
	#associate children properly
	
	
	
	
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
		if child.get_class() == 'MeshInstance3D':
			print('region display mesh found')
			region_display = child
	if camera != null and ui != null:
		ui.initialize_camera(camera)
		
	if camera != null and len(character_list) > 0:
		for i in range(len(character_list)):
			camera.assign_player(i, character_list[i])
	if ui != null and len(character_list) > 0:
		ui.initialize_character_list(character_list)
		#ui.ConfirmPressed.connect(_ExecuteTurn)
	if ui != null and region_display != null:
		ui.region_display = region_display

#func _ExecuteTurn() -> void:
#	for character in character_list:
#		var character_actions = character.get_child(1).TurnActions
#		var Action_runner = character.get_child(2)
#		print(character_actions)

		
		
		
