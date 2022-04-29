tool
extends Node2D
class_name PaletteSwap

export var palette := 0 setget set_palette
export var colors : PoolColorArray = ["FFF", "5DFF00", "7ee356", "FFC6E9", "79FFFF", "FFC900"]

export var sprite_path : NodePath
onready var sprite := get_node_or_null(sprite_path)

func _ready():
	set_palette()

func set_palette(arg := palette):
	palette = posmod(int(arg), colors.size())
	if sprite:
		sprite.modulate = colors[palette]

