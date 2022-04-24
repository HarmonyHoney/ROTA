extends MenuBase

func _input(event):
	menu_input(event)

func _physics_process(delta):
	menu_process(delta)

func accept():
	match items[cursor].name.to_lower():
		"play":
			Shared.load_data()
		"options":
			sub_menu(OptionsMenu)
		"exit":
			get_tree().quit()
