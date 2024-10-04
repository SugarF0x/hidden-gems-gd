extends Control

@onready var label: Label = $PanelContainer/MarginContainer/Label

@export var text: String:
	get(): 
		return label.text
	set(value): 
		label.text = value
