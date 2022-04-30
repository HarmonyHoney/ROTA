extends Node

var is_playing := false
var step := 0
var clock := 0.0

var door_dest
var player

func _ready():
	set_physics_process(false)

func _physics_process(delta):
	clock += delta
	
	match step:
		0:
			if clock > 0.15:
				next_step()
				door_dest.gem.fade_color()
				Audio.play(Audio.gem_collect, 0.8)
				
				UI.gem.show = true
		1:
			if clock > 1.0:
				next_step()
				UI.gem_label.text = str(Shared.gem_count)
		2:
			var limit = 0.5
			var t = min(clock, limit)
			var s = smoothstep(0, 1, t / limit)
			player.visible = true
			player.modulate.a = s
			
			if clock > limit:
				end()

func next_step():
	clock = 0.0
	step += 1

func begin():
	player = Shared.player
	door_dest = Shared.door_destination
	
	for i in [player, door_dest]:
		if !is_instance_valid(i):
			return
	
	is_playing = true
	Cutscene.start()
	
	set_physics_process(true)
	clock = 0.0
	step = 0
	
	player.set_physics_process(false)
	player.visible = false
	door_dest.gem.set_color(false)

func end():
	is_playing = false
	Cutscene.end()
	
	player.set_physics_process(true)
	set_physics_process(false)
	
	UI.gem.show = false
