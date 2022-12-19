extends Scroll

func _ready():
	cursor = int(OS.vsync_enabled)
	set_label()

func set_value():
	OS.vsync_enabled = bool(cursor)
