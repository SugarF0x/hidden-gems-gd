extends Node

@onready var hud: Hud = $UI/ContentContainer/Hud
@onready var instructions: Instructions = $UI/ContentContainer/Instructions
@onready var grid: GemGrid = $UI/ContentContainer/Grid

var gem_count: int = 3

func _ready() -> void:
	grid.gem_clicked.connect(on_gem_pressed)
	start_round()

func start_round() -> void:
	randomize_gem_indexes()
	grid.disable_gems()
	grid.fade(false)
	grid.reveal_gems()
	await grid.get_tree().create_timer(2.0).timeout
	await grid.play_gems_press(true)
	grid.hide_gems()
	await grid.play_gems_press(false)
	grid.enable_gems()

func finish_round() -> void:
	grid.disable_gems()
	for index in grid.gems.size():
		var gem = grid.gems[index]
		if index not in grid.correct_gem_indexes: continue
		if gem.state == Gem.BackgroundState.HIDDEN: gem.state = Gem.BackgroundState.MISSED if index in grid.correct_gem_indexes else Gem.BackgroundState.EMPTY
	
	await get_tree().create_timer(2.0).timeout
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

var gems_revealed: int = 0
func on_gem_pressed(index: int) -> void:
	gems_revealed += 1
	var gem = grid.gems[index]
	gem.state = Gem.BackgroundState.FOUND if index in grid.correct_gem_indexes else Gem.BackgroundState.WRONG
	if gems_revealed >= grid.correct_gem_indexes.size(): 
		gems_revealed = 0
		finish_round()
