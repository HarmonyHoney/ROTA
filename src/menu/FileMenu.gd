extends MenuBase

onready var file_open := $FileOpen

func _input(event):
	menu_input(event)

func _physics_process(delta):
	menu_process(delta)

func back():
	self.is_open = false

func accept():
	if items[cursor].is_new:
		Shared.load_slot(cursor)
	else:
		sub_menu(file_open)
