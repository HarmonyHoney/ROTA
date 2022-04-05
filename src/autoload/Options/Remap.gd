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
"JOY 13": preload("res://media/image/UI/dpad_down.png"),
"JOY 14": preload("res://media/image/UI/dpad_left.png"),
"JOY 15": preload("res://media/image/UI/dpad_right.png"),
"AXIS 1-": preload("res://media/image/UI/l_stick_up.png"),
"AXIS 1+": preload("res://media/image/UI/l_stick_down.png"),
"AXIS 0-": preload("res://media/image/UI/l_stick_left.png"),
"AXIS 0+": preload("res://media/image/UI/l_stick_right.png"),
"AXIS 2-": preload("res://media/image/UI/r_stick_up.png"),
"AXIS 2+": preload("res://media/image/UI/r_stick_down.png"),
"AXIS 3-": preload("res://media/image/UI/r_stick_left.png"),
"AXIS 3+": preload("res://media/image/UI/r_stick_right.png")}

func _ready():
	var a = InputMap.get_action_list(action)
	
	var sort = []
	for i in a:
		if i is InputEventJoypadButton or i is InputEventJoypadMotion:
			sort.push_back(i)
		else:
			sort.push_front(i)
	a = sort
	
	for i in 4:
		var s = " "
		if i < a.size():
			if a[i] is InputEventJoypadButton:
				s = "JOY " + str(a[i].button_index)
			elif a[i] is InputEventJoypadMotion:
				var av = a[i].axis_value
				var sgn = "+" if av > 0 else "-"
				s = "AXIS " + str(a[i].axis) + sgn
			else:
				s = str(a[i].as_text())
		
		var l = s
		
		if dict.has(s):
			l = dict[s]
		
		var label = list[i].get_node("Label")
		label.text = l
		
		
		var spr = list[i].get_node("Sprite")
		spr.visible = tex.has(s)
		label.visible = !spr.visible
		
		if spr.visible:
			spr.texture = tex[s]
		
		
		
