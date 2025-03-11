extends CharacterBody2D

class_name Player

@onready var animations = $AnimationPlayer

const MAX_SPEED = 50
var speed = MAX_SPEED

var sprite_direction = "down"
var can_move

const TARGET_POSITION_BUFFER = 1
var target_position = Vector2.ZERO
var is_moving_to_target_position = false

var utils = preload("res://utils/utils.gd").new()

# Called when the node enters the scene tree for the first time.
func _ready():
	can_move = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var movement_vector = Vector2.ZERO
	if not is_moving_to_target_position and can_move:
		movement_vector = get_movement_vector()
	elif is_moving_to_target_position:
		movement_vector = target_position - global_position
	
	# If close enough to target just snap to it
	if is_moving_to_target_position and movement_vector.length() < TARGET_POSITION_BUFFER:
		global_position = target_position
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
		if (abs(x_movement) > abs(y_movement)):
			sprite_direction = "right" if x_movement > 0 else "left"
		else:
			sprite_direction = "down" if y_movement > 0 else "up"
	return Vector2(x_movement, y_movement)


func update_animation():
	if (velocity.length() > 0):
		animations.play("walking_" + sprite_direction)
	else:
		animations.play("idle_" + sprite_direction)


func commence_battle():
	# Snap to nearest square
	target_position = utils.round_to_cell(global_position)
	is_moving_to_target_position = true


func _on_console_console_focus_change(is_focused):
	can_move = not is_focused
	velocity = Vector2.ZERO
