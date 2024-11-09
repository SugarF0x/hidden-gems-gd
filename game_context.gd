class_name GameContext extends Resource

@export var stage_current: int = 1
@export var stage_total: int = 10
@export var score: int = 0

signal stage_current_changed(to: int)
signal stage_total_changed(to: int)
signal score_changed(to: int)

func next_stage() -> void:
	stage_current += 1
	score += 100
	
	stage_current_changed.emit(stage_current)
	score_changed.emit(score)
