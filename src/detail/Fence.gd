tool
extends Node2D

export var length := 3 setget set_length
export var is_offset := false setget set_offset


func set_length(arg):
	length = max(1, abs(arg))
	if $Sprite:
		$Sprite.region_rect.size.x = 200 * length

func set_offset(arg : bool):
	is_offset = arg
	if $Sprite:
		$Sprite.region_rect.position.x = 200 * int(is_offset)
