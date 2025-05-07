extends Node2D

class_name Combat

var utils = Utils.new()

var player: Player
var tile_map: TileMapLayers
var ui_layer: UiLayer
var battle_menu: BattleMenu

var paths_shown_entity
var hovered_entity
var selected_entity

var is_console_focused = false
var is_in_combat = false

func _process(delta):
	if is_in_combat and not is_console_focused:
		process_battle(delta)


func begin_combat(player: Player, tile_map: TileMapLayers, ui_layer: UiLayer, 
				 battle_menu: BattleMenu) -> void:
	self.player = player
	self.tile_map = tile_map
	self.ui_layer = ui_layer
	self.battle_menu = battle_menu
	
	is_in_combat = true


func end_combat() -> void:
	is_in_combat = false


func process_battle(_delta) -> void:	
	var mouse_cell_pos: Vector2 = utils.round_to_cell(get_global_mouse_position())
	var player_pos = player.get_cell_position()
	hovered_entity = null
		
	if player_pos != null and utils.vector_approx(mouse_cell_pos, player_pos):
		hovered_entity = player
	
	var previously_selected = selected_entity
	if Input.is_action_just_released("select"):
		selected_entity = hovered_entity
		if selected_entity == player:
			ui_layer.anchor_element_to(battle_menu, player)
			battle_menu.show_menu()
	
	if previously_selected != selected_entity and previously_selected == player:
		var path: Array[Vector2] = tile_map.pathfind(player_pos, mouse_cell_pos, 6)
		if path.size() > 0:
			player.move_through_path(path)
	
	if selected_entity == null and hovered_entity == null and paths_shown_entity != null:
		tile_map.clear_squares()
		paths_shown_entity = null
		
	if selected_entity != null:
		if paths_shown_entity != selected_entity:
			paths_shown_entity = selected_entity
			if selected_entity == player:
				tile_map.showcase_possible_paths(player_pos, 6)
	elif hovered_entity != null:
		if paths_shown_entity != hovered_entity:
			paths_shown_entity = hovered_entity
			if hovered_entity == player:
				tile_map.showcase_possible_paths(player_pos, 6)


func _on_battle_menu_move_button_down():
	pass # Replace with function body.


func _on_console_console_focus_change(is_focused):
	is_console_focused = is_focused
