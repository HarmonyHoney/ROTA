extends Node2D

onready var sprites := $Sprites
onready var area := $Area2D

var box
var solid_clock := 0.0
var solid_time := 0.1

func _ready():
	sprites.modulate.a = 0.5
	visible = false
	set_physics_process(false)

func _physics_process(delta):
	solid_clock = min(solid_clock + delta, solid_time)
	if solid_clock == solid_time and area.get_overlapping_bodies().size() == 0:
		set_physics_process(false)
		visible = false
		
		box.position = position
		box.set_physics_process(true)

func respawn(angle := 0.0):
	sprites.rotation = angle
	solid_clock = 0
	set_physics_process(true)
	visible = true
