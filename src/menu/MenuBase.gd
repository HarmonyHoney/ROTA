extends Node
class_name MenuBase

export var cursor_path : NodePath
onready var cursor_node = get_node(cursor_path)

export var items_path : NodePath
onready var items_node = get_node(items_path)

export var is_scroll := false
export var menu_path : NodePath
onready var menu_node = get_node(menu_path)

var items = []
var cursor := 0 setget set_cursor
export var cursor_margin := Vector2(30, 0)

export var is_open := false

signal signal_close

func _ready():
	fill_items()

func menu_input(event):
	if !is_open: return
	
	var up = event.is_action_pressed("ui_up")
	var down = event.is_action_pressed("ui_down")
	var left = event.is_action_pressed("ui_left")
	var right = event.is_action_pressed("ui_right")
	var accept = event.is_action_pressed("ui_accept")
	var back = event.is_action_pressed("ui_cancel")
	
	if back:
		back()
	elif up or down:
		self.cursor += -1 if up else 1
	elif left or right:
		joy_x(-1 if left else 1)
	elif accept:
		accept()

func menu_process(delta):
	if is_open:
		cursor_node.rect_global_position = cursor_node.rect_global_position.linear_interpolate(items[cursor].rect_global_position - cursor_margin, 0.15)
		cursor_node.rect_size = cursor_node.rect_size.linear_interpolate(items[cursor].rect_size + (cursor_margin * 2.0), 0.15)
		
		# scroll
		if is_scroll:
			menu_node.rect_position.y = lerp(menu_node.rect_position.y, (720 / 2.0) - (cursor_node.rect_position.y + cursor_node.rect_size.y / 2.0), 0.08)

func set_cursor(arg := 0):
	cursor = clamp(arg, 0, items.size() - 1)

func fill_items():
	items = []
	if items_node:
		for i in items_node.get_children():
			if !i.is_in_group("no_item") and i.visible:
				items.append(i)

func accept():
	pass

func back():
	pass

func joy_x(arg := 1):
	pass

func sub_menu(arg : MenuBase):
	is_open = false
	arg.show(true)
	yield(arg, "signal_close")
	is_open = true
