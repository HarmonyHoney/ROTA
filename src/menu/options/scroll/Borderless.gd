extends Scroll

func _ready():
	cursor = int(get_window().borderless)
	set_label()

func set_value():
	get_window().borderless = bool(cursor)
	Shared.set_window_size()

