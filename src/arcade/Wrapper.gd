extends Node2D

export var image_path : NodePath = ""
onready var image_node := get_node_or_null(image_path)
var spr_list := []
var room_size := Vector2(600, 600)
var vec = []

func _ready():
	process_priority = 1
	
	spr_list = []
	for i in 8:
		var s = image_node.duplicate()
		add_child(s)
		spr_list.append(s)
	
	# mirrors
	vec = []
	for x in [-1, 0, 1]:
		for y in [-1, 0, 1]:
			if !(x == 0 and y == 0):
				vec.append(Vector2(x, y))

func _physics_process(delta):
	if !is_instance_valid(image_node): return
	
	var sg = image_node.global_position
	var add = Vector2(room_size.x, room_size.y) * 2.0
	
	for i in spr_list.size():
		spr_list[i].scale = image_node.global_scale
		spr_list[i].rotation = image_node.global_rotation
		spr_list[i].global_position = sg + (add * vec[i])
