extends Node

# DOWN
func d(arg : String):
	return int(Input.is_action_pressed(arg))

# PRESSED
func p(arg : String):
	return int(Input.is_action_just_pressed(arg))

# RELEASED
func r(arg : String):
	return int(Input.is_action_just_released(arg))
