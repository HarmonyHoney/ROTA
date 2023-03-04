extends Scroll

func _ready():
	cursor = Shared.clock_decimals
	set_label()

func set_value():
	Shared.clock_decimals = cursor
	UI.scene_changed(true)
