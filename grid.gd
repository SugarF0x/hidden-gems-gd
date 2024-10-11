@tool
class_name GemGrid
extends PanelContainer

var gem_scene: PackedScene = load("res://gem.tscn")

@onready var grid_container: GridContainer = $MarginContainer/GridContainer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var width: int = 2:
	set(value):
		width = value
		sync_grid_size()
		randomize_gem_indexes()
		redraw_grid()

@export var height: int = 3:
	set(value):
		height = value
		sync_grid_size()
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
	sync_grid_size()
	start()
	resized.connect(func(): pivot_offset = get_size() / 2)

func sync_grid_size() -> void:
	if not grid_container: return
	grid_container.columns = width

func redraw_grid() -> void:
	if not grid_container: return
	
	for child in grid_container.get_children(): child.queue_free()
	gem_children.clear()
	
	for n in (height * width):
		var item := gem_scene.instantiate() as Gem
		grid_container.add_child(item)
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
	#set_gem_processing(index, false)
	
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
	
	fade(true)
	reveal_gems()
	await get_tree().create_timer(2.0).timeout
	await play_gems_press(true)
	hide_gems()
	await play_gems_press(false)

# TODO: a lot of this logic is to be moved out into a parent script that would also have control over instructions and hud along with this

func on_round_end() -> void:
	for index in gem_children.size():
		var gem = gem_children[index]
		#if gem.process_mode == Node.PROCESS_MODE_DISABLED: continue
		if index not in gem_indexes: continue
		if gem.state == Gem.BackgroundState.HIDDEN: gem.state = Gem.BackgroundState.MISSED if index in gem_indexes else Gem.BackgroundState.EMPTY
	
	await get_tree().create_timer(2.0).timeout
	await fade(false)
	hide_gems()
	start()

func call_with_delay(fun: Callable, delay_time: float) -> void:
	await get_tree().create_timer(delay_time).timeout
	fun.call()

func fade(value: bool) -> Signal:
	if (not value):
		animation_player.play_backwards("fade")
		return animation_player.animation_finished
	
	animation_player.play("fade")
	
	var gem_animation_pool = gem_children.duplicate()
	gem_animation_pool.shuffle()
	
	for gem_index in gem_animation_pool.size(): 
		var gem = gem_animation_pool[gem_index] as Gem
		gem.set_opacity(0.0)
		call_with_delay(gem.fade.bind(true), .05 * gem_index)
	
	return animation_player.animation_finished

func play_gems_press(value: bool) -> Signal:
	var sig: Signal
	for gem in gem_children: sig = gem.play_press(value)
	return sig
