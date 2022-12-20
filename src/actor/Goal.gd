extends Node2D

onready var sprites = $Sprites
onready var area = $Area2D
onready var start_pos := position
var shine_easy := EaseMover.new(0.8)

var player = null
var is_collected := false
var is_follow := false

func _enter_tree():
	if Engine.editor_hint: return
	Shared.goal = self
	
	if !Shared.is_reload:
		Cutscene.is_show_goal = true
	
	CheatCode.connect("activate", self, "cheat_code")

func _ready():
	Cam.connect("turning", self, "turning")
	
	if Shared.goals.has(Shared.map_name):
		var c = 0.0
		sprites.modulate = Color(c,c,c, 0.2)

func _physics_process(delta):
	if shine_easy.clock > 0:
		shine_easy.count(delta, false)
		sprites.scale = Vector2.ONE * lerp(1.0, 1.8, shine_easy.smooth())
	
	# follow player
	if is_collected and player != null and is_follow:
		var target = player.position + player.rot(Vector2.UP * 20)
		position = position.linear_interpolate(target, 0.1)

func turning(angle):
	sprites.rotation = angle

func pickup(ply):
	if is_collected: return
	is_collected = true
	player = ply
	start_pos = position
	area.set_deferred("monitorable", false)
	Audio.play("gem_collect")

func cheat_code(cheat):
	if "konami" in cheat:
		pass#pickup(Shared.player)

func shine():
	shine_easy.clock = shine_easy.time
	Audio.play("gem_show")
