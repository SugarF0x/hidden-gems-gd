@tool
extends PanelContainer

@onready var round_label: Label = $HBoxContainer/MarginContainer/RoundLabel
@onready var score_label: Label = $HBoxContainer/MarginContainer/ScoreLabel

@export var current_round: int = 1:
	set(value):
		print('Setting big time! %s %s' % [str(current_round), str(value)])
		current_round = value
		update_round_label()

@export var total_rounds: int = 10:
	set(value):
		total_rounds = value
		update_round_label()

@export var score: int = 0:
	set(value):
		score = value
		if score_label: score_label.text = str(value)

func update_round_label():
	if not round_label: return
	round_label.text = "{current}/{total}".format({ "current": str(current_round), "total": str(total_rounds) })
