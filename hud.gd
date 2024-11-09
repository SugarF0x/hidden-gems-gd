@tool
class_name Hud
extends PanelContainer

@onready var round_label: Label = %RoundLabel
@onready var score_label: Label = %ScoreLabel

@export var current_round: int = 1:
	set(value):
		current_round = value
		update_round_label()

@export var total_rounds: int = 10:
	set(value):
		total_rounds = value
		update_round_label()

@export var score: int = 0:
	set(value):
		score = value
		update_score_label()

var game_context: GameContext = preload("res://game_context.tres")

func _ready():
	setup_context_sync()
	update_round_label()
	update_score_label()

func setup_context_sync() -> void:
	if not is_node_ready(): return
	if not game_context: return
	
	setup_context_connections()
	on_context_score_changed(game_context.score)
	on_context_stage_current_changed(game_context.stage_current)
	on_context_stage_total_changed(game_context.stage_total)

func setup_context_connections() -> void:
	if Engine.is_editor_hint(): return
	game_context.stage_total_changed.connect(on_context_stage_total_changed)
	game_context.stage_current_changed.connect(on_context_stage_current_changed)
	game_context.score_changed.connect(on_context_score_changed)

func on_context_score_changed(to: int) -> void: score = to
func on_context_stage_current_changed(to: int) -> void: current_round = to
func on_context_stage_total_changed(to: int) -> void: total_rounds = to

func update_round_label():
	if not round_label: return
	var new_value = "{current}/{total}".format({ "current": str(current_round), "total": str(total_rounds) })
	if round_label.text != new_value: round_label.text = new_value

func update_score_label():
	if not score_label: return
	if score_label.text != str(score): score_label.text = str(score)

signal pause_pressed
func on_pause_pressed(): pause_pressed.emit()
