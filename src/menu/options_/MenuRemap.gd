extends MenuBase

onready var control := $Control

onready var prompt_ease := EaseMover.new($Control/Prompt)
var is_prompt := false
onready var prompt_key := $Control/Prompt/VBoxContainer/Key
onready var prompt_timer_label := $Control/Prompt/VBoxContainer/Timer
var prompt_clock := 0.0
var prompt_time := 5.0
var is_button := false

onready var key = preload("res://src/menu/Options/Key.tscn")

export var is_gamepad := false

onready var header := $Control/Header
onready var header_back := $Control/Header/Back
onready var header_ease := EaseMover.new(null, 0.2)
onready var header_track := $Control/Menu/List/Spacer

var defaults := {}

func _ready():
	# get default binds
	defaults = Shared.default_keys.duplicate()

func _input(event):
	if !is_open: return
	
	# prompt input
	if is_prompt:
		if event.is_action_pressed("ui_pause"):
			is_prompt = false
		elif event.is_pressed() and is_type(event) and !event.is_action("ui_end") and !event.is_echo():
			assign_key(items[cursor].action, event)
			is_prompt = false
			get_tree().set_input_as_handled()
			audio_accept()
	# clear key
	elif event.is_action_pressed("ui_end"):
		clear_row(cursor)
		Audio.play(Audio.menu_accept, 0.8, 1.2)
	# menu input
	else:
		menu_input(event)

func _physics_process(delta):
	menu_process(delta)
	
	if is_prompt:
		prompt_clock -= delta
		prompt_timer_label.text = str(ceil(max(0, prompt_clock)))
		
		if prompt_clock < 0:
			is_prompt = false
	
	prompt_ease.count(delta, is_prompt)
	prompt_ease.node.modulate.a = lerp(0, 1, prompt_ease.clock / prompt_ease.time)
	prompt_ease.node.visible = prompt_ease.clock > 0
	
	#if !is_open: return
	
	# header position
	header.rect_global_position.y = clamp(header_track.rect_global_position.y, 30, 1280)
	
	# header back
	header_ease.show  = header.rect_global_position.y == 30
	header_ease.count(delta)
	header_back.modulate.a = lerp(0, 1.0, header_ease.frac())

func accept():
	audio_accept()
	if items[cursor].is_in_group("reset"):
		reset_to_defaults()
	elif items[cursor].is_in_group("remap"):
		is_prompt = true
		prompt_key.text = items[cursor].text
		prompt_clock = prompt_time
		get_tree().set_input_as_handled()

func back():
	audio_back()
	self.is_open = false
	Shared.save_keys()

func set_open(arg := is_open):
	.set_open(arg)
	
	if is_open:
		# create keys
		for i in items.size():
			create_keys(i)
		
		# header text
		$Control/Menu/List/Title.text = ("Controller" if is_gamepad else "Keyboard") + " Setup"
	else:
		# remove keys
		for i in items.size():
			remove_keys(i)

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
	# remove event if present
	if InputMap.action_has_event(action, event):
		InputMap.action_erase_event(action, event)
	# add event to action, will bring to front of list if present
	InputMap.action_add_event(action, event)
	
	# keep action size to 4 events of type
	var list = []
	for i in InputMap.get_action_list(action):
		if is_type(i):
			list.append(i)
	
	if list.size() > 4:
		InputMap.action_erase_event(action, list[0])
	
	create_keys(cursor)
	
	Shared.emit_signal("signal_gamepad", Shared.is_gamepad)

func create_keys(row):
	var r = items[row]
	if key and r.is_in_group("remap"):
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
