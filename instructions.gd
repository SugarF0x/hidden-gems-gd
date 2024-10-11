@tool
class_name Instructions
extends PanelContainer

@onready var label: Label = $MarginContainer/Label

@export var text: String = "sample instructions text":
	set(value): 
		text = value
		update_label()

func _ready():
	update_label()

func update_label():
	if not label: return
	if label.text != text: label.text = text
