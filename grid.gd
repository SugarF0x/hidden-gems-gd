@tool
class_name GemGrid
extends GridContainer

var gem_scene: PackedScene = load("res://gem.tscn")

@export var width: int = 2:
	set(value):
		columns = value
		width = value
		randomize_gem_indexes()
		redraw_grid()

@export var height: int = 3:
	set(value):
		height = value
		randomize_gem_indexes()
		redraw_grid()

@export var gem_count: int = 2:
	set(value):
		gem_count = value
		randomize_gem_indexes()
		redraw_grid()

var gem_children: Array[Gem] = []
var gem_indexes: Array[int] = []

func _ready() -> void:
	start()

func redraw_grid() -> void:
	for child in get_children(): child.queue_free()
	gem_children.clear()
	
	for n in (height * width):
		var item := gem_scene.instantiate() as Gem
		add_child(item)
		gem_children.append(item)
		item.gem_clicked.connect(on_gem_clicked.bind(n))
		
	if Engine.is_editor_hint(): reveal_gems()

func randomize_gem_indexes() -> void:
	gem_indexes.clear()
	var pool: Array[int] = []
	for i in range(width * height): pool.append(i)
	pool.shuffle()
	gem_indexes = pool.slice(0, gem_count)

var gems_user_revealed: int = 0
func on_gem_clicked(index: int) -> void:
	gems_user_revealed += 1
	var gem = gem_children[index]
	gem.state = Gem.BackgroundState.FOUND if index in gem_indexes else Gem.BackgroundState.WRONG
	set_gem_processing(index, false)
	
	if gems_user_revealed >= gem_count: 
		gems_user_revealed = 0
		on_round_end()

func reveal_gems() -> void:
	for index in gem_children.size(): 
		var gem = gem_children[index] as Gem
		gem.state = Gem.BackgroundState.FOUND if index in gem_indexes else Gem.BackgroundState.EMPTY

func hide_gems() -> void:
	for gem in gem_children as Array[Gem]: gem.state = Gem.BackgroundState.HIDDEN

func start() -> void:
	randomize_gem_indexes()
	redraw_grid()
	if Engine.is_editor_hint(): return
	
	reveal_gems()
	for index in gem_children.size(): set_gem_processing(index, false)
	await get_tree().create_timer(2.0).timeout
	for index in gem_children.size(): set_gem_processing(index, true)
	hide_gems()

func set_gem_processing(index: int, value: bool) -> void:
	gem_children[index].process_mode = Node.PROCESS_MODE_INHERIT if value else Node.PROCESS_MODE_DISABLED

# TODO: a lot of this logic is to be moved out into a parent script that would also have control over instructions and hud along with this

func on_round_end() -> void:
	for index in get_child_count():
		var gem = get_child(index) as Gem
		if gem.process_mode == Node.PROCESS_MODE_DISABLED: continue
		if index not in gem_indexes: continue
		if gem.state == Gem.BackgroundState.HIDDEN: gem.state = Gem.BackgroundState.MISSED if index in gem_indexes else Gem.BackgroundState.EMPTY
		set_gem_processing(index, false)
	
	await get_tree().create_timer(2.0).timeout
	hide_gems()
	await get_tree().create_timer(.5).timeout
	redraw_grid()
	start()
