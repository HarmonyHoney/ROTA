extends CanvasLayer

onready var control := $Control
onready var cursor_node := $Control/Menu/Cursor
onready var menu := $Control/Menu/

onready var items_node = $Control/Menu/List
var items := []

var is_open := false
var cursor := 0 setget set_cursor

var joy := Vector2.ZERO
var joy_last := Vector2.ZERO

onready var open = EaseMover.new(control, 0.5, Vector2(0, 720), Vector2.ZERO)

export var cursor_margin := Vector2.ZERO

func _ready():
	#control.visible = false
	
	for i in items_node.get_children():
		if !i.is_in_group("no_item"):
			items.append(i)

func _input(event):
	if !is_open: return
	joy_last = joy
	joy = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").round()

	# cursor
	if joy.y != 0 and joy.y != joy_last.y:
		self.cursor += joy.y

	# left and right
	if joy.x != 0 and joy.x != joy_last.x:
		if items[cursor].has_method("axis_x"):
			items[cursor].axis_x(joy.x)

	if event.is_action_pressed("ui_accept"):
		if items[cursor].has_method("act"):
			items[cursor].act()

	# exit
	if event.is_action_pressed("ui_cancel"):
		get_tree().set_input_as_handled()
		#yield(get_tree(), "idle_frame")
		show(false)


func _physics_process(delta):
	open.count(delta, is_open)
	control.modulate.a = lerp(0.0, 1.0, open.clock / open.time)
	
	control.visible = open.clock > 0
	
	if !is_open: return
	
	# cursor
	cursor_node.rect_position = cursor_node.rect_position.linear_interpolate(items_node.rect_position + items[cursor].rect_position - cursor_margin, 0.15)
	cursor_node.rect_size = cursor_node.rect_size.linear_interpolate(items[cursor].rect_size + (cursor_margin * 2.0), 0.15)
	
	# scroll
	menu.rect_position.y = lerp(menu.rect_position.y, (720 / 2.0) - (cursor_node.rect_position.y + cursor_node.rect_size.y / 2.0), 0.08)
	

func show(arg := true):
	is_open = arg
	#control.visible = is_open

	PauseMenu.is_paused = !is_open

	if is_open:
		self.cursor = 0

func set_cursor(arg := 0):
	cursor = clamp(arg, 0, items.size() - 1)

