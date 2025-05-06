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

"""
Returns an array of Vector 2 nodes from the source node to the radius node (Includes source node)
Returns an array of size zero if no path is found
"""
func pathfind(source: Vector2, target: Vector2, radius: int) -> Array[Vector2]:
	var paths: Paths = pathfind_all_cells(source, radius)
	var path: Array[Vector2] = []
	print("max ", paths.parents.size())
	for i in range(paths.cells.size()):
		var cell = paths.cells[i]
		if utils.vector_approx(cell, target):
			path.push_front(cell)
			while paths.parents[i] != -1:
				i = paths.parents[i]
				path.push_front(paths.cells[i])
			return path
	return path


func clear_squares():
	for instance in instance_squares:
		instance.queue_free()
	instance_squares.clear()


func showcase_walls(source: Vector2, radius: int):	
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
	var paths: Paths = pathfind_all_cells(source, radius)
	var reachable: Array[Vector2]

	for r in paths.reachable:
		reachable.push_back(paths.cells[r])
	
	for cell in reachable:
		var local_pos = Vector2(cell.x, cell.y)
		var instance: Node2D = grid_square.instantiate()
		instance.position = local_pos
		instance.z_index = 1
		add_child(instance)
		instance_squares.push_back(instance)
	var end = Time.get_ticks_msec()


"""
Will return a list of all cells in a grid that can be reached from a source
Returns as an array of local coordinates
Dijkstra's algorithm
"""
func pathfind_all_cells(source: Vector2, distance: float) -> Paths:
	var distance_c: int = ceili(distance)
	var source_grid_index = Vector2i(distance_c, distance_c) 
	var top_left: Vector2 = utils.round_to_cell(source) - Vector2(16 * distance_c, 16 * distance_c)
	var width = distance_c * 2 + 1
	var grid: Array[Array] = get_path_grid(top_left, width)
	
	var distance_arr: Array[Array] = []
	var parent_grid: Array[Array] = []
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
		parent_grid.push_back(parent_line)
	
	while not q.empty():
		var u: Vector2i = q.extract()
		var adjacencies: Array[Vector2i] = get_adjacencies(grid, u)
		for adj in adjacencies:
			var weight = (adj - u).length()
			if distance_arr[adj.y][adj.x] > distance_arr[u.y][u.x] + weight + K_ERROR:
				distance_arr[adj.y][adj.x] = distance_arr[u.y][u.x] + weight
				q.insert(adj, distance_arr[adj.y][adj.x])
				parent_grid[adj.y][adj.x] = Vector2i(u.x, u.y)
	
	var reachable_arr: Array[int] = []
	var parent_arr: Array[int] = []
	var cells: Array[Vector2] = []
	var count = 0
	for y in range(width):
		for x in range(width):
			cells.push_back(top_left + Vector2(x * 16, y * 16))
			if distance_arr[y][x] <= distance + K_ERROR:
				reachable_arr.push_back(y * width + x)
			count += 1
			if parent_grid[y][x] != null: 
				var parent: Vector2i = parent_grid[y][x]
				parent_arr.push_back(parent.y * width + parent.x)
			else: 
				parent_arr.push_back(-1)
	return Paths.new(cells, parent_arr, reachable_arr)


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
			else:
				grid_line.push_back(false)
		grid.push_back(grid_line)
	return grid
