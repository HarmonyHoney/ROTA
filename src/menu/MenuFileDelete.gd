extends MenuBase

export var open_path : NodePath
onready var open_menu = get_node_or_null(open_path)

func _input(event):
	menu_input(event)

func _physics_process(delta):
	menu_process(delta)

func set_open(arg := is_open):
	.set_open(arg)
	
	cursor = 1

func accept():
	audio_accept()
	if cursor == 0:
		Shared.erase_slot(get_parent().cursor)
		self.is_open = false
		open_menu.is_open = false
	elif cursor == 1:
		self.is_open = false

func back():
	audio_back()
	self.is_open = false
