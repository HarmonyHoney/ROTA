extends Control

export var is_gamepad := false

func act():
	OptionsMenu.open_remap(is_gamepad)
