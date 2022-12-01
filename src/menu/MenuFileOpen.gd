extends MenuBase

export var sub_path : NodePath
onready var delete_menu = get_node_or_null(sub_path)

export var demo_path : NodePath
onready var demo_menu = get_node_or_null(demo_path)

func accept():
	if cursor == 0:
		if Shared.load_slot(get_parent().cursor):
			is_open = false
		else:
			sub_menu(demo_menu)
	elif cursor == 1:
		sub_menu(delete_menu)
