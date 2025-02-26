extends Scroll

func _ready():
	cursor = int((DisplayServer.window_get_vsync_mode() != DisplayServer.VSYNC_DISABLED))
	set_label()

func set_value():
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if (bool(cursor)) else DisplayServer.VSYNC_DISABLED)
