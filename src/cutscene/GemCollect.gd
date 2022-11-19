extends Node

var is_playing := false
var step := 0
var clock := 0.0
var easy := EaseMover.new(0.5)
var is_clock := false
var is_collect := false

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
				easy.clock = 0
				Audio.play(Audio.gem_collect, 0.8)
				
				if is_collect:
					UI.up.show = true
				
				if is_clock:
					UI.down.show = true
				else:
					door_dest.gem.fade_color()
		1:
			if is_clock:
				door_dest.clock.scale = Vector2.ONE * easy.count(delta)
				door_dest.gem.scale = Vector2.ONE * (1 - easy.smooth())
			
			if clock > 1.0:
				next_step()
				easy.clock = 0
				UI.gem_label.text = str(Shared.gem_count)
				UI.clock_label.text = str(Shared.clock_rank)
		2:
			player.visible = true
			player.modulate.a = easy.count(delta)
			
			if clock > 0.5:
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
	is_clock = Cutscene.is_clock
	is_collect = Cutscene.is_collect
	
	set_physics_process(true)
	clock = 0.0
	step = 0
	
	player.set_physics_process(false)
	player.visible = false
	if is_clock:
		door_dest.clock.scale = Vector2.ZERO
		door_dest.gem.visible = true
	else:
		door_dest.gem.set_color(false)

func end():
	is_playing = false
	Cutscene.end()
	
	player.set_physics_process(true)
	set_physics_process(false)
	
	UI.up.show = false
	UI.down.show = false
