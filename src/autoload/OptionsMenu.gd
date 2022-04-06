extends CanvasLayer

onready var control := $Control
onready var cursor_node := $Control/Cursor
onready var list_node := $Control/Tabs

var tab := 0 setget set_tab
onready var tabs := $Control/Tabs.get_children()
onready var headers := $Control/Header.get_children()

onready var items_node = tabs[tab]
onready var items = tabs[tab].get_children()

var is_open := false
var scroll := 0
var cursor := 0 setget set_cursor

var joy := Vector2.ZERO
var joy_last := Vector2.ZERO

export var header_margin := Vector2(-20, 20)

func _ready():
	control.visible = false

func _input(event):
	if !is_open: return
	joy_last = joy
	joy = Input.get_vector("left", "right", "up", "down").round()
	
	# cursor
	if joy.y != 0 and joy.y != joy_last.y:
		self.cursor += joy.y
	
	# left and right
	if joy.x != 0 and joy.x != joy_last.x:
		# headers
		if cursor == -1:
			self.tab += joy.x
		
		# option
		elif items[cursor].has_method("axis_x"):
			items[cursor].axis_x(joy.x)
	
	if event.is_action_pressed("jump"):
		if cursor != -1:
			if items[cursor].has_method("act"):
				items[cursor].act()
	
	# exit
	if event.is_action_pressed("grab"):
		get_tree().set_input_as_handled()
		#yield(get_tree(), "idle_frame")
		show(false)
	

func _physics_process(delta):
	if !is_open: return
	
	if cursor == -1:
		cursor_node.rect_global_position = cursor_node.rect_global_position.linear_interpolate(headers[tab].rect_global_position - header_margin, 0.15)
		cursor_node.rect_size = cursor_node.rect_size.linear_interpolate(headers[tab].rect_size + (header_margin * 2.0), 0.15)
	else:
		cursor_node.rect_position = cursor_node.rect_position.linear_interpolate(list_node.rect_position + items[cursor - scroll].rect_position, 0.15)
		cursor_node.rect_size = cursor_node.rect_size.linear_interpolate(items[cursor].rect_size, 0.15)
	
	# scroll
	items_node.rect_position = items_node.rect_position.linear_interpolate(Vector2(0, 80) * -scroll, 0.15)

func show(arg := true):
	is_open = arg
	control.visible = is_open
	
	PauseMenu.is_paused = !is_open
	UI.gem.show = !is_open
	
	if is_open:
		self.tab = 0

func set_cursor(arg := 0):
	cursor = clamp(arg, -1, items.size() - 1)
	
	if cursor < scroll or cursor > 4 + scroll:
		scroll = max(0, cursor - (0 if cursor < scroll else 4))

func set_tab(arg := 0):
	tab = clamp(arg, 0, tabs.size() - 1)
	cursor = -1
	scroll = 0
	
	# header
	for i in headers.size():
		headers[i].modulate.a = 1.0 if i == tab else 0.5
	
	# visible
	for i in tabs.size():
		tabs[i].visible = i == tab
	
	# ready
	for i in tabs[tab].get_children():
		if i.has_method("_ready"):
			i._ready()
	
	# items
	items_node = tabs[tab]
	items = items_node.get_children()
	
	

