extends Node

onready var gem := $Gem
onready var gems_node := $Gems
onready var gems := []

export var radius := 150.0
export var turn_speed := 3.0

var door
var gem_count = 0

var clock := 0.0
var time := 10.0
var step := 0
signal done

export var gem_offset := 0.2
var gem_time := 1.0

var gem_last := 0.0
var gem_step := 0.0

var gem_shrink := Vector2(50, 0.5)
var socket_pos := Vector2.ZERO

var socket_ease := EaseMover.new(1.0)
var click_ease := EaseMover.new(0.5)


func _ready():
	set_physics_process(false)
	
	gem.visible = false
	gem.scale = Vector2.ZERO
	for i in 50:
		gems_node.add_child(gem.duplicate())
	gems = gems_node.get_children()
	
	gem.z_index = gems_node.z_index + 1
	gem.z_as_relative = false

func _physics_process(delta):
	clock += delta
	
	gem_last = gem_step
	gem_step = floor(clock / gem_offset)
	
	var shrink = clamp(clock - gem_shrink.x, 0.0, gem_shrink.y) / gem_shrink.y
	
	if gem_step != gem_last and gem_step < gem_count:
		Audio.play("gem_piano", 0.5 + (gem_step * 0.1))
	
	for i in gems.size():
		var f = clock - (gem_offset * i)
		var frac = clamp(f, 0.0, gem_time) / gem_time
		var under = abs(min(f, 0.0))
		
		var a = (TAU * (float(i) / float(gem_count))) + ((clock + under) * turn_speed)
		var pos = Vector2(radius * (1.0 - shrink) * -sign(turn_speed), 0).rotated(a)
		gems[i].position = gems_node.to_local(Shared.player.global_position).linear_interpolate(pos, frac)
		gems[i].scale = Vector2.ONE * ease(frac - shrink, 0.5)
	
	gem.scale = Vector2.ONE * lerp(0.0, 2.5, shrink)
	
	if step == 2:
		gem.global_position = gems_node.global_position.linear_interpolate(socket_pos, socket_ease.count(delta))
	elif step == 3:
		click_ease.count(delta)
		var w = ease(abs(wrapf(click_ease.frac() * 2.0, -1.0, 1.0)), -5)
		gem.scale = Vector2.ONE * lerp(2.5, 2.2, w)
	
	if clock > time:
		step += 1
		
		match step:
			1:
				time += 2.0
				Audio.play("clock_collect", 0.8, 1.2)
				#door.is_fade = true
				Cam.target_node = gem
			2:
				time += socket_ease.time
				socket_ease.clock = 0.0
				gems_node.visible = false
			3:
				time += click_ease.time
				click_ease.clock = 0.0
				Audio.play("gem_show", 0.2, 0.4)
			4:
				door.gem_color(true)
				gem.visible = false
				
				emit_signal("done")
				set_physics_process(false)

func act(d):
	if !is_instance_valid(d): return
	door = d
	
	Cutscene.is_playing = true
	
	gems_node.global_position = door.global_position + Shared.rot(Vector2(0, -300), door.dir)
	gem.position = gems_node.position
	socket_pos = door.global_position + Shared.rot(Vector2(0, -10), door.dir)
	
	Cam.target_node = null
	Cam.target_pos = door.global_position.linear_interpolate(gems_node.global_position, 2.0 / 3.0)
	Cam.start_zoom(0)
	
	gem_count = door.gem_count
	door.is_cutscene = false
	UI.up.show = false
	
	gem.visible = true
	gem.scale = Vector2.ZERO
	gems_node.visible = true
	for i in gems.size():
		gems[i].visible = i < gem_count
		gems[i].scale = Vector2.ZERO
	
	clock = 0.0
	step = 0
	time = (gem_count * gem_offset) + gem_time
	gem_shrink.x = time
	if randf() > 0.5: turn_speed = -turn_speed
	
	set_physics_process(true)
	yield(self, "done")
	
	Cam.target_node = Shared.player
	Cutscene.is_playing = false






