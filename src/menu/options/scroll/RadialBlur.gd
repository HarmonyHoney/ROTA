extends Scroll

func _ready():
	cursor = Shared.radial_blur
	set_label()

func set_value():
	Shared.radial_blur = cursor
