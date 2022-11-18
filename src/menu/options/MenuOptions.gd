extends MenuBase

onready var bg := $Control/BG

func _input(event):
	menu_input(event)

func _physics_process(delta):
	menu_process(delta)

func fill_items():
	for i in items_node.get_children():
		if i.is_in_group("window"):
			i.visible = !OS.window_fullscreen
	
	.fill_items()

func open():
	bg.visible = Shared.csfn != Shared.title_path

func accept():
	if items[cursor].has_method("act"):
		audio_accept()
		items[cursor].act()

func back():
	audio_back()
	self.is_open = false
	
	Shared.save_options()

func joy_x(arg := 1):
	if items[cursor].has_method("axis_x"):
		items[cursor].axis_x(arg)

func open_remap(is_gamepad := false):
	MenuRemap.is_gamepad = is_gamepad
	sub_menu(MenuRemap)
