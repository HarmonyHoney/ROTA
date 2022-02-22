extends Node2D

onready var sprite := $Sprite

var box : Box = null
var is_deploy := false
var last_deploy := false

var open_clock := 0.0
var open_time := 0.3

var z_start = 30
#var z_in_front = 36

var _delta := 1.0 / 60.0

func _ready():
	visible = false
	
	get_tree().connect("idle_frame", self, "place")

func _physics_process(delta):
	_delta = delta

func set_box(b):
	is_deploy = is_instance_valid(b)
	if is_deploy:
		#box_z(z_start)
		box = b
		#box_z(z_index + 1)
		place()

func box_z(arg):
	if is_instance_valid(box):
		box.z_index = arg

func place():
	open_clock = clamp(open_clock + (_delta if is_deploy else -_delta), 0, open_time)
	
	visible = open_clock > 0
	if visible:
		var s = smoothstep(0, 1, open_clock / open_time)
		#sprite.scale.x = s#clamp(s, 0, box.sprite.scale.x)
		sprite.material.set_shader_param("scale_x", s)
		sprite.material.set_shader_param("scale_y", s)
		
		if is_instance_valid(box):
			rotation = box.sprite.rotation
			position = box.sprite.global_position
			scale.x = box.sprite.scale.x
