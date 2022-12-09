extends Scroll

export(String, "Back", "Front") var order = "Back"

export(Array, String, FILE) var scenes := []

func set_value():
	if Shared.player.color_hair.size() > 0:
		var h = Shared.player.color_hair[0]
		
		for i in h.get_children():
			if order in i.name:
				i.queue_free()
		
		var s = load(scenes[cursor]).instance()
		s.name = order
		h.add_child(s)
		s.owner = h
