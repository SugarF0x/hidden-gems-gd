@tool
class_name Instructions
extends PanelContainer

@onready var label: Label = $MarginContainer/Label

@export var game_context: HGGameContext

@export var text: String = "sample instructions text":
	set(value): 
		text = value
		update_label()

func _ready():
	update_label()

func update_label():
	if not label: return
	label.text = text
