extends Node2D

var box : Box = null

var open_clock := 0.0
var open_time := 0.3

onready var sprite := $Sprite

var is_deploy := false

func _ready():
	visible = false

func _physics_process(delta):
	open_clock = clamp(open_clock + (delta if is_deploy else -delta), 0, open_time)
	
	visible = open_clock > 0
	if visible:
		var s = smoothstep(0, 1, open_clock / open_time)
		sprite.scale.x = s
		if is_instance_valid(box):
			place()

func set_box(b):
	is_deploy = is_instance_valid(b)
	if is_deploy:
		box = b
		place()

func place():
	rotation = box.sprite.rotation
	position = box.sprite.global_position
	scale.x = box.sprite.scale.x
