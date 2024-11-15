@tool
class_name StepsCounter extends HBoxContainer

#region static

@onready var current_label: Label = %CurrentLabel
@onready var total_label: Label = %TotalLabel

@export var current: int = 1 : set = set_current
@export var total: int = 10 : set = set_total

func set_current(value: int = current) -> void:
	current = value
	current_label.text = str(value).lpad(str(total).length(), "0")

func set_total(value: int = total) -> void:
	total = value
	total_label.text = str(value)

#endregion

func _ready() -> void:
	update_labels()

func update_labels() -> void:
	set_current()
	set_total()
