@tool
class_name StepsCounter extends HBoxContainer

#region static

@onready var current_label: Label = %CurrentLabel
@onready var total_label: Label = %TotalLabel

@export var current: int = 1 : set = set_current
@export var total: int = 10 : set = set_total

func set_current(value: int) -> void:
	current = value
	update_current_label()

func set_total(value: int = total) -> void:
	total = value
	update_total_label()

#endregion

func _ready() -> void:
	update_labels()

func update_current_label() -> void: 
	if not is_node_ready(): return
	current_label.text = str(current).lpad(str(total).length(), "0")

func update_total_label() -> void:
	if not is_node_ready(): return
	total_label.text = str(total)

func update_labels() -> void:
	update_current_label()
	update_total_label()
