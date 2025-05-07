extends Control

class_name BattleMenu

signal move_button_down()

func _ready():
	hide()


func _process(delta):
	pass


func show_menu() -> void:
	show()


func hide_menu() -> void:
	hide()


func _on_move_button_button_down():
	move_button_down.emit()
