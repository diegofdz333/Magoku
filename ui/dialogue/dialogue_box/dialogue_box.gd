extends Control

class_name DialogueBox

var text_speed = 30 # chars per second
var chars_shown = 0
var last_time

var is_hidden: bool
var name_text: String = ""
var dialogue_text: String = ""

var name_node: RichTextLabel
var dialogue_node: RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	is_hidden = false
	hide()
	name_node = find_child("Name")
	dialogue_node = find_child("Dialogue")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if chars_shown < dialogue_text.length():
		var more_chars = (Time.get_ticks_msec() - last_time) * text_speed / 1000 
		chars_shown += more_chars
		last_time += more_chars * 1000 / text_speed
		dialogue_node.text = dialogue_text.substr(0, chars_shown)


func toggle():
	is_hidden = not is_hidden
	if is_hidden: hide()
	else: show()


func set_hidden(new_is_hidden):
	is_hidden = new_is_hidden
	if is_hidden: hide()
	else: show()


func set_dialogue(new_dialogue: String):
	set_text(name_text, new_dialogue)


func set_text(new_name, new_dialogue):
	chars_shown = 0
	last_time = Time.get_ticks_msec()
	if new_name != null:
		name_text = new_name
		name_node.text = new_name
	if new_dialogue != null:
		dialogue_text = new_dialogue
	
