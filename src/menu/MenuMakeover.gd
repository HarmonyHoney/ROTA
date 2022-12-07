extends MenuBase

export var palette : PoolColorArray = []

var last_target = null
var last_pos = Vector2.ZERO

var attract = null

func open():
	print("open makeover")
	
	last_target = Cam.target_node
	last_pos = Cam.target_pos
	
	Cam.target_node = Shared.player
	Cam.turn_offset = Vector2(-100, -10)
	Cam.start_zoom(0, true, 0.4)
	Cam.turn(Shared.player.turn_to)
	
	if is_instance_valid(attract):
		attract.is_active = false
		Shared.player.joy.x = 0

func close():
	print("close makeover")
	Cam.target_node = null if last_target == null else last_target
	Cam.target_pos = last_pos
	Cam.turn_offset = Vector2.ZERO
	Cam.start_zoom(0)
	Cam.turn(0)
	
	if is_instance_valid(attract):
		attract.is_active = true
		Shared.player.joy.x = 1 if randf() > 0.5 else -1
