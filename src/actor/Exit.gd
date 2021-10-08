extends Node2D

onready var sprite : Sprite = $Sprite

func _ready():
	for i in get_tree().get_nodes_in_group("game_camera"):
		i.connect("set_rotation", self, "set_rotation")
		break

func set_rotation(degrees):
	sprite.rotation_degrees = degrees

