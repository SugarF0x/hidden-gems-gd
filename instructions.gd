@tool
extends PanelContainer

@onready var label: Label = $MarginContainer/Label

@export var text: String:
	set(value): 
		text = value
		if label: label.text = value
