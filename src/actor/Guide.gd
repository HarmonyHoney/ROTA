extends Line2D

var box : Box = null

func _physics_process(delta):
	if is_instance_valid(box):
		rotation = box.arrow.rotation
		position = box.sprite.global_position

func set_box(b):
	box = b
