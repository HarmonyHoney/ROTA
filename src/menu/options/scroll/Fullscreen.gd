extends Scroll

func _ready():
	cursor = int(OS.window_fullscreen)
	set_label()

func set_value():
	if cursor != int(OS.window_fullscreen):
		Shared.toggle_fullscreen()
