extends Control

class_name Console

signal console_focus_change(is_focused: bool)
signal console_command(cmmd: String)

enum RESPONSE_TYPE {SUCCESS, ERROR}

var console_hidden = true
var input_focus = false

var command_memory: Array[String]
var memory_index = -1

func _ready():
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var toggledConsole = Input.is_action_just_pressed("toggle_console")
	if toggledConsole:
		console_hidden = not console_hidden
		if console_hidden:
			hide()
		else:
			show()
	var last_command = Input.is_action_just_pressed("last_command")
	var next_command = Input.is_action_just_pressed("next_command")
	if last_command:
		memory_index += 1 if memory_index + 1 < command_memory.size() else 0
		update_input_text_from_memory(memory_index)
	
	if next_command:
		memory_index -= 1 if memory_index > 0 else 0
		update_input_text_from_memory(memory_index)

func update_input_text_from_memory(memory_index):
	var input_text: LineEdit = $Input/InputText
	if memory_index >= 0:
		input_text.text = command_memory[memory_index]
		input_text.caret_column = input_text.text.length()

func run_command(cmmd: String):
	var output_text = $Output/OutputScroll/OutputText
	var scroll_container = $Output/OutputScroll
	output_text.add_line("> " + cmmd)
	if command_memory.size() == 0 or command_memory[0] != cmmd:
		command_memory.push_front(cmmd)
	scroll_container.set_scroll(-1)
	console_command.emit(cmmd)


func clear():
	$Output/OutputScroll/OutputText.text = ""


func console_response(response: String, type: RESPONSE_TYPE = RESPONSE_TYPE.SUCCESS):
	if type == RESPONSE_TYPE.SUCCESS:
		$Output/OutputScroll/OutputText.add_line(response)
	elif type == RESPONSE_TYPE.ERROR:
		$Output/OutputScroll/OutputText.add_error_line(response)
	else:
		print_rich("[color=red]ERROR: response type not found[/color]")


func _on_input_text_focus_entered():
	input_focus = true
	console_focus_change.emit(true)


func _on_input_text_focus_exited():
	input_focus = false
	console_focus_change.emit(false)


# Called when a command is inputted into console
func _on_input_text_text_submitted(cmmd):
	run_command(cmmd)


func _on_input_text_text_changed(_new_text):
	memory_index = -1
