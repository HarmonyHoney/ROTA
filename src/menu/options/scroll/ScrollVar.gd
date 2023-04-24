extends Scroll

export var var_name := "shadow_enabled"
export var is_frac := false
export var is_int := false

func _ready():
	cursor = clamp(int(Shared.get(var_name)), 0.0, list.size() - 1)
	if is_frac: cursor = (cursor * list.size()) - 1
	elif is_int: cursor = max(0, list.find(str(cursor)))
	set_label()

func set_value():
	Shared.set(var_name, (float(cursor + 1) / list.size()) if is_frac else int(list[cursor]) if is_int else cursor)
