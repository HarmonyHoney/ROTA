extends CanvasLayer

onready var control := $Control
onready var cursor_node := $Control/Cursor

onready var list_node := $Control/List
onready var items_node := $Control/List/Items
onready var items := items_node.get_children()

var is_open := false

var scroll := 0
var cursor := 0 setget set_cursor
var cursor_x := 0 setget set_cursor_x
export var cursor_margin := Vector2(-50, 0)

var joy := Vector2.ZERO
var joy_last := Vector2.ZERO

var grid := {}


var open = EaseMover.new()

func _ready():
	open.from = Vector2(0, 720)
	open.to = Vector2.ZERO
	open.node = control
	
	
	
	#show(false)
	
	cursor_node.rect_size = $Control/List/Items/Up/HBoxContainer.get_child(0).rect_size
	
	# fill grid dict
	for y in items.size():
		var hb = items[y].get_node("HBoxContainer")
		
		for x in hb.get_child_count():
			grid[Vector2(x, y)] = hb.get_child(x)
	
	print(grid)

func _input(event):
	if !is_open: return
	
	joy_last = joy
	joy = Input.get_vector("left", "right", "up", "down").round()
	
	if joy.y != 0 and joy.y != joy_last.y:
		self.cursor += joy.y
	
	if joy.x != 0 and joy.x != joy_last.x:
		self.cursor_x += joy.x
	
	
	# exit
	if event.is_action("grab"):
		get_tree().set_input_as_handled()
		show(false)

func _physics_process(delta):
	
	# ease mover
	open.move(delta, is_open)
	
	
	
	var target = grid[Vector2(cursor_x, cursor)]
	
	# position
	var cg = cursor_node.rect_global_position
	cg = cg.linear_interpolate(target.rect_global_position - cursor_margin, 0.15)
	cursor_node.rect_global_position = cg
	
	# size
	var cs = cursor_node.rect_size
	cs = cs.linear_interpolate(target.rect_size + (cursor_margin * 2.0), 0.15)
	cursor_node.rect_size = cs
	
	# scroll
	items_node.rect_position = items_node.rect_position.linear_interpolate(Vector2(0, 80) * -scroll, 0.15)

func show(arg := true):
	is_open = arg
	#control.visible = is_open
	OptionsMenu.is_open = !is_open

func set_cursor(arg := 0):
	cursor = clamp(arg, 0, items.size() - 1)
	
	if cursor < scroll or cursor > 5 + scroll:
		scroll = max(0, cursor - (0 if cursor < scroll else 5))

func set_cursor_x(arg := 0):
	cursor_x = clamp(arg, 0, 3)

