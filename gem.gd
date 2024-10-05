@tool
extends Control

const icons_path := "res://assets/gems"

@onready var gem_texture_rect: TextureRect = $GemTextureRect

var selected_icon: Texture2D

func _ready():
	select_random_svg()
	gem_texture_rect.texture = selected_icon
	custom_minimum_size = gem_texture_rect.size

func select_random_svg() -> void:
	var dir = DirAccess.open(icons_path)
	if not dir:
		assert(false, "Failed to open dir at: " + icons_path)
		return
	
	var svg_files = []
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".svg"):
			svg_files.append(file_name)
		file_name = dir.get_next()
	
	dir.list_dir_end()
	
	if (svg_files.size() == 0):
		assert(false, "SVG list is empty")
		return
	
	var random_index = randi() % svg_files.size()
	selected_icon = load(icons_path + "/" + svg_files[random_index])
