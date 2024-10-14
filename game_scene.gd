@tool
extends MarginContainer

@onready var hud: Hud = $Container/Hud
@onready var instructions: Instructions = $Container/Instructions
@onready var grid: GemGrid = $Container/Grid

var gem_count: int = 3

func _ready() -> void:
	setup()

func set_starting_node_properties():
	grid.modulate.a = 0
	instructions.position = instructions_out_of_bounds_position
	hud.position = hud_out_of_bounds_position

func setup() -> void:
	call_deferred('setup_layout')
	grid.gem_clicked.connect(on_gem_pressed)
	if not Engine.is_editor_hint(): call_deferred('initial_transition')
	else: randomize_gem_indexes()

func setup_layout() -> void:
	set_hud_target_positions()
	set_instructions_target_positions()

func initial_transition() -> void:
	set_starting_node_properties()
	await hud_in(true)
	start_round()

func start_round() -> void:
	randomize_gem_indexes()
	grid.disable_gems()
	grid.fade(false)
	grid.reveal_gems()
	await get_tree().create_timer(2.0).timeout
	await grid.play_gems_press(true)
	grid.hide_gems()
	await grid.play_gems_press(false)
	await instructions_in(true)
	grid.enable_gems()

func finish_round() -> void:
	grid.disable_gems()
	for index in grid.gems.size():
		var gem = grid.gems[index]
		if index not in grid.correct_gem_indexes: continue
		if gem.state == Gem.BackgroundState.HIDDEN: gem.state = Gem.BackgroundState.MISSED if index in grid.correct_gem_indexes else Gem.BackgroundState.EMPTY
	
	await get_tree().create_timer(2.0).timeout
	await instructions_in(false)
	await grid.fade(true)
	grid.redraw_grid()
	hud.current_round += 1
	hud.score += 100
	start_round()

func randomize_gem_indexes() -> void:
	var pool: Array[int] = []
	for i in range(grid.width * grid.height): pool.append(i)
	pool.shuffle()
	grid.correct_gem_indexes = pool.slice(0, gem_count)

var hud_out_of_bounds_position: Vector2
var hud_initial_position: Vector2
func set_hud_target_positions() -> void:
	hud_initial_position = hud.position
	hud_out_of_bounds_position = Vector2(hud_initial_position.x, -hud.get_screen_position().y - hud.get_size().y)

var instructions_out_of_bounds_position: Vector2
var instructions_initial_position: Vector2
func set_instructions_target_positions() -> void:
	instructions_initial_position = instructions.position
	instructions_out_of_bounds_position = Vector2(instructions_initial_position.x, instructions.position.y + DisplayServer.window_get_size().y - instructions.get_screen_position().y)

func hud_in(val: bool) -> Signal:
	var tween = create_tween()
	hud.position = hud_out_of_bounds_position if val else hud_initial_position
	tween.tween_property(hud, "position", hud_initial_position if val else hud_out_of_bounds_position, 0.3)
	return tween.finished

func instructions_in(val: bool) -> Signal:
	var tween = create_tween()
	instructions.position = instructions_out_of_bounds_position if val else instructions_initial_position
	tween.tween_property(instructions, "position", instructions_initial_position if val else instructions_out_of_bounds_position, 0.3)
	return tween.finished

var gems_revealed: int = 0
func on_gem_pressed(index: int) -> void:
	gems_revealed += 1
	var gem = grid.gems[index]
	gem.state = Gem.BackgroundState.FOUND if index in grid.correct_gem_indexes else Gem.BackgroundState.WRONG
	gem.disable()
	if gems_revealed >= grid.correct_gem_indexes.size(): 
		gems_revealed = 0
		finish_round()