extends ScrollContainer

var scrollbar: VScrollBar

var target_scroll = 0
var goto_target = false

# Called when the node enters the scene tree for the first time.
func _ready():
	scrollbar = self.get_v_scroll_bar();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if goto_target:
		scroll_vertical = scrollbar.max_value if target_scroll < 0 else target_scroll
		goto_target = false


func set_scroll(scroll):
	target_scroll = scroll
	goto_target = true
