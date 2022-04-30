tool
extends Node2D

onready var petals := $FlowerPetals

export var palette := 0 setget set_palette

func _ready():
	set_palette()

func set_palette(arg := palette):
	palette = arg
	if petals:
		petals.palette = palette
		palette = petals.palette
