extends CanvasLayer

onready var control := $Control
onready var right := $Control/HBoxRight
onready var top := $Control/HBoxTop

onready var keys := [$Control/HBoxRight/C, $Control/HBoxRight/X]
onready var buttons := [$Control/HBoxRight/C/Control/Button, $Control/HBoxRight/X/Control/Button]

onready var key_z := $Control/HBoxTop/Z
onready var pause := $Control/HBoxTop/Pause
onready var game_hide := [$Control/HBoxRight/C/Control/Key, $Control/HBoxRight/X/Control/Key]
onready var game_show := [key_z, $Control/HBoxRight/C/Control/Sprite, $Control/HBoxRight/X/Control/Sprite]

onready var btns := $Control/HBoxLeft/DPad/Buttons.get_children()
onready var actions := InputMap.get_actions()

func _ready():
	set_game(false)
	visible = false
	
	yield(Shared, "scene_changed")
	visible = Shared.is_touch or ((OS.has_touchscreen_ui_hint() and OS.get_name() == "HTML5") or OS.get_name() == "Android")

func show_keys(arg_arrows := true, arg_c := true, arg_x := true, arg_pause := false, arg_passby := false):
	right.visible = arg_arrows
	keys[0].visible = arg_c
	keys[1].visible = arg_x
	top.visible = arg_pause

func set_game(arg := false):
	
	for h in game_hide:
		h.visible = !arg
	for s in game_show:
		s.visible = arg
	
	if Shared.is_arcade:
		key_z.visible = false
	pause.visible = !Shared.is_title
	
	for a in actions:
		Input.action_release(a)
	
	for f in buttons:
		f.passby_press = arg

func margin(x := 20, y := 20):
	control.margin_left = x
	control.margin_right = -x
	control.margin_top = y
	control.margin_bottom = -y
