class_name Utils

const K_ERROR = 0.001

"""
Parses a command-line string into an array of arguments, preserving quoted strings as single arguments.
"""
func parse_arguments(command: String) -> Array[String]:
	var args: Array[String] = []
	var regex = RegEx.new()
	# Matches quotations as one argument, otherwise separate by sapce
	regex.compile("(?!\\\\)(\\\".*?[^\\\\]\\\")|(?!\\\\)('.*?[^\\\\]')|\\S+")
	var matches = regex.search_all(command)
	
	for match in matches:
		var arg = match.get_string()
		if (arg.begins_with("\"") and arg.ends_with("\"")) or (arg.begins_with("'") and arg.ends_with("'")):
			arg = arg.substr(1, arg.length() - 2) # Remove surrounding quotes
		arg = arg.replace("\\\"", "\"")
		args.append(arg)
		print(arg)
	
	return args


"""
Given a coordinate, returns the coordinate rounded to the nearest cell center
"""
func round_to_cell(cords: Vector2) -> Vector2:
	return Vector2(
		round((cords.x + 8) / 16) * 16 - 8,
		round((cords.y + 8) / 16) * 16 - 8
	)


"""
Given a global coordinate, will return the coordinate relative to the UI layer
"""
func global_to_ui_position(camera: Camera, viewport: Viewport, cords: Vector2) -> Vector2:
	var relative_pos = cords - camera.global_position
	var center_of_screen = viewport.get_visible_rect().size / 2
	var ui_pos = relative_pos + (center_of_screen / camera.zoom)
	return ui_pos


func float_approx(a: float, b: float) -> bool:
	return abs(a - b) < K_ERROR


func vector_approx(a: Vector2, b: Vector2) -> bool:
	return float_approx(a.x, b.x) and float_approx(a.y, b.y)
