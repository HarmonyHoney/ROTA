extends MenuBase

export var open_path : NodePath
onready var open_menu = get_node(open_path)

func _input(event):
	menu_input(event)

func _physics_process(delta):
	menu_process(delta)

func set_open(arg := is_open):
	.set_open(arg)
	
	self.cursor = 1

func back():
	self.is_open = false

func accept():
	if cursor == 0:
		Shared.erase_slot(get_parent().cursor)
		back()
		open_menu.back()
	elif cursor == 1:
		back()
