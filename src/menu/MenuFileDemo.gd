extends MenuBase

func _input(event):
	menu_input(event)

func _physics_process(delta):
	menu_process(delta)

func accept():
	audio_accept()
	self.is_open = false

func back():
	audio_back()
	self.is_open = false
