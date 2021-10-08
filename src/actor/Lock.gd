extends StaticBody2D

onready var block : Sprite = $Sprites/Rect
onready var keyhole : Sprite = $Sprites/Keyhole
onready var collision : CollisionShape2D = $CollisionShape2D

func _ready():
	for i in get_tree().get_nodes_in_group("game_camera"):
		i.connect("set_rotation", self, "set_rotation")
		break

func set_rotation(degrees):
	keyhole.rotation_degrees = degrees

func open():
	collision.set_deferred("disabled", true)
	block.visible = false
