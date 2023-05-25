extends MenuBase

onready var palette : PoolColorArray = Shared.player.palette
var player
onready var hair_fronts : int = Shared.player.hair_fronts.size()
onready var hair_backs : int = Shared.player.hair_backs.size()

var pale = [3,2,2,1,0,16]

onready var arrows := $Center/Control/Dialog/Arrows.get_children()
export var arrow_margin := Vector2.ZERO

func row():
	if !arrows: return
	var c = items[cursor]
	arrows[0].rect_position = c.rect_position - Vector2(30, 0) + (arrow_margin * Vector2(-1, 1))
	arrows[1].rect_position = c.rect_position + Vector2(c.rect_size.x, 0) + arrow_margin
	
	for i in arrows:
		i.visible = cursor < items.size() - 1

func open():
	Cam.turn_offset = Vector2(-100, -10)
	Cam.start_zoom(0, true, 0.4)
	player = Shared.player
	if is_instance_valid(player):
		player.joy = Vector2.ZERO
		player.is_input = false
		palette = Shared.player.palette
		match_player()

func close():
	Cam.turn_offset = Vector2.ZERO
	Cam.start_zoom(0)
	
	player.is_input = true

func accept():
	match items[cursor].name.to_lower():
		"random":
			random()
		"preset":
			preset()

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

func match_player():
	outfit([player.hairstyle_front, player.hairstyle_back, player.dye["hair"], player.dye["eye"], player.dye["skin"], player.dye["fit"]])

func preset():
	randomize()
	var front = (randi() % (hair_fronts - 1)) + 1
	var back = randi() % hair_backs
	
	var skin = 4 + (randi() % 5)
	var c = range(palette.size())
	c.erase(skin)
	c.shuffle()
	
	outfit([front, back, c[0], c[1], skin, c[2]])
