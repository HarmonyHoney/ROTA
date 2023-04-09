extends Node

onready var gem := $Gem
onready var gems_node := $Gems
onready var gems := []

export var radius := 150.0
export var turn_speed := 1.0
var gem_count = 0

var clock := 0.0

var gem_ease := EaseMover.new(2.0)

var gem_offset := 0.3
var gem_time := 1.0

func _ready():
	set_physics_process(false)
	
	gem.visible = false
	for i in 50:
		gems_node.add_child(gem.duplicate())
	gems = gems_node.get_children()

func _physics_process(delta):
	clock += delta
	
	for i in gems.size():
		var f = clock - (gem_offset * i)
		var frac = clamp(f, 0.0, gem_time) / gem_time
		var under = abs(min(f, 0.0))
		
		var a = (TAU * (float(i) / float(gem_count))) + ((clock + under) * turn_speed)
		var pos = Vector2(radius, 0).rotated(a)
		gems[i].position = gems_node.to_local(Shared.player.global_position).linear_interpolate(pos, frac)
		gems[i].scale = Vector2.ONE * ease(frac, 0.5)
	

func act(d):
	if !is_instance_valid(d): return
	
	Cutscene.is_playing = true
	
	gems_node.global_position = d.global_position + Shared.rot(Vector2(0, -300), d.dir)
	Cam.target_node = null
	Cam.target_pos = d.global_position.linear_interpolate(gems_node.global_position, 2.0 / 3.0)
	Cam.start_zoom(0)
	
	gem_count = d.gem_count
	d.is_cutscene = false
	
	for i in gems.size():
		gems[i].visible = i < gem_count
		
		if i < gem_count:
			gems[i].position = Vector2(radius, 0).rotated(TAU * (float(i) / float(gem_count)))
	
	clock = 0.0
	set_physics_process(true)
	
	yield(get_tree().create_timer(2.0), "timeout")
	
	
	d.is_fade = true
	UI.up.show = false
	
	Audio.play("gem_collect", 0.6, 0.8)
	yield(get_tree().create_timer(3.0), "timeout")
	
	Cam.target_node = Shared.player
	
	set_physics_process(false)
	Cutscene.is_playing = false






