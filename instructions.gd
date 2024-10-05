@tool
extends PanelContainer

@onready var label: Label = $MarginContainer/Label

@export var text: String = "sample instructions text":
	set(value): 
		text = value
		if label: label.text = value

func _process(delta):
	if not Engine.is_editor_hint(): return
	if not label: return
	if label.text != text: label.text = text
