extends Control

export var is_gamepad := false

func act():
	RemapMenu.is_gamepad = is_gamepad
	RemapMenu.show()
