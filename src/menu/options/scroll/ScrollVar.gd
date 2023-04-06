extends Scroll

export var var_name := "shadow_enabled"
export var is_frac := false

func _ready():
	cursor = Shared.get(var_name)
	if is_frac: cursor = (cursor * list.size()) - 1
	set_label()

func set_value():
	Shared.set(var_name, (float(cursor + 1) / list.size()) if is_frac else cursor)
