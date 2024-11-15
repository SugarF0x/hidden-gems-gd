extends Node

@onready var game_scene: GameScene = $UI/GameScene
@onready var countdown: Countdown = $UI/Countdown

func _ready() -> void:
	#await countdown.play()
	game_scene.start_game.call_deferred()
