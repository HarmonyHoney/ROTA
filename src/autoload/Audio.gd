extends Node

var dict = {}

func _ready():
	for i in Shared.get_all_children(self):
		dict[str(get_path_to(i)).to_lower().replace("/", "_")] = i
	#print(dict)

func play(arg := "menu_cursor", from := 1.0, to := -1.0):
	if dict.has(arg):
		var a = dict[arg]
		a.pitch_scale = from if to < 0 else rand_range(from, to)
		a.play()
