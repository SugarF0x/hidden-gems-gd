class_name Countdown extends Control

@onready var video_stream_player: VideoStreamPlayer = $VideoStreamPlayer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	visible = false
	video_stream_player.finished.connect(_on_played)

func play() -> Signal:
	visible = true
	video_stream_player.play()
	audio_stream_player.play()
	return video_stream_player.finished

func _on_played() -> void:
	visible = false
