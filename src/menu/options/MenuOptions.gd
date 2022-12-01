extends MenuBase

onready var bg := $Control/BG

func fill_items():
	for i in items_node.get_children():
		if i.is_in_group("window"):
			i.visible = !OS.window_fullscreen
			i._ready()
		if i.is_in_group("speed"):
			i.visible = Shared.clock_show > 0
	
	.fill_items()

func open():
	bg.visible = Shared.csfn != Shared.title_path

func close():
	Shared.save_options()

func accept():
	if items[cursor].has_method("act"):
		items[cursor].act()

func joy_x(arg := 1):
	if items[cursor].has_method("axis_x"):
		items[cursor].axis_x(arg)

func open_remap(is_gamepad := false):
	MenuRemap.is_gamepad = is_gamepad
	sub_menu(MenuRemap)
