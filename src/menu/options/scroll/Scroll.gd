extends Control
class_name Scroll

onready var label_desc := get_node_or_null("Label")
onready var label_value := get_node_or_null("Label2")

var cursor := 0 setget set_cursor
export var is_loop := false
export var count := 0
export var list : PoolStringArray = ["OFF", "ON"]
var is_select := false

func _ready():
	set_label()

func set_label():
	if is_instance_valid(label_value):
		var s = ["< " if is_select and (is_loop or cursor > 0) else "",
		" >" if is_select and (is_loop or cursor < max(count, list.size() - 1)) else ""]
		
		label_value.text = s[0] + str(list[cursor] if count == 0 else cursor) + s[1]

func set_value():
	pass

func set_cursor(arg := cursor):
	cursor = posmod(arg, max(count + 1, list.size())) if is_loop else clamp(arg, 0, max(count, list.size() - 1))
	set_label()
	set_value()

func select(arg := is_select):
	is_select = arg
	set_label()

func axis_x(arg := 1):
	self.cursor += arg


