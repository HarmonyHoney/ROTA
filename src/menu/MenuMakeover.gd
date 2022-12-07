extends MenuBase

export var palette : PoolColorArray = []

var player

func open():
	print("open makeover")
	
	Cam.turn_offset = Vector2(-100, -10)
	Cam.start_zoom(0, true, 0.4)
	player = Shared.player
	player.joy = Vector2.ZERO
	player.is_input = false

func close():
	print("close makeover")
	Cam.turn_offset = Vector2.ZERO
	Cam.start_zoom(0)
	
	player.is_input = true

func accept():
	match items[cursor].name.to_lower():
		"random":
			random()

func random():
	var l = range(palette.size())
	randomize()
	l.shuffle()
	
	for i in items:
		if i.is_in_group("color"):
			i.cursor = l.pop_back()
			i.set_value()

func pale():
	var l = [2,1,0,16]
	
	for i in l.size():
		items[i].cursor = l[i]
		items[i].set_value()
