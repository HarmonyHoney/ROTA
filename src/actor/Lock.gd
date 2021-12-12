extends StaticBody2D

onready var block : Sprite = $Sprites/Rect
onready var keyhole : Sprite = $Sprites/Keyhole
onready var collision : CollisionShape2D = $CollisionShape2D
onready var animation : AnimationPlayer = $AnimationPlayer

func _ready():
	for i in get_tree().get_nodes_in_group("game_camera"):
		i.connect("turning", self, "turning")
		break

func turning(angle):
	keyhole.rotation = angle

func open():
	collision.set_deferred("disabled", true)
	animation.play("shrink")
