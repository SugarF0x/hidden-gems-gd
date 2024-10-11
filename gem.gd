@tool
class_name Gem
extends Control

const ICONS_PATH := "res://assets/gems"
const SIZE := 100

enum BackgroundState {
	EMPTY,
	FOUND,
	HIDDEN,
	MISSED,
	WRONG
}

const BACKGROUND_IMAGES = {
	BackgroundState.EMPTY: preload("res://assets/backgrounds/empty.svg"),
	BackgroundState.FOUND: preload("res://assets/backgrounds/found.svg"),
	BackgroundState.HIDDEN: preload("res://assets/backgrounds/hidden.svg"),
	BackgroundState.MISSED: preload("res://assets/backgrounds/missed.svg"),
	BackgroundState.WRONG: preload("res://assets/backgrounds/wrong.svg"),
}

@onready var background_texture_rect: TextureRect = $BackgroundTextureRect
@onready var gem_texture_rect: TextureRect = $GemTextureRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var disabled: bool = false

@export var state := BackgroundState.HIDDEN:
	set(value):
		state = value
		update_background_image()
		update_gem_visibility()

var selected_icon: Texture2D:
	set(value):
		selected_icon = value
		update_gem_texture()

func _ready() -> void:
	set_controls_node_size()
	set_random_gem_icon()
	update_background_image()
	update_gem_visibility()
	_editor_on_ready()

func set_random_gem_icon() -> void:
	var dir = DirAccess.open(ICONS_PATH)
	if not dir:
		assert(false, "Failed to open dir at: " + ICONS_PATH)
		return
	
	var svg_files = []
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".svg"): svg_files.append(file_name)
		file_name = dir.get_next()
	
	dir.list_dir_end()
	
	if (svg_files.size() == 0):
		assert(false, "SVG list is empty")
		return
	
	var random_index = randi() % svg_files.size()
	selected_icon = load(ICONS_PATH + "/" + svg_files[random_index])

func set_controls_node_size() -> void:
	custom_minimum_size = Vector2(SIZE, SIZE)

func update_background_image() -> void:
	if not background_texture_rect: return
	background_texture_rect.texture = BACKGROUND_IMAGES[state]

func update_gem_texture() -> void:
	if not gem_texture_rect: return
	gem_texture_rect.texture = selected_icon

func update_gem_visibility() -> void:
	if not gem_texture_rect: return
	if state == BackgroundState.FOUND or state == BackgroundState.MISSED: gem_texture_rect.visible = true
	else: gem_texture_rect.visible = false

func _editor_on_ready() -> void:
	if Engine.is_editor_hint(): state = BackgroundState.FOUND
	else: state = BackgroundState.HIDDEN

func set_opacity(value: float) -> void: modulate.a = value

func fade(value: bool) -> Signal:
	if value: animation_player.play("fade")
	else: animation_player.play_backwards("fade")
	return animation_player.animation_finished

func play_press(value: bool) -> Signal:
	if value: animation_player.play("press")
	else: animation_player.play_backwards("press")
	return animation_player.animation_finished

signal gem_clicked
func on_gem_clicked(): if not disabled: gem_clicked.emit()
func on_press_down(): if not disabled: play_press(true)
func on_press_up(): if not disabled: play_press(false)
