@tool
class_name GemGrid extends PanelContainer

# TODO: expand size upto a certain maximum, get size, get size for each gem, assign size to gems

#region static

var gem_scene: PackedScene = preload("res://gem.tscn")

@onready var grid_container: GridContainer = $MarginContainer/GridContainer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

#endregion
#region properties

@export var grid_size: Vector2i = Vector2i(2,3) : set = set_grid_size
@export var gems_revealed: bool = false : set = set_gems_revealed
@export var correct_gem_indexes: Array[int] = [0, 3] : set = set_correct_gem_indexes

func set_grid_size(value: Vector2i) -> void:
	grid_size = value
	update_grid_columns_count()
	redraw_grid()

func set_gems_revealed(value: bool) -> void:
	gems_revealed = value
	if Engine.is_editor_hint(): reveal_gems(value)

func set_correct_gem_indexes(value: Array[int]) -> void:
		correct_gem_indexes = value
		if Engine.is_editor_hint(): reveal_gems(gems_revealed)

#endregion

var gems: Array[Gem] = []
signal gem_clicked(index: int)

func _ready() -> void:
	update_grid_columns_count()
	redraw_grid()
	resized.connect(func(): pivot_offset = get_size() / 2)

func update_grid_columns_count() -> void:
	if not is_node_ready(): return
	grid_container.columns = grid_size.x

func redraw_grid() -> void:
	if not is_node_ready(): return
	
	for child in grid_container.get_children(): child.queue_free()
	gems.clear()
	
	for n in (grid_size.x * grid_size.y):
		var item = gem_scene.instantiate() as Gem
		grid_container.add_child(item)
		gems.append(item)
		
		item.gem_clicked.connect(gem_clicked.emit.bind(n))
		item.randomize_icon()
		
	if Engine.is_editor_hint(): reveal_gems(gems_revealed)

func reveal_gems(value: bool = true) -> void:
	for index in gems.size(): 
		var gem = gems[index]
		if value: gem.state = Gem.BackgroundState.FOUND if index in correct_gem_indexes else Gem.BackgroundState.EMPTY
		else: gem.state = Gem.BackgroundState.HIDDEN

func hide_gems() -> void: reveal_gems(false)
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
