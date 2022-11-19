extends OnOff

func _ready():
	is_on = Input.mouse_mode == Input.MOUSE_MODE_VISIBLE
	set_label()

func set_value():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if is_on else Input.MOUSE_MODE_HIDDEN

