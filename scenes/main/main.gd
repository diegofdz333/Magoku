extends Node

var DEFAULT_ZOOM = 2

var console: Console
var player: Player
var camera: Camera
var ui_layer: CanvasLayer
var dialogue_box: DialogueBox
var grid

var utils

func _ready():
	utils = preload("res://utils/utils.gd").new()
	console = find_child("Console")
	player = find_child("Player")
	grid = find_child("Grid")
	camera = find_child("GameCamera")
	ui_layer = find_child("UI_Layer")
	dialogue_box = find_child("DialogueBox")
	camera.zoom_to(DEFAULT_ZOOM)
	ui_layer.zoom_to(DEFAULT_ZOOM)

func _on_console_console_command(cmmd):
	command_parser(cmmd)

func command_parser(cmmd: String):
	var arguments =  utils.parse_arguments(cmmd)
	if arguments.size() == 0 || arguments[0] == "":
		return;
		
	var command = arguments[0].to_lower()
	
	if command == "battle":
		command_battle(arguments)
	elif command == "clear":
		command_clear(arguments)
	elif command == "dialogue":
		command_dialogue(arguments)
	elif command == "hello":
		print_and_respond("Hello, World!")
	elif command == "speed":
		command_speed(arguments)
	elif command == "grid":
		command_grid(arguments)
	elif command == "zoom":
		command_zoom(arguments)
	else:
		print_and_error("\"%s\" is not a valid command" % command)


func print_and_respond(str):
	print(str)
	console.console_response(str)


func print_and_error(str):
	var error = console.RESPONSE_TYPE.ERROR
	print_rich("[color=red]%s[/color]" % str)
	console.console_response(str, error)

# Console Commands :

# Start a battle
func command_battle(_arguments: Array[String]):
	grid.set_hidden(false)
	player.commence_battle()

# Clear the console of all text
func command_clear(_arguments: Array[String]):
	console.clear()


func command_dialogue(arguments: Array[String]):
	var errorMssg = "usage: dialogue [-n | --name <text>] [-d | --dialogue <text>] [-s | --show] [-h | --hide]"
	var name_text = null
	var dialogue_text = null
	var hide = false
	var show = false
	
	var i = 1
	while i < arguments.size():
		print(i)
		if arguments[i] == "-n" || arguments[i] == "--name":
			print("A")
			if i == arguments.size() - 1: print_and_error(errorMssg); return;
			print("B")
			name_text = arguments[i + 1]
			i += 1
		elif arguments[i] == "-d" || arguments[i] == "--dialogue":
			if i == arguments.size() - 1: print_and_error(errorMssg); return;
			dialogue_text = arguments[i + 1]
			i += 1
		elif arguments[i] == "-s" || arguments[i] == "--show":
			show = true
		elif arguments[i] == "-h" || arguments[i] == "--hide":
			hide = true
		else:
			print_and_error(errorMssg); return;
		i += 1
	
	var all_null: bool = name_text == null and dialogue_text == null and not hide and not show
	var show_and_hide: bool = show and hide
	if all_null or show_and_hide:
		print_and_error(errorMssg); return;
	if name_text or dialogue_text:
		dialogue_box.set_text(name_text, dialogue_text)
	if show or name_text or dialogue_text:
		dialogue_box.set_hidden(false)
	if hide:
		dialogue_box.set_hidden(true)
	
# Change player speed
func command_speed(arguments: Array[String]):
	if arguments.size() != 2 or not arguments[1].is_valid_float(): 
		print_and_error("usage: speed [multiplier]");
		return
	player.speed = player.MAX_SPEED * float(arguments[1])


func command_grid(_arguments: Array[String]):
	grid.toggle()


func command_zoom(arguments: Array[String]):
	var errorMssg = "usage: zoom [-u | --ui] [-s | --screen] [-a | --all] <multiplier>"
	if arguments.size() == 2:
		if not arguments[1].is_valid_float():
			print_and_error(errorMssg)
			return
		camera.zoom_to(float(arguments[1]))
	elif arguments.size() == 3:
		if not arguments[2].is_valid_float():
			print_and_error(errorMssg)
			return
		if arguments[1] == "-u" || arguments[1] == "--ui":
			ui_layer.zoom_to(float(arguments[2]))
		elif arguments[1] == "-s" || arguments[1] == "--screen":
			camera.zoom_to(float(arguments[2]))
		elif arguments[1] == "-a" || arguments[1] == "--all":
			camera.zoom_to(float(arguments[2]))
			ui_layer.zoom_to(float(arguments[2]))
		else:
			print_and_error(errorMssg)
	else:
		print_and_error(errorMssg)
