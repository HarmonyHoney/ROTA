extends MenuBase

export var sub_path : NodePath
onready var file_menu = get_node_or_null(sub_path)

export var credits_path : NodePath
onready var credits_menu = get_node_or_null(credits_path)

var pos = Vector2(1800, 650)

func _input(event):
	menu_input(event)

func _physics_process(delta):
	menu_process(delta)

func accept():
	audio_accept()
	match items[cursor].name.to_lower():
		"play":
			sub_menu(file_menu)
			Cam.target_pos = pos + Vector2(350, 0)
		"options":
			sub_menu(MenuOptions)
			Cam.target_pos = pos + Vector2(950, 0)
		"credits":
			sub_menu(credits_menu)
			Cam.target_pos = pos + Vector2(350, 0)
		"store":
			Shared.store_page()
		"exit":
			Shared.quit()

func open():
	Cam.target_pos = pos - Vector2(150, 0)

func back():
	audio_back()
	self.is_open = false
	Cam.target_pos = pos
