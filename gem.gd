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

@export var state := BackgroundState.EMPTY:
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
	if not Engine.is_editor_hint(): return
	state = BackgroundState.FOUND
