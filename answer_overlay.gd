@tool
class_name AnswerOverlay extends Control

enum AnswerOverlayState {
	CORRECT,
	WRONG,
}

const STATE_TO_COLOR_MAP = {
	AnswerOverlayState.CORRECT: 0x59AD6C4D,
	AnswerOverlayState.WRONG: 0xD8494B4D,
}

const STATE_TO_TEXTURE_MAP = {
	AnswerOverlayState.CORRECT: preload("res://assets/badges/correct-answer.svg"),
	AnswerOverlayState.WRONG: preload("res://assets/badges/wrong-answer.svg"),
}

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var panel: Panel = $Panel
@onready var texture_rect: TextureRect = $Panel/TextureRect

@export var game_context: HGGameContext

@export var state: AnswerOverlayState = AnswerOverlayState.CORRECT:
	set(value):
		state = value
		sync_bg_color()
		sync_icon()

func set_state(is_correct: bool) -> void: state = AnswerOverlayState.CORRECT if is_correct else AnswerOverlayState.WRONG

func _ready() -> void:
	sync_bg_color()
	sync_icon()

func sync_bg_color() -> void:
	if not panel: return
	var styleBox: StyleBoxFlat = panel.get_theme_stylebox("panel")
	styleBox.set('bg_color', Color(STATE_TO_COLOR_MAP[state]))

func sync_icon() -> void:
	if not texture_rect: return
	texture_rect.texture = STATE_TO_TEXTURE_MAP[state]

func fade(value: bool) -> Signal:
	if value: 
		animation_player.play('fade')
		animation_player.animation_finished.connect(func(name: String): visible = false, ConnectFlags.CONNECT_ONE_SHOT)
	else: 
		visible = true
		animation_player.play_backwards('fade')
	return animation_player.animation_finished
