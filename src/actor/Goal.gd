extends Node2D

onready var sprites = $Sprites
onready var gem := $Sprites/Gem
onready var area = $Area2D
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

func _physics_process(delta):
	if is_collected and player != null:
		
		if player.is_goal:
			player.spr_hand_l.global_position = sprites.to_global(Vector2(-20, 20))
			player.spr_hand_r.global_position = sprites.to_global(Vector2(20, 20))
		
		if p1_clock < p1_time:
			p1_clock = min(p1_clock + delta, p1_time)
			var s = smoothstep(0, 1, p1_clock / p1_time)
			position = start_pos.linear_interpolate(player.position + player.rot(Vector2(0, -100)), s)
			#circle.scale = Vector2.ONE * lerp(0, 6.0, s)
		elif p2_clock < p2_time:
			p2_clock = min(p2_clock + delta, p2_time)
			var s = smoothstep(0, 1, p2_clock / p2_time)
			gem.scale = Vector2.ONE * lerp(2.0, 1.0, s)
			
			# finish anim
			if p2_clock == p2_time:
				player.is_goal = false
				gem.z_as_relative = false
		
		# follow player
		else:
			var target = player.position + player.rot(Vector2.UP * 20)
			position = position.linear_interpolate(target, 0.1)
			
			#p3_clock = min(p3_clock + delta, p3_time)
			#var s = smoothstep(0, 1, p3_clock / p3_time)
			#circle.scale = Vector2.ONE * lerp(6.0, 3.0, s)

func turning(angle):
	sprites.rotation = angle

func pickup(ply):
	if is_collected: return
	
	player = ply
	
	is_collected = true
	gem.z_as_relative = true
	
	area.monitorable = false
