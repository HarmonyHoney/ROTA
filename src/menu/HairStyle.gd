extends Scroll

export(String, "back", "front") var order = "back"

func set_value():
	Shared.player.set("hairstyle_" + order, cursor)
