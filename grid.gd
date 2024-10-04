@tool
extends GridContainer

@export var height: int = 2:
	set(value):
		height = value
		redraw_grid()
	
@export var width: int = 2:
	set(value):
		columns = value
		width = value
		redraw_grid()

func _ready():
	if Engine.is_editor_hint(): redraw_grid()

func redraw_grid():
	for child in get_children(): child.queue_free()
	for n in (height * width):
		var item := Panel.new()
		item.custom_minimum_size = Vector2(50, 50)
		add_child(item)
