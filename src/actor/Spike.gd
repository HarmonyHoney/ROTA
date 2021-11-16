tool
extends Node2D

export var dir := 0 setget set_dir

func set_dir(arg):
	dir = posmod(arg, 4)
	rotation_degrees = dir * 90

func set_tile(left := true):
	if left:
		$Sprites/Left/Tile.visible = true
	else:
		$Sprites/Right/Tile.visible = true
