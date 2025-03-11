extends Node2D

class_name TileMapLayers

@export var grid_square: PackedScene

const MAX_DISTANCE: float = 99999999
const K_ERROR: float = 0.01

var instance_squares: Array[Node2D]

var wall_layer: TileMapLayer

var utils = preload("res://utils/utils.gd").new()


func _ready():
	wall_layer = $Wall


func pathfind(source: Vector2, target: Vector2):
	pass


func clear_squares():
	for instance in instance_squares:
		instance.queue_free()
	instance_squares.clear()


func showcase_walls(source: Vector2, radius: int):
	print("showcase possible walls")
	
	var top_left = utils.round_to_cell(source) - Vector2(16 * radius, 16 * radius)
	var source_grid_index = Vector2i(radius, radius) 
	
	var grid = get_path_grid(top_left, radius * 2)
	for y in range(0, radius * 2):
		for x in range(0, radius * 2):
			var local_pos = top_left + Vector2(x * 16, y * 16)
			if not grid[y][x] and (local_pos - source).length() <= radius * 16:
				var instance: Node2D = grid_square.instantiate()
				instance.position = local_pos
				instance.z_index = 1
				add_child(instance)
				instance_squares.push_back(instance)


func showcase_possible_paths(source: Vector2, radius: int):
	print("showcase possible paths")
	var start = Time.get_ticks_msec()
	print("time start: " + str(start))
	var top_left: Vector2 = utils.round_to_cell(source) - Vector2(16 * radius, 16 * radius)
	var reachable_cells = pathfind_all_cells(source, radius)
	
	for cell in reachable_cells:
		var local_pos = top_left + Vector2(cell.x * 16, cell.y * 16)
		var instance: Node2D = grid_square.instantiate()
		instance.position = local_pos
		instance.z_index = 1
		add_child(instance)
		instance_squares.push_back(instance)
	var end = Time.get_ticks_msec()
	print("time end: " + str(end))
	print("diff: " + str(end - start))

"""
Will return a list of all cells in a grid that can be reached from a source
"""
func pathfind_all_cells(source: Vector2, distance: float):
	var distance_c: int = ceili(distance)
	var source_grid_index = Vector2i(distance_c, distance_c) 
	var top_left: Vector2 = utils.round_to_cell(source) - Vector2(16 * distance_c, 16 * distance_c)
	var width = distance_c * 2
	var grid: Array[Array] = get_path_grid(top_left, width)
	
	var distance_arr: Array[Array] = []
	var parent_arr: Array[Array] = []
	var q = PriorityQueue.new()
	for y in range(width):
		var distance_line = []
		var parent_line = []
		for x in range(width):
			parent_line.push_back(null)
			if y == source_grid_index.y and x == source_grid_index.x:
				distance_line.push_back(0)
				q.insert(Vector2i(x, y), 0)
			else:
				distance_line.push_back(MAX_DISTANCE)
		distance_arr.push_back(distance_line)
		parent_arr.push_back(parent_line)
	
	while not q.empty():
		var u: Vector2i = q.extract()
		var adjacencies: Array[Vector2i] = get_adjacencies(grid, u)
		for adj in adjacencies:
			var weight = (adj - u).length()
			if distance_arr[adj.y][adj.x] > distance_arr[u.y][u.x] + weight + K_ERROR:
				distance_arr[adj.y][adj.x] = distance_arr[u.y][u.x] + weight
				q.insert(adj, distance_arr[adj.y][adj.x])
				parent_arr[adj.y][adj.x] = Vector2i(u.y, u.x)
	
	var reachable_arr: Array[Vector2i] = []
	for y in range(width):
		for x in range(width):
			if distance_arr[y][x] <= distance + K_ERROR:
				reachable_arr.push_back(Vector2i(x, y))
	return reachable_arr


func get_adjacencies(grid: Array[Array], u: Vector2i) -> Array[Vector2i]:
	var width = grid.size()
	var adj: Array[Vector2i] = []
	var up    = u.y > 0 and (grid[u.y-1][u.x] == false)
	var down  = u.y < width - 1 and (grid[u.y+1][u.x] == false)
	var left  = u.x > 0 and (grid[u.y][u.x-1] == false)
	var right = u.x < width - 1 and (grid[u.y][u.x+1] == false)
	if up:
		adj.push_back(Vector2i(u.x, u.y-1))
	if down:
		adj.push_back(Vector2i(u.x, u.y+1))
	if left:
		adj.push_back(Vector2i(u.x-1, u.y))
	if right:
		adj.push_back(Vector2i(u.x+1, u.y))
	""" diagonals`
	if down and right and (grid[u.x+1][u.y+1] == false):
		adj.push_back(Vector2i(u.x+1, u.y+1))
	if down and left and (grid[u.x-1][u.y+1] == false):
		adj.push_back(Vector2i(u.x-1, u.y+1))
	if up and right and (grid[u.x+1][u.y-1] == false):
		adj.push_back(Vector2i(u.x+1, u.y-1))
	if up and left and (grid[u.x-1][u.y-1] == false):
		adj.push_back(Vector2i(u.x-1, u.y-1))
	"""
	return adj


func get_path_grid(top_left: Vector2, length: int) -> Array[Array]:
	var grid: Array[Array] = []
	for y in range(0, length):
		var grid_line: Array[bool] = []
		for x in range(0, length):
			var local_cors: Vector2 = top_left + Vector2(x * 16, y * 16)
			var map_cords: Vector2i = wall_layer.local_to_map(local_cors)
			if wall_layer.get_cell_tile_data(map_cords) != null:
				grid_line.push_back(true)
				print(local_cors, map_cords)
			else:
				grid_line.push_back(false)
		grid.push_back(grid_line)
	return grid
