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
		items[cursor].act()

func back():
	get_tree().set_input_as_handled()
	self.is_open = false

func joy_x(arg := 1):
	if items[cursor].has_method("axis_x"):
		items[cursor].axis_x(arg)

func open_remap(is_gamepad := false):
	RemapMenu.is_gamepad = is_gamepad
	sub_menu(RemapMenu)
