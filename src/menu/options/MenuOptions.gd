extends MenuBase

onready var bg := $Control/BG

func fill_items():
	if is_instance_valid(items_node):
		for i in items_node.get_children():
			if i.is_in_group("window"):
				i.visible = !OS.window_fullscreen
				i._ready()
			if i.is_in_group("speed"):
				i.visible = Shared.clock_show > 0
	
	.fill_items()

func set_cursor(a := cursor):
	.set_cursor(a)
	is_audio_joy = cursor > 3

func open():
	bg.visible = Shared.csfn != Shared.title_path

func close():
	Shared.save_options()

func open_remap(is_gamepad := false):
	MenuRemap.is_gamepad = is_gamepad
	sub_menu(MenuRemap)
