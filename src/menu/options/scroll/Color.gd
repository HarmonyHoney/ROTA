extends Scroll

export (String, "hair", "skin", "fit", "eye") var part := "hair"

func set_value():
	var s = "color_" + part
	if cursor < MenuMakeover.palette.size():
		var a = Shared.player.get(s)
		
		for i in a:
			i.modulate = MenuMakeover.palette[cursor]
			label.modulate = i.modulate

