extends MenuBase

export var palette : PoolColorArray = []

func joy_x(arg := 1):
	if items[cursor].has_method("axis_x"):
		items[cursor].axis_x(arg)
