extends MenuBase

onready var item_window_size := $Control/Menu/List/Resolution

func _input(event):
	menu_input(event)

func _physics_process(delta):
	menu_process(delta)

func fill_items():
	if item_window_size:
		item_window_size.visible = !OS.window_fullscreen
	.fill_items()

func accept():
	if items[cursor].has_method("act"):
		audio_accept()
		items[cursor].act()

func back():
	audio_back()
	self.is_open = false

func joy_x(arg := 1):
	if items[cursor].has_method("axis_x"):
		items[cursor].axis_x(arg)

func open_remap(is_gamepad := false):
	MenuRemap.is_gamepad = is_gamepad
	sub_menu(MenuRemap)
