tool
extends Control

export var text := "" setget set_text
export var action := "" setget set_action

var event : InputEvent = null


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

func _ready():
	self.text = text

func parse_event(_event : InputEvent):
	event = _event
	
	var s = " "
	if event is InputEventJoypadButton:
		s = "JOY " + str(event.button_index)
	elif event is InputEventJoypadMotion:
		var sgn = "+" if event.axis_value > 0 else "-"
		s = "AXIS " + str(event.axis) + sgn
	elif event is InputEvent:
		s = str(event.as_text().to_upper())
	
	self.text = s

func set_text(arg := text):
	text = arg
	if !label: return
	
	# sprite
	if tex.has(text):
		label.visible = false
		
		sprite.texture = tex[text]
		if rotate.has(text):
			sprite.rotation_degrees = rotate[text]
	
	# text over key
	else:
		label.text = text.to_lower().capitalize()
		
		var size = font.get_string_size(text)
		var text_scale = clamp(90 / size.x, 0.1, 1.0)
		center.scale = Vector2.ONE * text_scale
		
		var check = text.length() < 2
		sprite.texture = tex_key if check else tex_key_2
		rect_min_size.x = 50 if check else 100
		rect_size = rect_min_size
		offset.rect_position.x = 25 if check else 50

func set_action(arg := action):
	action = arg
	
	if action != "" and InputMap.has_action(action):
		var l = InputMap.get_action_list(action)
		if l.size() > 0:
			parse_event(l.back())
	
