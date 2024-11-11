class_name GameContext extends Resource

#region data

@export var stage_current: int = 1 : set = set_stage_current
@export var stage_total: int = 10 : set = set_stage_total
@export var score: int = 0 : set = set_score

signal stage_current_changed(to: int, from: int)
signal stage_total_changed(to: int, from: int)
signal score_changed(to: int, from: int)

func set_stage_current(value: int):
	stage_current_changed.emit(value, stage_current)
	stage_current = value

func set_stage_total(value: int):
	stage_total_changed.emit(value, stage_total)
	stage_total = value

func set_score(value: int):
	score_changed.emit(value, score)
	score = value

#endregion
#region logic

func next_stage() -> void:
	stage_current += 1
	score += 100

#endregion
