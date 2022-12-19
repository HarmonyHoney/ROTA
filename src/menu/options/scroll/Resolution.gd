extends Scroll

func _ready():
	list = []
	for i in Shared.win_sizes:
		list.append(str(i.x) + ", " + str(i.y))
	
	var f = Array(Shared.win_sizes).find(Shared.win_size)
	if f != -1:
		cursor = f
		set_label()

func set_value():
	Shared.set_window_size(Shared.win_sizes[cursor])
