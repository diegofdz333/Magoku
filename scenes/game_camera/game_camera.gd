extends Camera2D

class_name Camera

# Called when the node enters the scene tree for the first time.
func _ready():
	make_current()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var player_nodes = get_tree().get_nodes_in_group("player")
	if player_nodes.size() > 0:
		var player = player_nodes[0] as Node2D
		global_position = player.global_position


func zoom_to(zoom_mult: float):
	zoom = Vector2(zoom_mult, zoom_mult)
