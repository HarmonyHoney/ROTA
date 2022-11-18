extends Scroll

func _ready():
	cursor = (Shared.clock_alpha * list.size()) - 1
	set_label()

func set_value():
	Shared.clock_alpha = float(cursor + 1) / list.size() 
	UI.clock.modulate.a = Shared.clock_alpha
