extends Node2D

onready var sprites = $Sprites
onready var circle := $Sprites/Circle
onready var gem := $Sprites/Gem

onready var start_pos := position

var is_collected := false

var player = null


var p1_clock := 0.0
var p1_time := 1.0

var p2_clock := 0.0
var p2_time := 0.3

var p3_clock := 0.0
var p3_time := 0.5

func _enter_tree():
	Shared.goal = self

func _ready():
	Shared.camera.connect("turning", self, "turning")
	
	if Shared.goals_collected.has(Shared.csfn):
		#is_collected = true
		sprites.modulate.a = 0.25
	
	circle.scale = Vector2.ZERO

func _physics_process(delta):
	if is_collected and player != null:
		if p1_clock < p1_time:
			p1_clock = min(p1_clock + delta, p1_time)
			var s = smoothstep(0, 1, p1_clock / p1_time)
			position = start_pos.linear_interpolate(player.position + player.rot(Vector2(0, -100)), s)
			circle.scale = Vector2.ONE * lerp(0, 6.0, s)
		elif p2_clock < p2_time:
			p2_clock = min(p2_clock + delta, p2_time)
			var s = smoothstep(0, 1, p2_clock / p2_time)
			gem.scale = Vector2.ONE * lerp(2.0, 1.0, s)
			
			if p2_clock == p2_time:
				player.set_physics_process(true)
				gem.z_as_relative = false
		else:
			#if p3_clock < p3_time:
			p3_clock = min(p3_clock + delta, p3_time)
			var s = smoothstep(0, 1, p3_clock / p3_time)
			circle.scale = Vector2.ONE * lerp(6.0, 3.0, s)
			
			var target = player.position + player.rot(Vector2.UP * 20)
			
			position = position.linear_interpolate(target, 0.1)
			
			#var dist = 100
			#if position.distance_to(target) > dist:
			#	position = target + ((position - target).normalized() * dist)

func turning(angle):
	sprites.rotation = angle

func _on_Area2D_body_entered(body):
	pickup(body)

func pickup(arg):
	if is_collected: return
	
	is_collected = true
	player = arg
	
	player.set_physics_process(false)
	player.anim.play("idle")
	player.velocity = Vector2.ZERO
	
	gem.z_as_relative = true
	#z_index = 90
	#sprites.modulate = Color.white
	
#	var p = $Sprites/Gem/Polygon2D
#	var p2 = $Sprites/Gem/Polygon2D/Polygon2D
#	for i in [p, p2]:
#		i.color = Color.white - i.color
#		i.color.a = 1.0
	
	
	
