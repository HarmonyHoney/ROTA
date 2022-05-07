tool
extends Node2D

export var length := 3 setget set_length
export var is_offset := false setget set_offset

var width := 100

onready var sprite := $Sprite

func _ready():
	set_length()
	set_offset()

func set_length(arg := length):
	length = max(1, abs(arg))
	if sprite:
		sprite.region_rect.size.x = width * length

func set_offset(arg := is_offset):
	is_offset = arg
	if sprite:
		sprite.region_rect.position.x = width * int(is_offset)
