extends Control

export var action := ""

onready var list = $HBoxContainer.get_children()

var dict = {"JOY 0": "JOY A",
"JOY 1": "JOY B",
"JOY 2": "JOY X",
"JOY 3": "JOY Y",
"JOY 4": "JOY LB",
"JOY 5": "JOY RB",
"JOY 6": "JOY LT",
"JOY 7": "JOY RT",
"JOY 8": "L Stick In",
"JOY 9": "R Stick In",
"JOY 10": "Select",
"JOY 11": "Start",
"JOY 12": "D-Pad Up",
"JOY 13": "D-Pad Down",
"JOY 14": "D-Pad Left",
"JOY 15": "D-Pad Right",
"JOY 16": "JOY Home",
"JOY 17": "JOY Share",
"AXIS 1-": "L Stick Up",
"AXIS 1+": "L Stick Down",
"AXIS 0-": "L Stick Left",
"AXIS 0+": "L Stick Right",
"AXIS 2-": "R Stick Up",
"AXIS 2+": "R Stick Down",
"AXIS 3-": "R Stick Left",
"AXIS 3+": "R Stick Right",
"AXIS 6+": "JOY LT+",
"AXIS 7+": "JOY RT+"}


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
"RIGHT": preload("res://media/image/UI/key_up.png"),
}

var rotate = {"DOWN": 180,
"LEFT": 270,
"RIGHT": 90,
"JOY 13": 180,
"JOY 14": 270,
"JOY 15": 90,}


func _ready():
	if action != "":
		set_keys()

func set_keys():
	var joy = []
	var keys = []
	for i in InputMap.get_action_list(action):
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
		
		var label = list[i].get_node("Label")
		label.visible = true
		var spr = list[i].get_node("Sprite")
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
		
		
