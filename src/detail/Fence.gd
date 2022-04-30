tool
extends Node2D

export var length := 3 setget set_length
export var is_offset := false setget set_offset

var width := 100

func set_length(arg):
	length = max(1, abs(arg))
	if $Sprite:
		$Sprite.region_rect.size.x = width * length

func set_offset(arg : bool):
	is_offset = arg
	if $Sprite:
		$Sprite.region_rect.position.x = width * int(is_offset)
