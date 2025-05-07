extends Node2D

class_name MainScene

var DEFAULT_ZOOM = 2

var utils = Utils.new()

# child nodes / scenes
var console: Console
var player: Player
var camera: Camera
var ui_layer: UiLayer
var dialogue_box: DialogueBox
var tile_map: TileMapLayers
var battle_menu: BattleMenu
var combat: Combat
var grid

var paths_shown_entity
var hovered_entity
var selected_entity

var is_console_focused = false

func _ready():
	console = find_child("Console")
	player = find_child("Player")
	grid = find_child("Grid")
	camera = find_child("GameCamera")
	ui_layer = find_child("UI_Layer");
	dialogue_box = find_child("DialogueBox")
	tile_map = find_child("TileMapLayers")
	battle_menu = find_child("BattleMenu")
	combat = find_child("Combat")
	
	ui_layer.camera = camera
	camera.zoom_to(DEFAULT_ZOOM)
	ui_layer.zoom_to(DEFAULT_ZOOM)
	paths_shown_entity = null


func _process(delta):
	pass


func set_hovered_enitity(entity):
	hovered_entity = entity


func set_selected_enitity(entity):
	selected_entity = entity


"""
CONSOLE CODE BELOW
"""

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
	elif command == "paths":
		command_paths(arguments)
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


# ######################## 
# Console Commands :
# ########################

# Start a battle
func command_battle(arguments: Array[String]):
	var error_mssg = "usage: battle [-s | --start] [-e | --end]"
	var i = 1
	var start = false
	var end = false
	while i < arguments.size():
		if arguments[i] == "-s" || arguments[i] == "--start":
			start = true
		elif arguments[i] == "-e" || arguments[i] == "--end":
			end = true
		else:
			print_and_error(error_mssg); return;
		i += 1
	if (start and end) or (not start and not end):
		print_and_error(error_mssg); return;
	
	if start:
		grid.set_hidden(false)
		combat.begin_combat(player, tile_map, ui_layer, battle_menu)
		player.commence_battle()
	if end:
		grid.set_hidden(true)
		combat.end_combat()
		player.end_battle()

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
			if i == arguments.size() - 1: print_and_error(errorMssg); return;
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


func command_paths(arguments: Array[String]):
	var error_mssg = "usage: paths [-r <radius: int>] [-c | --clear] [-w | --walls]"
	var radius = null
	var clear = false
	var walls = false
	var i = 1
	while i < arguments.size():
		if arguments[i] == "-r":
			if i == arguments.size() - 1: print_and_error(error_mssg); return;
			if not arguments[i + 1].is_valid_int():
				print_and_error(error_mssg); return;
			radius = arguments[i + 1]
			i += 1
		elif arguments[i] == "-c" || arguments[i] == "--clear":
			clear = true
		elif arguments[i] == "-w" || arguments[i] == "--walls":
			walls = true
		else:
			print_and_error(error_mssg); return;
		i += 1
	
	if (not clear and radius == null) or (clear and radius != null) or (walls and radius == null):
		print_and_error(error_mssg); return;

	if clear:
		tile_map.clear_squares()
	if radius != null:
		tile_map.clear_squares()
		if walls:
			tile_map.showcase_walls(player.position, int(radius))
		else:
			tile_map.showcase_possible_paths(player.position, int(radius))

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


func _on_console_console_focus_change(is_focused):
	is_console_focused = is_focused
