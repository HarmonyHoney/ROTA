class_name EaseMover

var show := true
var clock := 0.0
var time := 0.5
var from := Vector2.ZERO
var to := Vector2.ZERO
var node

func count(delta, arg := show):
	clock = clamp(clock + (delta if arg else -delta), 0, time)
	return smoothstep(0, 1, clock / time)

func move(delta, arg := show):
	var s = count(delta, arg)
	node.rect_position = from.linear_interpolate(to, s)
