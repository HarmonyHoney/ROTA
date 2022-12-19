extends Scroll

func _ready():
	cursor = int(Input.mouse_mode == Input.MOUSE_MODE_VISIBLE)
	set_label()

func set_value():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if bool(cursor) else Input.MOUSE_MODE_HIDDEN

