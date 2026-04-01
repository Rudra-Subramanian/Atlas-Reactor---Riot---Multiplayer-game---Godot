extends MeshInstance3D


@onready var shape_cast_3d: ShapeCast3D = ShapeCast3D.new()
@onready var material : StandardMaterial3D
@export var radius: float = 20.0
@export var ray_count: int = 100  # How many points to sample
@export var start_height: float = 10.0
@export var cast_distance: float = 20.0 # Length of the rays downward
# Prepare query objects.
@onready var query_parameters := NavigationPathQueryParameters3D.new()
@onready var query_result := NavigationPathQueryResult3D.new()
@onready var circles : Array = []



func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		#var collision_array = get_collision_array()
		#form_mesh(collision_array)
		for circle in circles:
			circle.queue_free()
		circles.clear()
		self.mesh = null
		var  points = get_bounding_pointsfunc(global_position)
		draw_better_mesh(points, global_position)
	return	






func get_bounding_pointsfunc(center_position) -> Array[Vector3]:
	var hit_points: Array[Vector3] = []
	var parent = get_parent()
	var space_state = get_world_3d().direct_space_state
	# Calculate the angle between each ray
	var angle_step = (PI * 2.0) / ray_count

	for i in range(ray_count):
		var hit_position = check_if_point_is_valid(i, angle_step, space_state, radius, center_position)
		# 1. Calculate the X and Z position on the circle's edge
		
		if hit_position:
			hit_points.append(hit_position.position)

			
	return hit_points

func check_if_point_is_valid(i, angle_step, space_state, distance_from_center, center_position):
			# 1. Calculate the X and Z position on the circle's edge
		var current_angle = i * angle_step
		var x = cos(current_angle) * distance_from_center
		var z = sin(current_angle) * distance_from_center
		
		# 2. Define the ray start (at height 10) and end (sweeping down)
		# We start relative to the character's current global position
		var ray_start = center_position + Vector3(x, start_height, z)
		var ray_end = ray_start + Vector3(0, -cast_distance, 0)
		
		# 3. Create and run the raycast
		var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end)
		
		var result = space_state.intersect_ray(query)
		
		# 4. If we hit the mesh, save the coordinate
		if result:
			var path_to_point = query_path(global_position, result.position)
			#print('\n\npat  h to the found point is %s \n final position is: %s' % [path_to_point, result.position])
			var length_to_path = get_length_of_path(path_to_point, result.position)
			if length_to_path > 20:
				return check_if_point_is_valid(i, angle_step, space_state, distance_from_center - 0.2, center_position)
			print('path length %s' % [length_to_path])
			result.position.y += 0.2
			#print(result.position)
			var dot = MeshInstance3D.new()
			var sphere = SphereMesh.new()
			sphere.radius = 0.2
			sphere.height = 0.4
			dot.mesh = sphere
			get_tree().root.add_child(dot)
			dot.global_position = result.position
			circles.append(dot)
			return result
		elif distance_from_center > 0.2:
			return check_if_point_is_valid(i, angle_step, space_state, distance_from_center - 0.2, center_position)
		else:
			return result


func get_collision_array() -> Array:
		shape_cast_3d.force_shapecast_update()
		var collision_count = shape_cast_3d.get_collision_count()
		var collision_array = []
		print('number of collisions %s' % [collision_count])
		for i in range(int(collision_count)):
			var collision_point = shape_cast_3d.get_collision_point(i)
			print('point %s: %s' % [i, collision_point])
			collision_array.append(collision_point)
		return collision_array
	




func draw_line(point_array: Array):
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, material)
	for i in range(len(point_array)):
		immediate_mesh.surface_add_vertex(point_array[i])
	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(0.765, 0.0, 0.322, 1)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	return await final_cleanup(mesh_instance, 1)

func draw_better_mesh(hit_points : Array, center_pos):
	if hit_points.size() < 3:
		mesh = null # Not enough points to make a surface
		return

	var vertices = PackedVector3Array()
	var indices = PackedInt32Array()

	# 1. Add the Center Point (local to the MeshInstance)
	vertices.append(to_local(center_pos))
	
	# 2. Add the Edge Points (converted to local space)
	for p in hit_points:
		vertices.append(to_local(p))

	# 3. Build Triangles (Fan Pattern)
	# Each triangle connects: Center -> Point(i) -> Point(i+1)
	for i in range(1, hit_points.size()):
		indices.append(0)         # Center
		indices.append(i)         # Current point
		indices.append(i + 1)     # Next point
	
	# Close the circle: Connect last point back to the first edge point
	indices.append(0)
	indices.append(hit_points.size())
	indices.append(1)

	# 4. Construct the ArrayMesh
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices

	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	self.mesh = arr_mesh
	
	var mat := ORMMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(0.0, 0.0, 1.0, 0.6)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	set_surface_override_material(0, mat)

	#return await final_cleanup(mesh_instance, 0)


