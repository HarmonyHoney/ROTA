extends OnOff

func _ready():
	is_on = OS.vsync_enabled
	set_label()

func set_value():
	OS.vsync_enabled = is_on
