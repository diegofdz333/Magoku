class_name Paths

var cells: Array[Vector2]
var parents: Array[int]
var reachable: Array[int]

func _init(cells: Array[Vector2], parents: Array[int], reachable: Array[int]):
	self.cells = cells
	self.parents = parents
	self.reachable = reachable
