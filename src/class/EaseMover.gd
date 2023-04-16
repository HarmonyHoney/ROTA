class_name EaseMover

var show := true
var clock := 0.0
var time := 0.5
var last := -1.0
var from := Vector2.ZERO
var to := Vector2.ZERO
var current := Vector2.ZERO
var node

var is_complete setget , get_is_complete
var is_last setget , get_is_last

func _init(_time := time, _from := from, _to := to, _node := node):
	time = _time
	from = _from
	to = _to
	node = _node

func count(delta, arg := show, is_smooth := true):
	last = clock
	clock = clamp(clock + (delta if arg else -delta), 0, time)
	return smooth() if is_smooth else (clock / time)

func move(delta, arg := show):
	current = from.linear_interpolate(to, count(delta, arg))
	
	if is_instance_valid(node):
		node.rect_position = current
	
	return current

func from_lerp_to(arg := (clock / time)):
	return from.linear_interpolate(to, arg)

func frac():
	return clock / time

func smooth():
	return smoothstep(0, 1, clock / time)

func get_is_complete():
	return clock == time

func get_is_last():
	return clock == last
