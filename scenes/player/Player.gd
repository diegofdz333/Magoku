extends CharacterBody2D

class_name Player

@onready var animations = $AnimationPlayer

const MAX_SPEED = 50
var speed = MAX_SPEED

var sprite_direction = "down"
var is_console_open = false
var is_in_battle = false

const TARGET_POSITION_BUFFER = 1
var target_paths_index = 0
var target_paths: Array[Vector2]
var is_moving_to_target_position = false

var utils = Utils.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var movement_vector = Vector2.ZERO
	var can_move = not is_moving_to_target_position and not is_console_open and not is_in_battle
	if can_move:
		movement_vector = get_movement_vector()
	elif is_moving_to_target_position:
		var target_position = target_paths[target_paths_index]
		movement_vector = target_position - global_position
		sprite_direction = get_sprite_direction(movement_vector)
	
	# If close enough to target just snap to it
	if is_moving_to_target_position and movement_vector.length() < TARGET_POSITION_BUFFER:
		global_position = target_paths[target_paths_index]
		target_paths_index += 1
		if target_paths_index >= target_paths.size():
			is_moving_to_target_position = false
			movement_vector = Vector2.ZERO
	
	var direction = movement_vector.normalized()
	velocity = direction * speed
	move_and_slide()
	update_animation()


func get_movement_vector():
	var x_movement = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y_movement = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	if (abs(x_movement) + abs(y_movement) > 0):
		sprite_direction = get_sprite_direction(Vector2(x_movement, y_movement))
	return Vector2(x_movement, y_movement)


func get_sprite_direction(movement_vec: Vector2):
	if (abs(movement_vec.x) > abs(movement_vec.y)):
		return "right" if movement_vec.x > 0 else "left"
	return "down" if movement_vec.y > 0 else "up"

func update_animation():
	if (velocity.length() > 0):
		animations.play("walking_" + sprite_direction)
	else:
		animations.play("idle_" + sprite_direction)


func move_through_path(path):
	target_paths = path
	target_paths_index = 0
	is_moving_to_target_position = true


"""
Returns the position of the player by the cell they are currently in
Returns null if the player is not "locked into" a cell
TODO: change is_in_battle to a more generic is_locked_in
"""
func get_cell_position():
	if not is_in_battle or is_moving_to_target_position:
		return null
	return utils.round_to_cell(global_position)


func commence_battle():
	# Snap to nearest square
	target_paths = [utils.round_to_cell(global_position)]
	target_paths_index = 0
	is_moving_to_target_position = true
	is_in_battle = true


func end_battle():
	is_in_battle = false


func _on_console_console_focus_change(is_focused):
	is_console_open = is_focused
	velocity = Vector2.ZERO
