extends Node2D

onready var sprites = $Sprites
onready var anim = $AnimationPlayer

onready var csf = get_tree().current_scene.filename

var is_collected := false

func _ready():
	for i in get_tree().get_nodes_in_group("game_camera"):
		i.connect("turning", self, "turning")
		break
	
	if Shared.goals_collected.has(csf):
		pickup()

func turning(angle):
	sprites.rotation = angle

func _on_Area2D_body_entered(body):
	pickup()

func pickup():
	if !is_collected:
		is_collected = true
		sprites.modulate.a = 0.25
