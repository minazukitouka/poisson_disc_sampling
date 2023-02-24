extends Resource

# input
var bound: PackedVector2Array
var radius: float
var k := 10
var max_points := -1

# internal
var grid_size: float
var grid := {}
var active_points: PackedVector2Array = []
var inactive_points: PackedVector2Array = []

func generate() -> PackedVector2Array:
	grid_size = radius / sqrt(2)
	add_first_point()
	while active_points.size() > 0 && (max_points == -1 || inactive_points.size() < max_points):
		add_next_point()
	return inactive_points

func add_first_point() -> void:
	var min_x := INF
	var max_x := -INF
	var min_y := INF
	var max_y := -INF
	for vertex in bound:
		if vertex.x < min_x:
			min_x = vertex.x
		if vertex.x > max_x:
			max_x = vertex.x
		if vertex.y < min_y:
			min_y = vertex.y
		if vertex.y > max_y:
			max_y = vertex.y
	while true:
		var point := Vector2(
			randf_range(min_x, max_y),
			randf_range(min_y, max_y)
		)
		if Geometry2D.is_point_in_polygon(point, bound):
			add_active_point(point)
			return

func add_next_point() -> void:
	# pick random point from active points
	var picked_point_index := randi() % active_points.size()
	var picked_point := active_points[picked_point_index]
	for i in range(k):
		var point := create_random_point_near_picked_point(picked_point)
		if !Geometry2D.is_point_in_polygon(point, bound):
			continue
		if is_point_too_close_to_any_neighbor(point):
			continue
		add_active_point(point)
		return
	# remove picked point from active points to inactive points
	active_points.remove_at(picked_point_index)
	inactive_points.append(picked_point)

func get_grid_position(point: Vector2) -> Vector2i:
	return Vector2i(
		int(point.x / grid_size),
		int(point.y / grid_size)
	)

func add_active_point(point: Vector2) -> void:
	active_points.append(point)
	grid[get_grid_position(point)] = point

func create_random_point_near_picked_point(picked_point: Vector2) -> Vector2:
	var length := radius + randf_range(0, radius)
	var angle := randf_range(0, TAU)
	return picked_point + Vector2(length, 0).rotated(angle)

func is_point_too_close_to_any_neighbor(point: Vector2) -> bool:
	var grid_position := get_grid_position(point)
	for dx in range(-2, 3):
		for dy in range(-2, 3):
			var neighbor_grid_position := grid_position + Vector2i(dx, dy)
			if grid.has(neighbor_grid_position):
				var distance := point.distance_to(grid[neighbor_grid_position])
				if distance <= radius:
					return true
	return false
