#tool
extends Control

export var text := "" setget set_text
export var action := "" setget set_action
export var is_gamepad := false setget set_gamepad
export var is_connect := false setget set_connect
export var is_shrink := false setget set_shrink

onready var offset := $Offset
onready var sprite := $Offset/Sprite
onready var center := $Offset/Center
onready var label := $Offset/Center/Label
onready var font : Font = label.get("custom_fonts/font")

var tex_key = preload("res://media/image/box/round_rect200.png")
var tex_key_2 = preload("res://media/image/UI/key_2.png")

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
"AXIS 0-": preload("res://media/image/UI/l_stick_left.png"),
"AXIS 0+": preload("res://media/image/UI/l_stick_right.png"),
"AXIS 1-": preload("res://media/image/UI/l_stick_up.png"),
"AXIS 1+": preload("res://media/image/UI/l_stick_down.png"),
"AXIS 2-": preload("res://media/image/UI/r_stick_left.png"),
"AXIS 2+": preload("res://media/image/UI/r_stick_right.png"),
"AXIS 3-": preload("res://media/image/UI/r_stick_up.png"),
"AXIS 3+": preload("res://media/image/UI/r_stick_down.png"),
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

var short = {KEY_CONTROL : "Ctrl",
KEY_DELETE: "Del",
KEY_BRACELEFT: "[",
KEY_BRACERIGHT: "]",
KEY_SEMICOLON: ";",
KEY_APOSTROPHE: "'",
KEY_BACKSLASH: "\\",
KEY_SLASH: "/",
KEY_QUOTELEFT: "`",
KEY_MINUS: "-",
KEY_EQUAL: "=",
KEY_CAPSLOCK: "Caps",
KEY_ESCAPE: "Esc",
KEY_COMMA: ",",
KEY_PERIOD: ".",}

func _ready():
	self.text = text

func is_type(event):
	var test = !is_gamepad and event is InputEventKey
	if !test:
		test = is_gamepad and (event is InputEventJoypadButton or event is InputEventJoypadMotion)
	
	return test

func parse_event(event : InputEvent):
	var s = " "
	if event is InputEventJoypadButton:
		s = "JOY " + str(event.button_index)
	elif event is InputEventJoypadMotion:
		var sgn = "+" if event.axis_value > 0 else "-"
		s = "AXIS " + str(event.axis) + sgn
	elif event is InputEvent:
		if event is InputEventKey and short.has(event.scancode):
			s = short[event.scancode]
		else:
			s = str(event.as_text().to_upper())
	
	self.text = s

func set_text(arg := text):
	text = arg
	if !label or text == "": return
	
	offset.rect_scale = Vector2.ONE
	
	# sprite
	if tex.has(text):
		label.visible = false
		
		sprite.texture = tex[text]
		sprite.rotation_degrees = rotate[text] if rotate.has(text) else 0
		
		rect_min_size.x = 50
		rect_size = rect_min_size
		offset.rect_position.x = 25
	
	# text over key
	else:
		label.visible = true
		label.text = text.to_lower().capitalize()
		
		var size = font.get_string_size(text)
		var text_scale = clamp(90 / size.x, 0.1, 1.0)
		center.scale = Vector2.ONE * text_scale
		
		var check = text.length() < 2
		sprite.texture = tex_key if check else tex_key_2
		sprite.rotation_degrees = 0
		
		rect_min_size.x = 50 if check else 100
		rect_size = rect_min_size
		offset.rect_position.x = 25 if check else 50
		
		if is_shrink and !check:
			offset.rect_scale = Vector2.ONE * 0.5
	
	set_shrink()

func set_action(arg := action):
	action = arg
	
	if action != "" and InputMap.has_action(action):
		var l = InputMap.get_action_list(action)
		
		# gamepad or keyboard
		var e = null
		for i in l:
			if is_type(i):
				e = i
		if e:
			parse_event(e)

func set_gamepad(arg := is_gamepad):
	is_gamepad = arg
	set_action()

func set_connect(arg := is_connect):
	is_connect = arg
	
	if is_connect:
		Shared.connect("gamepad_input", self, "set_gamepad")
	else:
		Shared.disconnect("gamepad_input", self, "set_gamepad")
	
	self.is_gamepad = Shared.is_gamepad

func set_shrink(arg := is_shrink):
	is_shrink = arg
	
