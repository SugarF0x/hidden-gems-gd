extends Node

@onready var game_scene: GameScene = $UI/GameScene
@onready var countdown: Countdown = $UI/Countdown

@export var skip_intro: bool = true

func _ready() -> void:
	if skip_intro:
		game_scene.start_game.call_deferred()
	else:
		await countdown.play()
		game_scene.start_game()
