extends OnOff

func _ready():
	is_on = OS.window_borderless
	set_label()

func set_value():
	OS.window_borderless = is_on
	Shared.set_window_size()

