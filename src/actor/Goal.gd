extends Node2D

onready var sprites = $Sprites
onready var area = $Area2D
var shine_easy := EaseMover.new()
var fade_easy := EaseMover.new()
var turn_x := 1.0
var turn_easy := EaseMover.new(0.3)

var target = null
var is_collected := false

func _enter_tree():
	if Engine.editor_hint: return
	Shared.goal = self
	
	if !Shared.is_reload:
		Cutscene.is_show_goal = true
	
	CheatCode.connect("activate", self, "cheat_code")

func _ready():
	Cam.connect("turning", self, "set_rotation")
	
	if Shared.goals.has(Shared.map_name):
		var c = 0.0
		sprites.modulate = Color(c,c,c, 0.2)

func _physics_process(delta):
	if shine_easy.clock > 0:
		sprites.scale = Vector2.ONE * lerp(1.0, 2.0, shine_easy.count(delta, false))
	
	if fade_easy.clock > 0:
		var s = fade_easy.count(delta, false)
		sprites.scale = Vector2.ONE * lerp(0.0, 1.0, s)
		sprites.rotation = lerp(TAU * 0.3 * turn_x, 0.0, s)
	
	# follow target
	if is_instance_valid(target):
		var p = target.global_position
		if target == Shared.player:
			var s = turn_easy.count(delta, target.dir_x < 0, false)
			p += Vector2(lerp(-1.0, 1.0, ease(s, -0.7)) * 50, -30).rotated(target.sprites.rotation)
		
		global_position = global_position.linear_interpolate(p, 6.0 * delta)

func cheat_code(cheat):
	if "konami" in cheat:
		is_collected = true
		Shared.map_clock = 99
		Audio.play("gem_collect")

func shine(is_audio := true):
	shine_easy.clock = shine_easy.time
	if is_audio: Audio.play("gem_show")
