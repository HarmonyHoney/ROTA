extends Node2D

onready var sprites = $Sprites
onready var anim = $AnimationPlayer

onready var csf = get_tree().current_scene.filename

var is_collected := false

var player = null

func _ready():
	for i in get_tree().get_nodes_in_group("game_camera"):
		i.connect("turning", self, "turning")
		break
	
	if Shared.goals_collected.has(csf):
		#is_collected = true
		sprites.modulate.a = 0.25

func _physics_process(delta):
	if is_collected and player != null:
		position = position.linear_interpolate(player.position, 0.1)

func turning(angle):
	sprites.rotation = angle

func _on_Area2D_body_entered(body):
	pickup(body)

func pickup(arg):
	if !is_collected:
		is_collected = true
		player = arg
