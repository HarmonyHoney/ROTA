extends Control

export var is_gamepad := false

func act():
	MenuOptions.open_remap(is_gamepad)
