extends Node2D

onready var arrow := $Arrow

export var dir := 0

export var door_path : NodePath
onready var door_node := get_node_or_null(door_path)

func _ready():
	MenuMakeover.connect("closed", self, "closed")
	
	arrow.dir = posmod(dir, 4)

func _on_Arrow_open():
	MenuMakeover.is_open = true
	arrow.is_locked = true

func closed():
	arrow.is_locked = false
	
	if is_instance_valid(Shared.door_in):
		Shared.door_in.visible = true
		Shared.door_in.arrow.is_locked = false
