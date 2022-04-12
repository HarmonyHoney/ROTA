extends CanvasLayer

onready var control := $Control
onready var cursor_node := $Control/Menu/Cursor
onready var menu := $Control/Menu

onready var items_node := $Control/Menu/List
var items := []

var is_open := false
var open = EaseMover.new()

var scroll := 0
var cursor := 0 setget set_cursor
export var cursor_margin := Vector2.ZERO

var joy := Vector2.ZERO
var joy_last := Vector2.ZERO

var prompt := EaseMover.new()
var is_prompt := false
onready var prompt_key := $Control/Prompt/VBoxContainer/Key
onready var prompt_timer_label := $Control/Prompt/VBoxContainer/Timer
var prompt_clock := 0.0
var prompt_time := 5.0
var is_button := false

onready var key = preload("res://src/autoload/Options/Key.tscn")

export var is_gamepad := false

onready var header := $Control/Header
onready var header_back := $Control/Header/Back
onready var header_ease := EaseMover.new(null, 0.2)
onready var header_track := $Control/Menu/List/Spacer

var defaults := {}

func _ready():
	open.from = Vector2(0, 720)
	open.to = Vector2.ZERO
	open.node = control
	
	prompt.node = $Control/Prompt
	prompt.to = prompt.node.rect_position
	prompt.from = Vector2(prompt.to.x, 720)
	
	# fill items
	for i in items_node.get_children():
		if !i.is_in_group("no_item"):
			items.append(i)
	
	# create keys
	for i in items.size():
		create_keys(i)
	
	# get default binds
	for i in InputMap.get_actions():
		defaults[i] = InputMap.get_action_list(i)

func _input(event):
	if !is_open: return
	
	if is_prompt:
		if event.is_action_pressed("ui_pause"):
			is_prompt = false
		elif event.is_pressed() and is_type(event):
			assign_key(items[cursor].action, event)
			is_prompt = false
			get_tree().set_input_as_handled()
		
	else:
		joy_last = joy
		joy = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").round()
		
		# move cursor
		if joy.y != 0 and joy.y != joy_last.y:
			self.cursor += joy.y
		
		# open prompt
		elif event.is_action_pressed("ui_accept"):
			if items[cursor].is_in_group("reset"):
				reset_to_defaults()
			elif items[cursor].is_in_group("remap"):
				is_prompt = true
				prompt_key.text = items[cursor].action
				prompt_clock = prompt_time
				get_tree().set_input_as_handled()
		
		# clear key
		elif event.is_action_pressed("ui_end"):
			clear_row(cursor)
		
		# exit
		elif event.is_action_pressed("ui_cancel"):
			get_tree().set_input_as_handled()
			show(false)

func _physics_process(delta):
	if is_prompt:
		prompt_clock -= delta
		prompt_timer_label.text = str(ceil(max(0, prompt_clock)))
		
		if prompt_clock < 0:
			is_prompt = false
	
	# ease mover
	open.count(delta, is_open)
	control.modulate.a = lerp(0, 1, open.clock / open.time)
	
	prompt.count(delta, is_prompt)
	prompt.node.modulate.a = lerp(0, 1, prompt.clock / prompt.time)
	prompt.node.visible = prompt.clock > 0
	
	if open.clock == 0: return
	
	var target = items[cursor]
	
	# position
	var cg = cursor_node.rect_global_position
	cg = cg.linear_interpolate(target.rect_global_position - cursor_margin, 0.15)
	cursor_node.rect_global_position = cg
	
	# size
	var cs = cursor_node.rect_size
	cs = cs.linear_interpolate(target.rect_size + (cursor_margin * 2.0), 0.15)
	cursor_node.rect_size = cs
	
	# scroll menu
	menu.rect_position.y = lerp(menu.rect_position.y, (720 / 2.0) - (cursor_node.rect_position.y + cursor_node.rect_size.y / 2.0), 0.08)
	
	# header position
	header.rect_global_position.y = clamp(header_track.rect_global_position.y, 30, 1280)
	
	# header back
	header_ease.show  = header.rect_global_position.y == 30
	header_ease.count(delta)
	header_back.modulate.a = lerp(0, 1.0, header_ease.frac())

func show(arg := true):
	is_open = arg
	OptionsMenu.is_open = !is_open
	
	if is_open:
		cursor = 0
		scroll = 0
		
		# create keys
		for i in items.size():
			create_keys(i)
		
		# header text
		$Control/Menu/List/Title.text = ("Controller" if is_gamepad else "Keyboard") + " Setup"
		
	else:
		for i in items.size():
			remove_keys(i)

func set_cursor(arg := 0):
	cursor = clamp(arg, 0, items.size() - 1)

func draw_key(key_node, event):
	if !is_type(event): return
	
	key_node.parse_event(event)

func remove_keys(row := 0):
	if items[row].is_in_group("remap"):
		for i in items[row].get_node("Keys").get_children():
			i.queue_free()

func clear_row(row := 0):
	if items[row].is_in_group("remap"):
		remove_keys(row)
		var action = items[row].action
		
		var list = []
		for i in InputMap.get_action_list(action):
			if is_type(i):
				list.append(i)
		
		# keep one event for ui
		if "ui_" in action:
			list.pop_back()
		
		for i in list:
			InputMap.action_erase_event(action, i)
		
		create_keys(row)
		
		Shared.emit_signal("signal_gamepad", Shared.is_gamepad)

func assign_key(action, event):
	# keep size to 4
	var list = []
	for i in InputMap.get_action_list(action):
		if is_type(i):
			list.append(i)
	
	if list.size() > 3:
		InputMap.action_erase_event(action, list[0])
	
	InputMap.action_add_event(action, event)
	
	create_keys(cursor)
	
	Shared.emit_signal("signal_gamepad", Shared.is_gamepad)

func create_keys(row):
	var r = items[row]
	if r.is_in_group("remap"):
		var action = items[row].action
		
		for i in r.get_node("Keys").get_children():
			i.queue_free()
		
		for i in InputMap.get_action_list(action):
			if is_type(i):
				var k = key.instance()
				r.get_node("Keys").add_child(k)
				
				draw_key(k, i)

func is_type(event):
	var test = !is_gamepad and event is InputEventKey
	if !test:
		test = is_gamepad and (event is InputEventJoypadButton or event is InputEventJoypadMotion)
	
	return test

func reset_to_defaults():
	for action in InputMap.get_actions():
		for event in InputMap.get_action_list(action):
			if is_type(event):
				InputMap.action_erase_event(action, event)
	
	for action in defaults.keys():
		for event in defaults[action]:
			if is_type(event):
				InputMap.action_add_event(action, event)
	
	for i in items.size() - 1:
		create_keys(i)
	
	Shared.emit_signal("signal_gamepad", Shared.is_gamepad)