func draw_mesh(point_array: Array, persist_ms: float):
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var mat := ORMMaterial3D.new()
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP, mat)
	for i in range(len(point_array)):
		immediate_mesh.surface_add_vertex(point_array[i])
	immediate_mesh.surface_end()

	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(0.0, 0.0, 1.0, 0.6)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	return await final_cleanup(mesh_instance, persist_ms)


func form_mesh(point_array: Array) -> bool:
	#get length of point_array
	var point_length = len(point_array)
	if point_length < 2:
		print('not enough collisions')
		return false
	elif point_length == 2:
		draw_line(point_array)
		return true
	else:
		draw_mesh(point_array, 100)
		return true
		
	return false
	
## 1 -> Lasts ONLY for current physics frame
## >1 -> Lasts X time duration.
## <1 -> Stays indefinitely
func final_cleanup(mesh_instance, persist_ms: float):
	#var existing = get_tree().get_root().find_children("*", "MeshInstance3D", true, false)
	#for child in existing:
	#	if child.mesh is ImmediateMesh and not child.is_queued_for_deletion():
	#		child.mesh.clear_surfaces()
	#		child.queue_free()
	get_tree().get_root().add_child(mesh_instance)
	if persist_ms == 1:
		await get_tree().physics_frame
		mesh_instance.queue_free()
	elif persist_ms > 0:
		await get_tree().create_timer(persist_ms).timeout
		mesh_instance.queue_free()
	else:
		return mesh_instance
		
		

func create_intersection_mesh(position):
	var space_state = get_world_3d().direct_space_state
	var cylinder = CylinderShape3D.new()
	cylinder.radius = 20.0
	cylinder.height = 20.0
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = cylinder
	# Center the 20-unit high cylinder at Y=0 to cover Y=10 to Y=-10
	query.transform = global_transform 
	query.collision_mask = 1 # Set this to match your target objects' layers
	var points = space_state.collide_shape(query, 100)
	# 3. Process the pairs
	var point_list = []
	for i in range(0, points.size(), 2):
		var point_on_mesh = points[i + 1] # The second point in the pair
		#print("in index %s Contact point on mesh: %s"% [i+1,point_on_mesh])
		point_list.append(point_on_mesh)
	draw_mesh(point_list, 100)



func query_path(p_start_position: Vector3, p_target_position: Vector3, p_navigation_layers: int = 1) -> PackedVector3Array:
	if not is_inside_tree():
		return PackedVector3Array()

	var map: RID = get_world_3d().get_navigation_map()

	if NavigationServer3D.map_get_iteration_id(map) == 0:
		# This map has never synced and is empty, no point in querying it.
		return PackedVector3Array()

	query_parameters.map = map
	query_parameters.start_position = p_start_position
	query_parameters.target_position = p_target_position
	query_parameters.navigation_layers = p_navigation_layers

	NavigationServer3D.query_path(query_parameters, query_result)
	var path: PackedVector3Array = query_result.get_path()

	return path

func get_length_of_path(path : PackedVector3Array, final_position) -> float:
	#print('path length: %s' % [len(path)])
	var x_within = final_position.x > path[-1].x- 0.05 and final_position.x < path[-1].x + 0.05
	var z_within = final_position.z > path[-1].z- 0.05 and final_position.z < path[-1].z + 0.05
	
	var final_position_true = x_within and z_within
	
	#print('\n\nFinal Path Position:%s \n raycast hit position: %s \nis path reachable?: %s' % [path[-1], final_position, final_position_true])
	if final_position_true:
		#print(path)
		var path_length = 0.0
		for i in range(len(path)-1):
			
			var portion_length = path[i].distance_to(path[i+1])
			#print('portion length for part %s: %s' % [i, portion_length])
			path_length = path_length + portion_length
		#print(path_length)
		return path_length
	
	return 10000
