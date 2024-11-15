@tool
class_name GemGrid extends Control

#region static

var gem_scene: PackedScene = preload("res://gem.tscn")

enum RevealType {
	NONE,
	ALL,
	SELECTED,
	SELECTED_AND_CORRECT,
}

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var panel: PanelContainer = $Panel
@onready var margin_container: MarginContainer = $Panel/MarginContainer
@onready var grid_container: GridContainer = $Panel/MarginContainer/GridContainer

#endregion
#region properties

@export var grid_size: Vector2i = Vector2i(2,3) : set = set_grid_size
@export var reveal_type: RevealType = RevealType.ALL : set = set_reveal_type
@export var correct_gem_indexes: Array[int] = [0, 3] : set = set_correct_gem_indexes
@export var selected_gem_indexes: Array[int] = [] : set = set_selected_gem_indexes

var tile_size: int = Gem.max_tile_size : set = set_tile_size

func set_grid_size(value: Vector2i) -> void:
	grid_size = value
	update_nodes()

func set_reveal_type(value: RevealType) -> void:
	reveal_type = value
	update_gem_reveal_state()

func set_correct_gem_indexes(value: Array[int]) -> void:
	correct_gem_indexes = value
	update_gem_reveal_state()

func set_selected_gem_indexes(value: Array[int]) -> void:
	selected_gem_indexes = value
	update_gem_reveal_state()

func set_tile_size(value: int) -> void:
	tile_size = min(Gem.max_tile_size, value)
	for gem in gems: gem.tile_size = tile_size

#endregion

var gems: Array[Gem] = []
signal gem_clicked(index: int)

func _ready() -> void:
	update_nodes.call_deferred()
	panel.resized.connect(func(): panel.pivot_offset = panel.size / 2)

func update_nodes() -> void:
	update_grid_columns_count()
	update_tile_size()
	redraw_grid()
	update_gem_reveal_state()

func update_grid_columns_count() -> void:
	if not is_node_ready(): return
	grid_container.columns = grid_size.x

func update_tile_size() -> void:
	if not is_node_ready(): return
	var gap = grid_container.get_theme_constant('h_separation')
	var margin = margin_container.get_theme_constant('margin_left') + margin_container.get_theme_constant('margin_right')
	var free_space = size.x - margin - gap * (grid_size.x - 1)
	tile_size = free_space / grid_size.x

func update_gem_reveal_state() -> void:
	for index in gems.size(): 
		var gem = gems[index]
		
		match reveal_type:
			RevealType.NONE: gem.state = Gem.GemState.HIDDEN
			RevealType.ALL: gem.state = Gem.GemState.FOUND if index in correct_gem_indexes else Gem.GemState.EMPTY
			RevealType.SELECTED: 
				if index not in selected_gem_indexes: gem.state = Gem.GemState.HIDDEN
				elif index in correct_gem_indexes: gem.state = Gem.GemState.FOUND
				else: gem.state = Gem.GemState.WRONG
			RevealType.SELECTED_AND_CORRECT: 
				if index in selected_gem_indexes: 
					if index in correct_gem_indexes: gem.state = Gem.GemState.FOUND
					else: gem.state = Gem.GemState.WRONG
				elif index in correct_gem_indexes: gem.state = Gem.GemState.MISSED
				else: gem.state = Gem.GemState.HIDDEN

func redraw_grid() -> void:
	if not is_node_ready(): return
	
	for child in grid_container.get_children(): child.queue_free()
	gems.clear()
	
	for n in (grid_size.x * grid_size.y):
		var item = gem_scene.instantiate() as Gem
		grid_container.add_child(item)
		gems.append(item)
		
		item.gem_clicked.connect(gem_clicked.emit.bind(n))
		item.tile_size = tile_size
		item.randomize_icon()

func disable_gems() -> void: for gem in gems: gem.disable()
func enable_gems() -> void: for gem in gems: gem.enable()

func call_with_delay(fun: Callable, delay_time: float) -> void:
	await get_tree().create_timer(delay_time).timeout
	fun.call()

func instnant_fade() -> void:
	animation_player.play("fade")
	animation_player.seek(animation_player.current_animation_length)
	animation_player.stop()

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
