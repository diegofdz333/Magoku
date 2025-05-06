extends CanvasLayer

class_name UiLayer

var camera: Camera
var anchored_elements: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for element in anchored_elements:
		var anchor: Node2D = anchored_elements[element]
		element.position = global_to_ui_position(anchor.global_position)


func zoom_to(zoom) -> void:
	for child in get_children():
		if child is not Console:
			child.scale = Vector2(zoom, zoom)


func anchor_element_to(element: Control, anchor: Node2D) -> void:
	anchored_elements[element] = anchor


func remove_anchor(element: Control) -> void:
	anchored_elements.erase(element);

"""
Given a global coordinate, will return the coordinate relative to the UI layer
"""
func global_to_ui_position(cords: Vector2) -> Vector2:
	if not camera:
		print("ERROR: Camera not defined in UI")
		return Vector2(0, 0)
	var viewport = get_viewport()
	var relative_pos = cords - camera.global_position
	var center_of_screen = viewport.get_visible_rect().size / 2
	var ui_pos = relative_pos + center_of_screen
	return ui_pos
