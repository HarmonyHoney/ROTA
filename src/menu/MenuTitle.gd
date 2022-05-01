extends MenuBase

export var sub_path : NodePath
onready var file_menu = get_node_or_null(sub_path)

export var credits_path : NodePath
onready var credits_menu = get_node_or_null(credits_path)

func _input(event):
	menu_input(event)

func _physics_process(delta):
	menu_process(delta)

func accept():
	audio_accept()
	match items[cursor].name.to_lower():
		"play":
			sub_menu(file_menu)
		"options":
			sub_menu(MenuOptions)
		"credits":
			sub_menu(credits_menu)
		"exit":
			Shared.quit()

func back():
	audio_back()
	self.is_open = false
