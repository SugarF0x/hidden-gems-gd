@tool
extends GridContainer

var gem_scene: PackedScene = load("res://gem.tscn")

@export var width: int = 2:
	set(value):
		columns = value
		width = value
		redraw_grid()

@export var height: int = 3:
	set(value):
		height = value
		redraw_grid()

func _ready():
	if Engine.is_editor_hint(): redraw_grid()

func redraw_grid():
	for child in get_children(): child.queue_free()
	for n in (height * width):
		var item = gem_scene.instantiate()
		add_child(item)
