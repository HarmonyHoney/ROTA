extends Scroll

func _ready():
	cursor = int(OS.window_borderless)
	set_label()

func set_value():
	OS.window_borderless = bool(cursor)
	Shared.set_window_size()

