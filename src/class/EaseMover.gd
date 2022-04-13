class_name EaseMover

var show := true
var clock := 0.0
var time := 0.5
var from := Vector2.ZERO
var to := Vector2.ZERO
var current := Vector2.ZERO
var node

var is_complete setget , get_complete

func _init(_node := node, _time := time, _from := from, _to := to):
	node = _node
	time = _time
	from = _from
	to = _to

func count(delta, arg := show):
	clock = clamp(clock + (delta if arg else -delta), 0, time)
	return smooth()

func move(delta, arg := show):
	count(delta, arg)
	current = from.linear_interpolate(to, smooth())
	
	if node:
		node.rect_position = current
	
	return current

func frac():
	return clock / time

func smooth():
	return smoothstep(0, 1, clock / time)

func get_complete():
	return clock == time
