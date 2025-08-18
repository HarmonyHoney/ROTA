extends MenuBase

func fill_items():
	if is_instance_valid(items_node):
		for i in items_node.get_children():
			if i.is_in_group("window"):
				i.visible = !OS.window_fullscreen
				i._ready()
			if i.is_in_group("speed"):
				i.visible = Shared.clock_show > 0
			if i.is_in_group("light"):
				i.visible = Shared.light_enabled > 0
			if i.is_in_group("shadow") and i.visible:
				i.visible = Shared.shadow_enabled > 0
	
	.fill_items()

func row():
	is_audio_joy = cursor == 2 or cursor > 5

func close():
	Shared.save_options()
	UI.scene_changed()

func open_remap(is_gamepad := false):
	MenuRemap.is_gamepad = is_gamepad
	sub_menu(MenuRemap)
