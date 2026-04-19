class_name ActionBasis

var move_speed : float
var move_distance : float
var action_turn : int #either 1 ,2,3 or 4 
var movement_points : Array[Vector3]
var action_type


enum ActionType {SHOOT, THROW, USE, CAST, MOVE}

func _set_move_speed(speed: float) -> void:
	move_speed = speed
func _set_move_distance(distance: float) -> void:
	move_distance = distance
func _set_action_turn(turn: int) -> void:
	action_turn = turn

func set_movement_zero(position: Vector3):
	movement_points = [position]
	return

func add_movement_point(position: Vector3):
	var old_points = movement_points
	movement_points.append(position)
	if get_distance_left() < 0:
		movement_points = old_points
		print('point too far')
	

func add_movement_array(movement_points : PackedVector3Array):
	for point in movement_points:
		add_movement_point(point)

func get_movement_path() -> Array:

	return movement_points	

func get_last_point() -> Vector3:
	return movement_points[-1]

func get_current_distance() -> float:
	var total = 0
	var previous_point = null
	for point in movement_points:
		if previous_point == null:
			previous_point = point
		else:
			total = total + previous_point.distance_to(point)
			previous_point = point
	return total #add up the distance between all the movement points

func get_distance_left() -> float:
	var current_distance = get_current_distance()
	return move_distance - current_distance
