extends Scroll

func _ready():
	cursor = int(((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN)))
	set_label()

func set_value():
	if cursor != int(((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN))):
		Shared.toggle_fullscreen()
