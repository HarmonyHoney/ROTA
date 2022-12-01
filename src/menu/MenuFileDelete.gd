extends MenuBase

export var open_path : NodePath
onready var open_menu = get_node_or_null(open_path)

func open():
	cursor = 1

func accept():
	if cursor == 0:
		Shared.erase_slot(get_parent().cursor)
		self.is_open = false
		open_menu.is_open = false
	elif cursor == 1:
		self.is_open = false

