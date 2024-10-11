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

func _ready():
	update_round_label()
	update_score_label()

func update_round_label():
	if not round_label: return
	var new_value = "{current}/{total}".format({ "current": str(current_round), "total": str(total_rounds) })
	if round_label.text != new_value: round_label.text = new_value

func update_score_label():
	if not score_label: return
	if score_label.text != str(score): score_label.text = str(score)

signal pause_pressed
func on_pause_pressed(): pause_pressed.emit()
