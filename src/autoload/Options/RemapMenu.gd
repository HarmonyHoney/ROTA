extends CanvasLayer

onready var control := $Control
onready var cursor_node := $Control/Cursor

onready var list_node := $Control/List
onready var items_node := $Control/List/Items
onready var items := items_node.get_children()

var is_open := false
var open = EaseMover.new()

var scroll := 0
var cursor := 0 setget set_cursor
var cursor_x := 0 setget set_cursor_x
export var cursor_margin := Vector2(-50, 0)

var joy := Vector2.ZERO
var joy_last := Vector2.ZERO

var grid := {}

var actions = {"Up": "up",
"Down": "down",
"Left": "left",
"Right": "right",
"Jump/Accept": "jump",
"Grab/Back": "grab",
"Zoom": "zoom",
"Reset": "reset",
"Pause": "pause",}

var tex = {"JOY 0": preload("res://media/image/UI/btn_a.png"),
"JOY 1": preload("res://media/image/UI/btn_b.png"),
"JOY 2": preload("res://media/image/UI/btn_x.png"),
"JOY 3": preload("res://media/image/UI/btn_y.png"),
"JOY 10": preload("res://media/image/UI/btn_select.png"),
"JOY 11": preload("res://media/image/UI/btn_start.png"),
"JOY 12": preload("res://media/image/UI/dpad_up.png"),
"JOY 13": preload("res://media/image/UI/dpad_up.png"),
"JOY 14": preload("res://media/image/UI/dpad_up.png"),
"JOY 15": preload("res://media/image/UI/dpad_up.png"),
"AXIS 1-": preload("res://media/image/UI/l_stick_up.png"),
"AXIS 1+": preload("res://media/image/UI/l_stick_down.png"),
"AXIS 0-": preload("res://media/image/UI/l_stick_left.png"),
"AXIS 0+": preload("res://media/image/UI/l_stick_right.png"),
"AXIS 2-": preload("res://media/image/UI/r_stick_up.png"),
"AXIS 2+": preload("res://media/image/UI/r_stick_down.png"),
"AXIS 3-": preload("res://media/image/UI/r_stick_left.png"),
"AXIS 3+": preload("res://media/image/UI/r_stick_right.png"),
"KEY": preload("res://media/image/box/round_rect200.png"),
"KEY_2": preload("res://media/image/UI/key_2.png"),
"KEY_3": preload("res://media/image/UI/key_3.png"),
"UP": preload("res://media/image/UI/key_up.png"),
"DOWN": preload("res://media/image/UI/key_up.png"),
"LEFT": preload("res://media/image/UI/key_up.png"),
"RIGHT": preload("res://media/image/UI/key_up.png"),}

var rotate = {"DOWN": 180,
"LEFT": 270,
"RIGHT": 90,
"JOY 13": 180,
"JOY 14": 270,
"JOY 15": 90,}

func _ready():
	open.from = Vector2(0, 720)
	open.to = Vector2.ZERO
	open.node = control
	
	# create rows
	var u = items_node.get_child(0)
	for i in actions.size() - 1:
		var dup = u.duplicate()
		items_node.add_child(dup)
	items = items_node.get_children()
	
	# setup rows
	for y in items.size():
		items[y].get_node("Label").text = actions.keys()[y]
		
		# fill grid dict
		var k = items[y].get_node("Keys")
		for x in k.get_child_count():
			grid[Vector2(x, y)] = k.get_child(x)
		
		set_keys(y)
	
	#print(grid)

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

func set_keys(row := 0):
	var joy = []
	var keys = []
	for i in InputMap.get_action_list(actions.values()[row]):
		if i is InputEventJoypadButton or i is InputEventJoypadMotion:
			joy.append(i)
		else:
			keys.append(i)
	
	var a = []
	for i in 2:
		if i < keys.size():
			a.append(keys[i])
		else:
			a.append("")
	a.append_array(joy)
	
	for i in 4:
		var s = ""
		if i < a.size():
			if a[i] is InputEventJoypadButton:
				s = "JOY " + str(a[i].button_index)
			elif a[i] is InputEventJoypadMotion:
				var av = a[i].axis_value
				var sgn = "+" if av > 0 else "-"
				s = "AXIS " + str(a[i].axis) + sgn
			elif a[i] is InputEvent:
				s = str(a[i].as_text().to_upper())
		
		var label = grid[Vector2(i, row)].get_node("Label")
		label.visible = true
		var spr = grid[Vector2(i, row)].get_node("Sprite")
		spr.visible = true
		
		# no text
		if s == "":
			label.visible = false
			spr.visible = false
		
		# sprite
		elif tex.has(s):
			label.visible = false
			
			spr.texture = tex[s]
			if rotate.has(s):
				spr.rotation_degrees = rotate[s]
		
		# text over key
		else:
			label.text = s
			
			if s.length() < 2:
				spr.texture = tex["KEY"]
			else:
				spr.texture = tex["KEY_2"]
