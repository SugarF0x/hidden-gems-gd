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

@export var gem_count: int = 2:
	set(value):
		gem_count = value
		randomize_gem_indexes()
		redraw_grid()

var gem_indexes: Array[int] = []

func _ready() -> void:
	randomize_gem_indexes()
	redraw_grid()
	_editor_on_ready()

func redraw_grid() -> void:
	for child in get_children(): child.queue_free()
	for n in (height * width):
		var item := gem_scene.instantiate() as Gem
		add_child(item)
		item.state = Gem.BackgroundState.FOUND if n in gem_indexes else Gem.BackgroundState.EMPTY

func randomize_gem_indexes() -> void:
	gem_indexes.clear()
	var pool: Array[int] = []
	for i in range(width * height): pool.append(i)
	pool.shuffle()
	gem_indexes = pool.slice(0, gem_count)

func _editor_on_ready() -> void:
	if not Engine.is_editor_hint(): return
	pass
