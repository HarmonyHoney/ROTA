extends Node

onready var audio_coin := $Coin
onready var audio_collect := $Collect

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
				audio_collect.pitch_scale = rand_range(0.8, 1.3)
				audio_collect.play()
				
				UI.gem.show = true
		1:
			if clock > 1.0:
				next_step()
				UI.gem_label.text = str(Shared.gem_count)
				#audio_coin.play()
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
	
	Cutscene.start()
	
	set_physics_process(true)
	clock = 0.0
	step = 0
	
	player.set_physics_process(false)
	player.visible = false
	door_dest.gem.set_color(false)

func end():
	Cutscene.end()
	
	player.set_physics_process(true)
	set_physics_process(false)
	
	UI.gem.show = false
