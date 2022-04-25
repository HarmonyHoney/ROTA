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

export var is_open := false setget set_open
signal signal_close
var is_sub_menu := false

export var is_fade := false
export var fade_path : NodePath
onready var fade_node = get_node(fade_path)
onready var fade_ease := EaseMover.new()

var joy := Vector2.ZERO
var joy_last := Vector2.ZERO

var joy_clock := 0.0
var joy_wait := 0.3
var joy_repeat := 0.2

func _ready():
	fill_items()
	self.cursor = 0
	
	reset_cursor()

func menu_input(event):
	if !is_open: return
	
	var accept = event.is_action_pressed("ui_accept")
	var back = event.is_action_pressed("ui_cancel")
	
	joy_last = joy
	joy = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").round()
	
	if back and event.is_pressed():
		back()
	elif accept and event.is_pressed():
		accept()
	elif joy.y != 0 and joy.y != joy_last.y:
		self.cursor = wrapi(cursor + joy.y, 0, items.size())
		joy_clock = 0.0
	elif joy.x != 0 and joy.x != joy_last.x:
		joy_x(joy.x)

func menu_process(delta):
	if is_fade:
		fade_node.modulate.a = fade_ease.count(delta, is_open)
	
	if is_open:
		# hold up/down repeat
		if joy.y != 0:
			joy_clock += delta
			if joy_clock > joy_wait + joy_repeat:
				joy_clock = joy_wait
				self.cursor += joy.y
		
		# move cursor
		cursor_node.rect_global_position = cursor_node.rect_global_position.linear_interpolate(items[cursor].rect_global_position - cursor_margin, 0.15)
		cursor_node.rect_size = cursor_node.rect_size.linear_interpolate(items[cursor].rect_size + (cursor_margin * 2.0), 0.15)
		
		# scroll
		if is_scroll:
			menu_node.rect_position.y = lerp(menu_node.rect_position.y, (720 / 2.0) - (cursor_node.rect_position.y + cursor_node.rect_size.y / 2.0), 0.08)

func set_cursor(arg := 0):
	cursor = clamp(arg, 0, items.size() - 1)
	#cursor = wrapi(arg, 0, items.size() - 1)

func reset_cursor():
	cursor_node.rect_global_position = items[cursor].rect_global_position - cursor_margin
	cursor_node.rect_size = items[cursor].rect_size + (cursor_margin * 2.0)
	
	# scroll
	if is_scroll:
		menu_node.rect_position.y = (720 / 2.0) - (cursor_node.rect_position.y + cursor_node.rect_size.y / 2.0)

func set_open(arg := is_open):
	is_open = arg
	
	if is_open:
		self.cursor = 0
		fill_items()
	else:
		emit_signal("signal_close")

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
	is_sub_menu = true
	is_open = false
	
	arg.is_open = true 
	yield(arg, "signal_close")
	
	is_sub_menu = false
	is_open = true
