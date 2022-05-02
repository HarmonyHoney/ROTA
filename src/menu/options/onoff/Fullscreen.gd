extends OnOff

func _ready():
	is_on = OS.window_fullscreen
	set_label()

func set_value():
	Shared.toggle_fullscreen()
	MenuOptions.fill_items()
