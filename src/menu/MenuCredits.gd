extends MenuBase


func _input(event):
	menu_input(event)

func _physics_process(delta):
	menu_process(delta)

func back():
	self.is_open = false
