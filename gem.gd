@tool
class_name Gem extends Control

#region static

const ICONS_PATH := "res://assets/gems"

enum GemState {
	EMPTY,
	FOUND,
	HIDDEN,
	MISSED,
	WRONG
}

const BACKGROUND_IMAGES: Dictionary = {
	GemState.EMPTY: preload("res://assets/backgrounds/empty.svg"),
	GemState.FOUND: preload("res://assets/backgrounds/found.svg"),
	GemState.HIDDEN: preload("res://assets/backgrounds/hidden.svg"),
	GemState.MISSED: preload("res://assets/backgrounds/missed.svg"),
	GemState.WRONG: preload("res://assets/backgrounds/wrong.svg"),
}

@onready var background_texture_rect: TextureRect = $BackgroundTextureRect
@onready var gem_texture_rect: TextureRect = $GemTextureRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var button: Button = $Button

const max_tile_size: int = 84

#endregion
#region properties

@export var state: GemState = GemState.HIDDEN : set = set_state
@export var icon: Texture2D = preload(ICONS_PATH + "/1.svg") : set = set_icon
@export var tile_size: int = max_tile_size : set = set_tile_size

func set_state(value: GemState) -> void:
	state = value
	update_background_image()
	update_gem_visibility()

func set_icon(value: Texture2D) -> void:
	icon = value
	update_gem_texture()

func set_tile_size(value: int) -> void:
	tile_size = clampi(value, 0, max_tile_size)
	update_node_sizes()

#endregion

func _ready() -> void:
	update_node_sizes()
	update_gem_texture()
	update_background_image()
	update_gem_visibility()
	connect_button_signals()

func randomize_icon() -> void:
	var dir: DirAccess = DirAccess.open(ICONS_PATH)
	if not dir:
		assert(false, "Failed to open dir at: " + ICONS_PATH)
		return

	var svg_files: Array[Variant] = []

	dir.list_dir_begin()
	var file_name: String = dir.get_next()

	while file_name != "":
		if file_name.ends_with(".svg"): svg_files.append(file_name)
		file_name = dir.get_next()

	dir.list_dir_end()

	if (svg_files.size() == 0):
		assert(false, "SVG list is empty")
		return

	var random_index: int = randi() % svg_files.size()
	icon = load(ICONS_PATH + "/" + svg_files[random_index])

func update_node_sizes() -> void:
	if not is_node_ready(): return
	custom_minimum_size = Vector2(tile_size, tile_size)
	size = custom_minimum_size
	pivot_offset = size / 2
	gem_texture_rect.size = Vector2(tile_size * .69, tile_size * .68)
	gem_texture_rect.position = Vector2((tile_size * .31) / 2, (tile_size * .32) / 2)

func update_background_image() -> void:
	if not is_node_ready(): return
	background_texture_rect.texture = BACKGROUND_IMAGES[state]

func update_gem_texture() -> void:
	if not is_node_ready(): return
	gem_texture_rect.texture = icon

func update_gem_visibility() -> void:
	if not is_node_ready(): return
	if state == GemState.FOUND or state == GemState.MISSED: gem_texture_rect.visible = true
	else: gem_texture_rect.visible = false

func set_opacity(value: float) -> void: modulate.a = value

func fade(value: bool) -> Signal:
	if value: animation_player.play("fade")
	else: animation_player.play_backwards("fade")
	return animation_player.animation_finished

#region press handling	

func connect_button_signals() -> void:
	button.button_down.connect(on_press_down)
	button.button_up.connect(on_press_up)
	button.pressed.connect(on_gem_clicked)

var disabled: bool = false
func disable() -> void: disabled = true
func enable() -> void: disabled = false

signal gem_clicked
func on_gem_clicked(): if not disabled: gem_clicked.emit()

func play_press(value: bool) -> Signal:
	if value: animation_player.play("press")
	else: animation_player.play_backwards("press")
	return animation_player.animation_finished

var _is_pressed: bool = false
func on_press_down():
	if not disabled:
		_is_pressed = true
		play_press(true)
func on_press_up():
	if not disabled || _is_pressed:
		_is_pressed = false
		play_press(false)

#endregion
