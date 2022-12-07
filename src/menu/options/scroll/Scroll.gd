extends Control
class_name Scroll

onready var label_desc := get_node_or_null("Label")
onready var label_value := get_node_or_null("Label2")

var cursor := 0
export var is_loop := false
export var count := 0
export var list : PoolStringArray = ["zero", "one", "two"]


func _ready():
	set_label()

func axis_x(arg):
	cursor = posmod(cursor + arg, (count + 1) if count > 0 else list.size()) if is_loop else clamp(cursor + arg, 0, count if count > 0 else (list.size() - 1))
	set_label()
	set_value()

func set_label():
	if is_instance_valid(label_value):
		label_value.text = "< " + str(list[cursor] if count == 0 else cursor) + " >"

func set_value():
	pass
