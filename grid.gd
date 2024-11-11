@tool
class_name GemGrid extends PanelContainer

var gem_scene: PackedScene = load("res://gem.tscn")

@onready var grid_container: GridContainer = $MarginContainer/GridContainer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var width: int = 2:
	set(value):
		width = value
		sync_grid_size()
		redraw_grid()

@export var height: int = 3:
	set(value):
		height = value
		sync_grid_size()
		redraw_grid()

var gems: Array[Gem] = []
@export var correct_gem_indexes: Array[int] = [0, 3]:
	set(value):
		correct_gem_indexes = value
		if Engine.is_editor_hint(): reveal_gems()

signal gem_clicked(index: int)

func _ready() -> void:
	sync_grid_size()
	redraw_grid()
	resized.connect(func(): pivot_offset = get_size() / 2)

func sync_grid_size() -> void:
	if not grid_container: return
	grid_container.columns = width

func redraw_grid() -> void:
	if not grid_container: return
	
	for child in grid_container.get_children(): child.queue_free()
	gems.clear()
	
	for n in (height * width):
		var item := gem_scene.instantiate() as Gem
		grid_container.add_child(item)
		gems.append(item)
		item.gem_clicked.connect(gem_clicked.emit.bind(n))
		
	if Engine.is_editor_hint(): reveal_gems()

func reveal_gems() -> void:
	for index in gems.size(): 
		var gem = gems[index]
		gem.state = Gem.BackgroundState.FOUND if index in correct_gem_indexes else Gem.BackgroundState.EMPTY

func hide_gems() -> void: for gem in gems: gem.state = Gem.BackgroundState.HIDDEN 
func disable_gems() -> void: for gem in gems: gem.disable()
func enable_gems() -> void: for gem in gems: gem.enable()

func call_with_delay(fun: Callable, delay_time: float) -> void:
	await get_tree().create_timer(delay_time).timeout
	fun.call()

func fade(value: bool) -> Signal:
	if (value):
		animation_player.play("fade")
		return animation_player.animation_finished
	
	animation_player.play_backwards("fade")
	
	var gem_animation_pool: Array[Gem] = gems.duplicate()
	gem_animation_pool.shuffle()
	
	for gem_index in gem_animation_pool.size(): 
		var gem: Gem = gem_animation_pool[gem_index]
		gem.set_opacity(0.0)
		call_with_delay(gem.fade.bind(false), .05 * gem_index)
	
	return animation_player.animation_finished

func play_gems_press(value: bool) -> Signal:
	var sig: Signal
	for gem in gems: sig = gem.play_press(value)
	return sig
