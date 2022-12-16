extends MenuBase

export var palette : PoolColorArray = []

var player

var pale = [3,2,2,1,0,16]

func open():
	#print("open makeover")
	Cam.turn_offset = Vector2(-100, -10)
	Cam.start_zoom(0, true, 0.4)
	player = Shared.player
	player.joy = Vector2.ZERO
	player.is_input = false

func close():
	#print("close makeover")
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
		if i.is_in_group("color") or i.is_in_group("hair"):
			i.cursor = l.pop_back() if i.is_in_group("color") else randi() % (i.count + 1)

func outfit(l := pale):
	for i in l.size():
		items[i].cursor = l[i]

func preset(l := pale):
	var h = [[0,8], [1,9], [2,3], [2,7], [3,2], [3,4], [4,1], [5,1], [6,5]]
	h.shuffle()
	
	var skin = [4,5,6]
	skin.shuffle()
	
	var c = range(palette.size())
	c.erase(skin[0])
	c.shuffle()
	
	outfit([h[0][0], h[0][1], c[0], skin[0], c[1], c[2]])
