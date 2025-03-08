extends Sprite2D

var is_hidden

# Called when the node enters the scene tree for the first time.
func _ready():
	is_hidden = true
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player_nodes = get_tree().get_nodes_in_group("player")
	if player_nodes.size() > 0:
		var player = player_nodes[0] as Node2D
		var player_pos: Vector2 = player.global_position
		var grid_pos = Vector2(round(player_pos.x / 16) * 16, round(player_pos.y / 16) * 16 - 8)
		global_position = grid_pos


func toggle():
	is_hidden = not is_hidden
	if is_hidden: hide()
	else: show()


func set_hidden(new_is_hidden):
	is_hidden = new_is_hidden
	if is_hidden: hide()
	else: show()
