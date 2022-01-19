extends Line2D

var box : Box = null

func _ready():
	visible = false

func _physics_process(delta):
	if visible:
		place()

func set_box(b):
	box = b
	visible = is_instance_valid(box)
	if visible:
		place()

func place():
	rotation = box.sprite.rotation
	position = box.sprite.global_position
	scale.x = box.sprite.scale.x
