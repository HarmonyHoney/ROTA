extends Node2D

onready var sprites = $Sprites
onready var area = $Area2D
var shine_easy := EaseMover.new()
var fade_easy := EaseMover.new()

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
		modulate.a = fade_easy.count(delta, false)
	
	# follow target
	if is_instance_valid(target):
		global_position = global_position.linear_interpolate(target.global_position + target.rot(Vector2.UP * 20), 6.0 * delta)

func cheat_code(cheat):
	if "konami" in cheat:
		is_collected = true
		Shared.map_clock = 99
		Audio.play("gem_collect")

func shine(is_audio := true):
	shine_easy.clock = shine_easy.time
	if is_audio: Audio.play("gem_show")
