@tool
class_name Hud extends PanelContainer

#region static

@onready var score_label: Label = %ScoreLabel
@onready var steps_counter: StepsCounter = %StepsCounter
@onready var pause_button: TextureButton = %PauseButton

@export var context_conntexted: bool = true
@export var current_round: int = 1 : set = set_current_round
@export var total_rounds: int = 10 : set = set_total_rounds
@export var score: int = 0 : set = set_score

func set_current_round(value: int) -> void:
	current_round = value
	update_round_label()

func set_total_rounds(value: int) -> void:
	total_rounds = value
	update_round_label()

func set_score(value: int) -> void:
	score = value
	update_score_label()

#endregion

var game_context: GameContext = preload("res://game_context.tres")

func _ready():
	pause_button.pressed.connect(on_pause_pressed)
	setup_context_sync()
	update_round_label()
	update_score_label()

func setup_context_sync() -> void:
	if not is_node_ready(): return
	if not context_conntexted: return
	if not game_context: return
	
	setup_context_connections()
	on_context_score_changed(game_context.score, 0)
	on_context_stage_current_changed(game_context.stage_current, 0)
	on_context_stage_total_changed(game_context.stage_total, 0)

func setup_context_connections() -> void:
	if Engine.is_editor_hint(): return
	game_context.stage_total_changed.connect(on_context_stage_total_changed)
	game_context.stage_current_changed.connect(on_context_stage_current_changed)
	game_context.score_changed.connect(on_context_score_changed)

func on_context_score_changed(to: int, _from: int) -> void: score = to
func on_context_stage_current_changed(to: int, _from: int) -> void: current_round = to
func on_context_stage_total_changed(to: int, _from: int) -> void: total_rounds = to

func update_round_label() -> void:
	if not is_node_ready(): return
	steps_counter.current = current_round
	steps_counter.total = total_rounds

func update_score_label() -> void:
	if not is_node_ready(): return
	if score_label.text != str(score): score_label.text = str(score)

signal pause_pressed
func on_pause_pressed(): pause_pressed.emit()
