tool
extends Door

onready var sprites := $Sprites
onready var open := $Sprites/Open
onready var door_mat : ShaderMaterial = $Sprites/Door.material

onready var gem := $Sprites/Open/Gem
onready var gem_fill := $Sprites/Open/Gem/Fill
var is_gem := false
var gem_easy := EaseMover.new()

onready var clock := $Sprites/Open/Clock
var is_clock := false
var clock_easy := EaseMover.new()

func _ready():
	if Engine.editor_hint: return
	
	arrow.connect("activate", self, "activate")
	
	var m = scene_path.lstrip(Shared.worlds_path).rstrip(".tscn")
	clock.visible = Shared.goals.has(m) and Shared.goals[m] > 0 and Shared.speedruns.has(m) and Shared.goals[m] < Shared.speedruns[m]
	gem.visible = !clock.visible
	
	if "hub" in scene_path:
		gem.visible = false
	elif Shared.goals.has(m):
		gem_color(2)

func _physics_process(delta):
	if open_close:
		var s = open_easy.count(delta, open_close > 0)
		door_mat.set_shader_param("line", lerp(0.9, 0.1, s))
		var o = 1.0 - s
		open.scale.x = o
		open.visible = o > 0.01
		if open_easy.clock == 0.0 or open_easy.is_complete:
			open_close = 0
		
	elif is_gem:
		gem_easy.count(delta)
		gem.color = colors[1].linear_interpolate(colors[2], gem_easy.smooth())
		gem_fill.color = colors[0].linear_interpolate(colors[3], gem_easy.smooth())
		if gem_easy.clock == 0 or gem_easy.is_complete:
			is_gem = false
		
	elif is_clock:
		var c = clock_easy.count(delta)
		
		gem.rotation = TAU * 2 * c
		gem.scale = Vector2.ONE * lerp(1.0, 0.0, c)
		
		clock.rotation = -gem.rotation
		clock.scale = Vector2.ONE * lerp(0.0, 1.0, c)
		
		if clock_easy.is_complete:
			is_clock = false

func activate():
	Shared.speedrun_goal(scene_path, arrow.is_active)

func on_enter():
	Shared.collect_gem()

func gem_color(arg := 0):
	gem.color = colors[arg]
	gem_fill.color = colors[arg + 1]

func gem_fade(arg := true):
	is_gem = arg
	gem_easy.show = arg
	gem_easy.clock = 0 if arg else gem_easy.time
