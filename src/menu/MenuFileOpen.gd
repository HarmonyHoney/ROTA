extends MenuBase

export var sub_path : NodePath
onready var delete_menu = get_node_or_null(sub_path)

func _input(event):
	menu_input(event)

func _physics_process(delta):
	menu_process(delta)

func accept():
	audio_accept()
	if cursor == 0:
		Shared.load_slot(get_parent().cursor)
	elif cursor == 1:
		sub_menu(delete_menu)

func back():
	audio_back()
	self.is_open = false
