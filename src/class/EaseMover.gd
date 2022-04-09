class_name EaseMover

var show := true
var clock := 0.0
var time := 0.5
var from := Vector2.ZERO
var to := Vector2.ZERO
var node

func _init(_node := node, _time := time, _from := from, _to := to):
	node = _node
	time = _time
	from = _from
	to = _to

func count(delta, arg := show):
	clock = clamp(clock + (delta if arg else -delta), 0, time)
	return smoothstep(0, 1, frac())

func move(delta, arg := show):
	if node:
		node.rect_position = from.linear_interpolate(to, count(delta, arg))

func frac():
	return clock / time
