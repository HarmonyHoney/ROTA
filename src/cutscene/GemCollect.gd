extends Node

onready var audio_collect := $Collect

var step := 0
var time := 0.0

var door_dest
var player

func _ready():
	set_physics_process(false)

func _physics_process(delta):
	time += delta
	
	match step:
		0:
			if time > 0.15:
				next_step()
				door_dest.gem.fade_color()
				audio_collect.pitch_scale = rand_range(0.8, 1.3)
				audio_collect.play()
				
				HUD.is_gem = true
		1:
			if time > 1.0:
				next_step()
				HUD.gem_label.text = str(Shared.gem_count)
		2:
			var limit = 0.5
			var t = min(time, limit)
			var s = smoothstep(0, 1, t / limit)
			player.visible = true
			player.modulate.a = s
			
			if time > limit:
				next_step()
				player.set_physics_process(true)
				set_physics_process(false)
				door_dest.set_process_input(true)
				
				door_dest.arrow.visible = true
				door_dest.arrow_clock = 0.0
				
				HUD.is_gem = false

func next_step():
	time = 0.0
	step += 1

func begin():
	player = Shared.player
	door_dest = Shared.door_destination
	
	
	for i in [player, door_dest]:
		if !is_instance_valid(i):
			return
	
	set_physics_process(true)
	time = 0.0
	step = 0
	
	player.set_physics_process(false)
	player.visible = false
	door_dest.gem.set_color(false)
	door_dest.arrow.visible = false
	door_dest.set_process_input(false)
